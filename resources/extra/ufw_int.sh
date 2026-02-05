SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PLUGIN_DIR="$SCRIPT_DIR/../plugins"

cp "$PLUGIN_DIR/ufw.zip" /usr/local/ufw.zip
sudo unzip -o /usr/local/ufw.zip -d /usr/local

cp "$PLUGIN_DIR/config_ufw.zip" /usr/local/config_ufw.zip

if [ ! -d "/usr/local/ufw/conf" ]; then
    sudo unzip -o /usr/local/config_ufw.zip -d /usr/local/ufw
fi