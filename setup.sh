#!/bin/bash

# Functions
change_source() {
    local source_url=$1
    local source_list="/etc/apt/sources.list"
    
    # Backup original sources.list
    sudo cp $source_list "${source_list}.backup"

    # Change source
    sudo sed -i "s|http://.*.ubuntu.com|${source_url}|g" $source_list
}

# Variables
source /etc/os-release
UBUNTU_CODENAME=$VERSION_CODENAME
NEW_APT_SOURCE="https://mirrors.ustc.edu.cn"
SSH_KEY_FILE="$HOME/.ssh/id_ed25519_ssh"
SSHD_CONFIG_PATH="/etc/ssh/sshd_config"

# Change source to USTC
change_source $NEW_APT_SOURCE
sudo apt update
sudo apt upgrade -y

# Install particular packages
sudo apt install -y net-tools wireless-tools locales language-pack-zh-hans python3-pip docker.io libsensors5 lm-sensors stress s-tui cmake upower

# Update pip
sudo pip3 install --upgrade pip

# Configure Docker
sudo adduser $USER docker

# Configure locale
sudo update-locale LANG=zh_CN.UTF-8
sudo dpkg-reconfigure locales 

# Configure SSH to PubkeyAuthentication only
echo "Generating SSH key pair..."
ssh-keygen -t ed25519 -a 100 -f "$SSH_KEY_FILE" -N "" -q
cat $SSH_KEY_FILE.pub >> $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/authorized_keys
chmod 700 $HOME/.ssh

sudo cp "$SSHD_CONFIG_PATH" "$SSHD_CONFIG_PATH.backup"
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' "$SSHD_CONFIG_PATH"
sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' "$SSHD_CONFIG_PATH"
sudo sed -i 's/#UsePAM yes/UsePAM no/' "$SSHD_CONFIG_PATH"
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$SSHD_CONFIG_PATH"
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' "$SSHD_CONFIG_PATH"

sudo service ssh restart
sudo service sshd restart
