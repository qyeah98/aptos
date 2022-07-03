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

echo -e "\e[1m\e[32m1. Set your info \e[0m" && sleep 1

ADDRESS=$(curl inet-ip.info)

echo -e "\e[1m\e[32mSet your username \e[0m" && sleep 1
read -p "INPUT Username: " USERNAME

echo "=================================================="

echo -e "\e[1m\e[32m2. Updating list of dependencies... \e[0m" && sleep 1
sudo apt update -y
sudo apt upgrade -y
sudo apt install unzip -y

sudo cd $HOME

echo "=================================================="

echo -e "\e[1m\e[32m3. Checking if Docker is installed... \e[0m" && sleep 1

if ! command -v docker &> /dev/null
then
    echo -e "\e[1m\e[32mInstalling Docker... \e[0m" && sleep 1
    sudo apt-get install ca-certificates curl gnupg lsb-release wget -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
fi

echo "=================================================="

echo -e "\e[1m\e[32m4. Checking if Docker Compose is installed ... \e[0m" && sleep 1

echo -e "\e[1m\e[32mInstalling Docker Compose v2.6.1 ... \e[0m" && sleep 1
sudo mkdir -p ~/.docker/cli-plugins/
sudo curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
sudo chmod +x ~/.docker/cli-plugins/docker-compose
sudo chown $USER /var/run/docker.sock

echo "=================================================="

echo -e "\e[1m\e[32m5. Installing Aptos CLI ... \e[0m" && sleep 1

sudo wget -qO aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-0.2.0/aptos-cli-0.2.0-Ubuntu-x86_64.zip
sudo unzip -o aptos-cli.zip -d /usr/bin
sudo chmod +x /usr/bin/aptos
sudo rm aptos-cli.zip

echo "=================================================="

echo -e "\e[1m\e[32m6. Downloading Aptos Validator config files ... \e[0m" && sleep 1

sudo rm -rf ~/testnet

sudo mkdir -p ~/testnet  && cd ~/testnet
echo "$(pwd)"

sudo wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
sudo wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml


echo "=================================================="

echo -e "\e[1m\e[32m7. Setting Validator ... \e[0m" && sleep 1

echo -e "\e[1m\e[32m7.1 Generating Keys... \e[0m" && sleep 1
aptos genesis generate-keys --output-dir ~/$testnet

aptos genesis set-validator-configuration \
    --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
    --username $USERNAME \
    --validator-host $ADDRESS:6180

echo -e "\e[1m\e[32m7.2 Creating YAML file... \e[0m" && sleep 1
sudo tee layout.yaml > /dev/null <<EOF
---
root_key: "F22409A93D1CD12D2FC92B5F8EB84CDCD24C348E32B3E7A720F3D2E288E63394"
users:
  - $USERNAME
chain_id: 40
min_stake: 0
max_stake: 100000
min_lockup_duration_secs: 0
max_lockup_duration_secs: 2592000
epoch_duration_secs: 86400
initial_lockup_timestamp: 1656615600
min_price_per_gas_unit: 1
allow_new_validators: true
EOF

echo -e "\e[1m\e[32m7.2 Downloading AptosFramework Move bytecode... \e[0m" && sleep 1
sudo wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.2.0/framework.zip
sudo unzip framework.zip

echo -e "\e[1m\e[32m7.3 Compiling genesis blob and waypoint.... \e[0m" && sleep 1
aptos genesis generate-genesis --local-repository-dir ~/testnet --output-dir ~/testnet


echo "=================================================="

echo -e "\e[1m\e[32m8. Starting Aptos Validator ... \e[0m" && sleep 1

sudo docker compose up -d

echo "=================================================="

echo -e "\e[1m\e[32m9. Aptos Validator Started \e[0m" && sleep 1

sudo docker ps

echo "=================================================="

echo -e "\e[1m\e[32m10. Info \e[0m" && sleep 1

echo -e "\e[1m\e[32mTo update docker image: \e[0m"
echo -e "\e[1m\e[39m    docker compose pull \n \e[0m"

echo -e "\e[1m\e[32mTo view validator logs: \e[0m"
echo -e "\e[1m\e[39m    docker logs -f testnet-validator-1 --tail 100 \n \e[0m"

echo -e "\e[1m\e[32mTo view fullnode logs: \e[0m"
echo -e "\e[1m\e[39m    docker logs -f testnet-fullnode-1 --tail 100 \n \e[0m"

echo -e "\e[1m\e[32mTo stop: \e[0m"
echo -e "\e[1m\e[39m    docker compose stop \n \e[0m"

echo "=================================================="

echo -e "\e[1m\e[32m11. To Register your node \e[0m"  && sleep 1

echo -e "\e[1m\e[32mRegistration site \e[0m"
echo -e "\e[1m\e[39m    https://community.aptoslabs.com/ \n \e[0m"

echo -e "\e[1m\e[32mRegistration parameter \e[0m"
echo -e "\e[1m\e[39m   $(sudo cat $HOME/testnet/$USERNAME.yaml) \n \e[0m"

echo -e "\e[1m\e[32mPublic IP \e[0m"
echo -e "\e[1m\e[39m   $ADDRESS \n \e[0m"
echo "=================================================="

