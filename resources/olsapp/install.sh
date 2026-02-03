#!/bin/bash

# Detect OS info
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VERSION=${VERSION_ID%%.*}
elif [ -f /etc/centos-release ]; then
    OS_NAME="centos"
    OS_VERSION=$(awk '{print $4}' /etc/centos-release | cut -d. -f1)
fi

# Function to remove blank/duplicate cron lines
remove_extra_cron_lines() {
    crontab -l 2>/dev/null | grep -v '^[[:space:]]*$' | sort | uniq | crontab -
    echo "Extra lines (blank/duplicate) have been removed from the cron jobs!"
}

# Add backup cronjobs based on OS
add_backup_cronjobs() {
    local PYTHON_CMD

    if [[ ("$OS_NAME" == "centos" || "$OS_NAME" == "almalinux") && ("$OS_VERSION" == "7" || "$OS_VERSION" == "8") ]]; then
        PYTHON_CMD="/root/venv/bin/python3.12"
    elif [[ "$OS_NAME" == "ubuntu" && "$OS_VERSION" -ge 24 ]]; then
        PYTHON_CMD="/root/venv/bin/python"
    elif [[ "$OS_NAME" == "ubuntu" && "$OS_VERSION" -lt 24 ]]; then
        PYTHON_CMD=$(which python3)
    else
        PYTHON_CMD="/root/venv/bin/python3"
    fi

    local CRON_JOBS="\
0 0 * * * $PYTHON_CMD /usr/local/lsws/Example/html/mypanel/manage.py check_version
0 */3 * * * $PYTHON_CMD /usr/local/lsws/Example/html/mypanel/manage.py limit_check
"

    ( crontab -l 2>/dev/null; echo "$CRON_JOBS" ) | crontab -
    remove_extra_cron_lines
    echo "Cron jobs have been added successfully!"
}

run_repo() {
    # wget -O - https://repo.litespeed.sh | sudo bash

    OUTPUT=$(cat /etc/*release)

    if echo "$OUTPUT" | grep -q "Ubuntu 18.04\|Ubuntu 20.04\|Ubuntu 22.04\|Ubuntu 24.04"; then
        SERVER_OS="Ubuntu"
        sudo apt update -qq

    elif echo "$OUTPUT" | grep -q "Debian"; then
        SERVER_OS="Debian"
        sudo apt update -qq

    elif echo "$OUTPUT" | grep -q "AlmaLinux 8\|AlmaLinux 9\|CentOS Linux 8\|CentOS Stream 8\|CentOS Stream 9\|Rocky Linux 8\|Rocky Linux 9"; then
        SERVER_OS="Centos"
        sudo dnf update -y
    fi
    
   

}
run_py() {
    local PYTHON_CMD

    if [[ ("$OS_NAME" == "centos" || "$OS_NAME" == "almalinux") && ("$OS_VERSION" == "7" || "$OS_VERSION" == "8") ]]; then
        PYTHON_CMD="/root/venv/bin/python3.12"
    elif [[ "$OS_NAME" == "ubuntu" && "$OS_VERSION" -ge 24 ]]; then
        PYTHON_CMD="/root/venv/bin/python"
    elif [[ "$OS_NAME" == "ubuntu" && "$OS_VERSION" -lt 24 ]]; then
        PYTHON_CMD=$(which python3)
    else
        PYTHON_CMD="/root/venv/bin/python3"
    fi

    echo "Trying $PYTHON_CMD /usr/local/lsws/Example/html/mypanel/manage.py install_olsapp"
    $PYTHON_CMD /usr/local/lsws/Example/html/mypanel/manage.py install_olsapp
    local STATUS=$?

    if [[ $STATUS -ne 0 ]]; then
        echo "First attempt failed, trying fallback Python interpreters..."

        # Fallback Python interpreters to try if the first fails
        local FALLBACKS=(
            "/usr/bin/python3"
            "$(which python3)"
            "/usr/local/bin/python3"
            "/root/venv/bin/python"
        )

        for alt_python in "${FALLBACKS[@]}"; do
            if [[ -x "$alt_python" ]]; then
                echo "Trying fallback: $alt_python /usr/local/lsws/Example/html/mypanel/manage.py install_olsapp"
                $alt_python /usr/local/lsws/Example/html/mypanel/manage.py install_olsapp
                STATUS=$?
                if [[ $STATUS -eq 0 ]]; then
                    echo "Succeeded with fallback: $alt_python"
                    return 0
                fi
            else
                echo "Fallback interpreter not executable or not found: $alt_python"
            fi
        done

        echo "All fallback attempts failed."
        return 1
    fi
}

install_olsapp() {
    ZIP_URL="https://olspanel.com/olsapp/olsapp.zip?ts=$(date +%s)"
    DEST_DIR="/usr/local/lsws/Example/html/olsapp"
    ZIP_FILE="/usr/local/lsws/Example/html/olsapp.zip"

    
    
    # Check for local file in various locations
    # Prioritizing the one in the current directory acting as 'olsapp.zip' (which I just downloaded)
    if [ -f "olsapp.zip" ]; then
        echo "Found olsapp.zip in current directory. Using it."
        cp "olsapp.zip" "$ZIP_FILE"
    elif [ -f "../olsapp.zip" ]; then
        echo "Found olsapp.zip in parent directory."
        cp "../olsapp.zip" "$ZIP_FILE"
    else
        echo "Local olsapp.zip not found. Proceeding to download..."
        wget -O "$ZIP_FILE" "$ZIP_URL" --no-cache --no-cookies
    fi

    echo "Extracting olsapp..."
    mkdir -p "$DEST_DIR"
    unzip -o "$ZIP_FILE" -d "$DEST_DIR"
    rm -f "$ZIP_FILE"

    echo "olsapp installed at: $DEST_DIR"
}

# Run installer
run_repo
install_olsapp
#run_py
chown -R olspanel:olspanel /usr/local/lsws/Example/html/olsapp

