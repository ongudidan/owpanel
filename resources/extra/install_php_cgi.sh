#!/bin/bash
echo "please wait... php cgi installing...."
# Suppress all output and errors
# LOGFILE="/root/cgi_install.log"
# touch "$LOGFILE" 2>/dev/null || LOGFILE="/tmp/cgi_install.log"
# exec >>"$LOGFILE" 2>&1


# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VERSION=${VERSION_ID%%.*}
elif [ -f /etc/centos-release ]; then
    OS_NAME="centos"
    OS_VERSION=$(awk '{print $4}' /etc/centos-release | cut -d. -f1)
fi

# Choose package manager
if [[ "$OS_NAME" == "ubuntu" || "$OS_NAME" == "debian" ]]; then
    PACKAGE_MANAGER="apt"
elif [[ "$OS_NAME" =~ ^(centos|almalinux|rhel|fedora|rocky|oraclelinux)$ ]]; then
    if command -v dnf &>/dev/null; then
        PACKAGE_MANAGER="dnf"
    else
        PACKAGE_MANAGER="yum"
    fi
else
    exit 0
fi

install_all_cgi_php_versions() {
    sudo ${PACKAGE_MANAGER} update -y || true
    sudo ${PACKAGE_MANAGER} install -y software-properties-common lsb-release apt-transport-https ca-certificates || true

    if ! grep -q "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:ondrej/php || true
        sudo ${PACKAGE_MANAGER} update -y || true
    fi

    for version in 7.4 8.2; do
        ini_file="/etc/php/$version/cgi/php.ini"
        if [ ! -f "$ini_file" ]; then
            sudo ${PACKAGE_MANAGER} install -y \
                php${version}-cgi \
                php${version}-cli \
                php${version}-common \
                php${version}-mbstring \
                php${version}-zip \
                php${version}-curl \
                php${version}-sqlite3 \
                php${version}-bcmath \
                php${version}-intl || true

sudo ${PACKAGE_MANAGER} install -y php${version}-xml || true
sudo ${PACKAGE_MANAGER} install -y php${version}-mysql || true
sudo ${PACKAGE_MANAGER} install -y php${version}-imap || true
sudo ${PACKAGE_MANAGER} install -y php${version}-mysqlnd || true
sudo ${PACKAGE_MANAGER} install -y php${version}-php-imap || true
sudo ${PACKAGE_MANAGER} install -y php${version}-json || true

            [ -f "$ini_file" ] && {
                sudo sed -i 's/^upload_max_filesize\s*=.*/upload_max_filesize = 80M/' "$ini_file" || true
                sudo sed -i 's/^post_max_size\s*=.*/post_max_size = 80M/' "$ini_file" || true
            }
        fi
    done

    sudo pkill php || true
}

install_all_cgi_php_versions_centos() {
    for version in 8.2 8.3; do
        ini_file="/etc/php/${version}/cgi/php.ini"
        case "$version" in
            8.2) rpm_url="https://olspanel.com/repo-files/centos-php82-cgi/php8.2-8.2.0-1.el9.x86_64.rpm" ;;
            8.3) rpm_url="https://olspanel.com/repo-files/centos-php83-cgi/php8.3-8.3.0-1.el9.x86_64.rpm" ;;
            *) continue ;;
        esac

        if [ ! -f "$ini_file" ]; then
            sudo ${PACKAGE_MANAGER} install -y "$rpm_url" || true

            [ -f "$ini_file" ] && {
                sudo sed -i 's/^upload_max_filesize\s*=.*/upload_max_filesize = 80M/' "$ini_file" || true
                sudo sed -i 's/^post_max_size\s*=.*/post_max_size = 80M/' "$ini_file" || true
            }
        fi
    done
}

if [[ "$OS_NAME" =~ ^(centos|almalinux|rhel|fedora|rocky|oraclelinux)$ ]]; then
    install_all_cgi_php_versions_centos
else
    install_all_cgi_php_versions
fi

sudo ${PACKAGE_MANAGER} install -y php8.2-intl || true
