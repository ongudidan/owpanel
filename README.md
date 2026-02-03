# 🚀 OLSpanel - Free OpenLiteSpeed Web Hosting Control Panel

`OLSpanel` is a **free** and lightweight control panel designed for managing OpenLiteSpeed web hosting with ease. With just a few clicks, you can install and start managing your web server effortlessly.

---

## 📌 Features
✅ **Account Management** – allow users to set and manage disk and bandwidth limits according to their selected package.  
✅ **OpenLiteSpeed Web Server** – Fast and efficient web server for optimized performance.  
✅ **MariaDB Database** – Reliable and high-performance database management.  
✅ **Auto SSL** – Secure your websites with Let's Encrypt SSL.  
✅ **FTP Server** – Built-in FTP management for easy file transfers.  
✅ **DNS Server (PowerDNS)** – Integrated DNS management for domains.  
✅ **phpMyAdmin** – Database management made simple.  
✅ **Email Support** – Send and receive emails effortlessly.  
✅ **File Manager** – Web-based file management for convenience.  
✅ **PHP Management** – Configure and switch PHP versions easily.  
✅ **Firewall Protection** – FirewallD & ConfigServer Firewall (CSF) integration.  
✅ **One-Click Backups & Restores** – Securely back up and restore your data.  

---

## 🖥️ Supported Operating Systems
`OLSpanel` is currently supported on following OS:


- ✅ **Ubuntu 20.04 (Focal Fossa)**
- ✅ **Ubuntu 22.04 (Jammy Jellyfish)**
- ✅ **Ubuntu 24.04 (Noble Numbat)**
- ✅ **CentOS 8/9**
- ✅ **AlmaLinux 8/9**
- ✅ **Rocky Linux 8/9**
- ✅ **Debian 11/12**

> ℹ️ *Support for additional Linux distributions is coming soon!*

---

## 🖼️ Screenshots

Here are some screenshots of the **OLSpanel** control panel:

*OpenLiteSpeed Web Server admin/whm Dashboard*
![whm](screenshort/whm.png)  

*User Panel  Interface*
![User panel Interface](screenshort/user.png)  





## 📥 Installation

This version of OLSpanel is designed to be installed from your own self-hosted repository, ensuring full offline capability and independence from external sources.

Run the following commands to install:

```sh
# Clone your repository (replace URL with your actual repo URL)
git clone https://github.com/ongudidan/owpanel.git
cd owpanel

# Fix line endings (CRLF issues) and permissions
sudo apt install dos2unix -y
find . -type f -name "*.sh" -exec dos2unix {} \;
chmod +x *.sh resources/**/*.sh 2>/dev/null

# Run the localized installer
sudo bash install.sh
```

## 🔐 Troubleshooting & Access

### Manual Password Reset
If you are unable to log in with the displayed password, you can reset the admin password directly via SSH:

```bash
# Run this command as root
olspanel reset_admin_password my_new_password
```

Replace `my_new_password` with your desired secure password.
