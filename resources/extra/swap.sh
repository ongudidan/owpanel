#!/bin/bash
HOME_PATH_FILE="/etc/olspanel/base_dir"
if [ -f "$HOME_PATH_FILE" ]; then
    # Read value from file
    PROJECT_DIR="$(cat "$HOME_PATH_FILE")"
else
    # Extract from systemd service
    PROJECT_DIR="/usr/local/lsws/Example/html/mypanel"
fi
# Define swap file path
SWAP_File="/olspanel.swap"

# Get total RAM and current swap in MiB
Total_RAM=$(free -m | awk '/^Mem:/ { print $2 }')
Total_SWAP=$(free -m | awk '/^Swap:/ { print $2 }')

# Calculate required swap
Set_SWAP=$((Total_RAM - Total_SWAP))

# Only proceed if swap file doesn't exist
if [ ! -f "$SWAP_File" ]; then
  echo -e "🔍 Checking current SWAP setup...\n"

  if [[ $Total_SWAP -ge $Total_RAM ]]; then
    echo -e "✅ Sufficient swap already exists: ${Total_SWAP}MB"
  else
    # Limit swap size to 2048 MB max
    if [[ $Set_SWAP -gt 2048 ]]; then
      Set_SWAP=2048
    fi

    echo -e "🛠 Creating ${Set_SWAP}MiB swap file at $SWAP_File..."

    # Create swap file
    sudo fallocate -l "${Set_SWAP}M" "$SWAP_File" || sudo dd if=/dev/zero of="$SWAP_File" bs=1M count="$Set_SWAP"
    sudo chmod 600 "$SWAP_File"
    sudo mkswap "$SWAP_File"
    sudo swapon "$SWAP_File"

    # Add to fstab if not already present
    if ! grep -q "$SWAP_File" /etc/fstab; then
      echo "$SWAP_File swap swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
    fi

    # Set swappiness
    sudo sysctl vm.swappiness=10
    if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
      echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf > /dev/null
    fi

    echo -e "\n✅ Swap of ${Set_SWAP}MiB set up successfully.\n"
    swapon --show
  fi
else
  echo -e "⚠️ Swap file already exists at $SWAP_File."
fi





# Localize dependencies: Define local resource paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PLUGIN_DIR="$SCRIPT_DIR/../plugins"
EXTRA_DIR="$SCRIPT_DIR"

# Helper function to install plugin from local zip
install_local_plugin() {
    local plugin_name=$1
    local zip_name="$plugin_name.zip"
    local local_zip="$PLUGIN_DIR/$zip_name"
    local target_dir="$PROJECT_DIR/3rdparty/$plugin_name"

    if [ -f "$local_zip" ]; then
        echo "Installing $plugin_name from local source: $local_zip..."
        mkdir -p "$target_dir"
        # Assuming plugin zips might contain a top-level folder or not, standardizing to extract INTO target or parent?
        # Usually web apps extract into 'roundcube/' etc.
        # But safest is unzip -d
        # If the zip has the folder inside, we might end up with target/plugin/index.php.
        # Let's inspect typical behavior: install_cp_plugin usually unzips to directory.
        # For safety, let's unzip to a temp dir and move.
        TEMP_EXTRACT="/tmp/plugin_extract_$plugin_name"
        rm -rf "$TEMP_EXTRACT"
        mkdir -p "$TEMP_EXTRACT"
        unzip -q -o "$local_zip" -d "$TEMP_EXTRACT"
        
        # Check content
        if [ -d "$TEMP_EXTRACT/$plugin_name" ]; then
             # Zip had folder inside
             cp -r "$TEMP_EXTRACT/$plugin_name/"* "$target_dir/"
        else
             # Zip was loose files
             cp -r "$TEMP_EXTRACT/"* "$target_dir/"
        fi
        rm -rf "$TEMP_EXTRACT"
        
        # Permissions
        chown -R nobody:nobody "$target_dir"
        echo "✅ $plugin_name installed successfully."
    else
        echo "⚠️  Local plugin archive not found: $local_zip"
        echo "Please place $zip_name in owpanel/resources/plugins/ to install it."
    fi
}


# Localize scripts (olspanel CLI, etc.)
if [ -f "$EXTRA_DIR/olspanel.sh" ]; then
    cp "$EXTRA_DIR/olspanel.sh" /etc/profile.d/olspanel.sh
fi

if [ -f "$EXTRA_DIR/ufw_int.sh" ]; then
    bash "$EXTRA_DIR/ufw_int.sh"
fi

if [ -f "$EXTRA_DIR/install_php_cgi.sh" ]; then
    bash "$EXTRA_DIR/install_php_cgi.sh"
fi

# olspanel CLI binary
if [ -f "$EXTRA_DIR/olspanel" ]; then
    cp "$EXTRA_DIR/olspanel" /usr/local/bin/olspanel
    chmod +x /usr/local/bin/olspanel
fi

# Install Plugins Locally
rainloop="$PROJECT_DIR/3rdparty/rainloop/index.php"
roundcube="$PROJECT_DIR/3rdparty/roundcube/index.php"

if [ ! -f "$roundcube" ]; then
    install_local_plugin "roundcube"
fi

if [ ! -f "$rainloop" ]; then
    install_local_plugin "rainloop"
fi

install_local_plugin "phpmyadmin"