#!/bin/bash
# scripts/bootstrap_linux.sh
# PURPOSE: Prepare a Linux host for Ansible management (Install Python3)
# USAGE: Run this on the target Linux server if Ansible fails to connect.

echo "🐧 Detecting OS and setting up Ansible prerequisites..."

# Check if we are root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

# Function to install python on Debian/Ubuntu
install_debian() {
    echo "Detected Debian/Ubuntu system."
    apt-get update -y
    apt-get install -y python3 python3-pip openssh-server
}

# Function to install python on RHEL/CentOS
install_rhel() {
    echo "Detected RHEL/CentOS/Fedora system."
    dnf install -y python3 python3-pip openssh-server
    # Ensure firewall allows SSH
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --reload
}

if [ -f /etc/debian_version ]; then
    install_debian
elif [ -f /etc/redhat-release ]; then
    install_rhel
else
    echo "Unsupported OS. Please install Python3 manually."
    exit 1
fi

# Ensure SSH is running
systemctl enable --now sshd
echo "✅ Linux Host is ready for Ansible!"