wget -O /usr/local/ufw.zip "https://olspanel.com/plugin/ufw.zip?$(date +%s)"
sudo unzip -o /usr/local/ufw.zip -d /usr/local

wget -O /usr/local/config_ufw.zip "https://olspanel.com/plugin/config_ufw.zip?$(date +%s)"

if [ ! -d "/usr/local/ufw/conf" ]; then
    sudo unzip -o /usr/local/config_ufw.zip -d /usr/local/ufw
fi