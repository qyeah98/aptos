#!/bin/bash

echo "=================================================="
echo -e "\033[0;35m"
echo "                             .__      ";
echo "   _________.__. ____ _____  |  |__   ";
echo "  / ____<   |  |/ __ \\__  \ |  |  \  ";
echo " < <_|  |\___  \  ___/ / __ \|   Y  \ ";
echo "  \__   |/ ____|\___  >____  /___|  / ";
echo "     |__|\/         \/     \/     \/  ";
echo "                                      ";
echo -e "\e[0m"
echo "=================================================="

sleep 2

echo -e "\e[1m\e[32m0. Install list of dependencies \e[0m" && sleep 1

cd $HOME

sudo apt update -y
sudo apt upgrade -y
sudo apt install zip unzip jq fio -y

echo "=================================================="

echo -e "\e[1m\e[32m1. Install Docker \e[0m" && sleep 1

echo -e "\e[1m\e[32m1.1 Installing Docker... \e[0m" && sleep 1
sudo apt-get install ca-certificates curl gnupg lsb-release wget -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

echo -e "\e[1m\e[32m1.2 Installing Docker Compose v2.6.1 ... \e[0m" && sleep 1
sudo mkdir -p ~/.docker/cli-plugins/
sudo curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
sudo chmod +x ~/.docker/cli-plugins/docker-compose
sudo chown $USER /var/run/docker.sock

echo "=================================================="

echo -e "\e[1m\e[32m2. Install Aptos CLI \e[0m" && sleep 1

sudo wget -qO aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.3.8/aptos-cli-0.3.8-Ubuntu-x86_64.zip
sudo unzip -o aptos-cli.zip -d /usr/bin
sudo chmod +x /usr/bin/aptos
sudo rm aptos-cli.zip

echo "=================================================="

echo -e "\e[1m\e[32mInfo \e[0m" && sleep 1

echo -e "\e[1m\e[32mDocker Version: \e[0m"
echo -e "\e[1m\e[39m    $(docker -v) \n \e[0m"

echo -e "\e[1m\e[32mDocker Version: \e[0m"
echo -e "\e[1m\e[39m    $(docker compose version) \n \e[0m"

echo -e "\e[1m\e[32mAptos CLI Version: \e[0m"
echo -e "\e[1m\e[39m    $(aptos -V) \n \e[0m"

echo "=================================================="
