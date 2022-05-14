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

echo -e "\e[1m\e[32m1.1 Set your IP/DNS \e[0m" && sleep 1
read -p "INPUT Your IP/DNS : " ADDRESS

echo "=================================================="

echo -e "\e[1m\e[32m1.2 Set your username \e[0m" && sleep 1
read -p "INPUT Username: " USERNAME

echo "=================================================="

echo -e "\e[1m\e[32m2. Updating list of dependencies... \e[0m" && sleep 1
sudo apt-get update
cd $HOME

echo "=================================================="

echo -e "\e[1m\e[32m3. Checking if Docker is installed... \e[0m" && sleep 1

if ! command -v docker &> /dev/null
then

    echo -e "\e[1m\e[32m3.1 Installing Docker... \e[0m" && sleep 1
    sudo apt-get install ca-certificates curl gnupg lsb-release wget -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
fi

echo "=================================================="

echo -e "\e[1m\e[32m4. Checking if Docker Compose is installed ... \e[0m" && sleep 1

docker compose version &> /dev/null
if [ $? -ne 0 ]
then

    echo -e "\e[1m\e[32m4.1 Installing Docker Compose v2.3.3 ... \e[0m" && sleep 1
    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    sudo chown $USER /var/run/docker.sock
fi

echo "=================================================="

echo -e "\e[1m\e[32m5. Downloading Aptos Validator config files ... \e[0m" && sleep 1

rm -rf ~/aptos-node/testnet

sudo mkdir -p ~/aptos-node/testnet
cd ~/aptos-node/testnet

if [ -f docker-compose.yaml ]
then
    docker compose down -v
fi

sudo docker run --rm \
  -v $(pwd):/data/aptos-cli \
  jiangydev/aptos-cli:v0.1.1 \
  aptos genesis generate-keys --output-dir /data/aptos-cli

sudo wget -O docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
sudo wget -O validator.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml
sudo wget -O fullnode.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/fullnode.yaml

sudo docker run --rm \
  -v $(pwd):/data/aptos-cli \
  jiangydev/aptos-cli:v0.1.1 \
  aptos genesis set-validator-configuration \
  --keys-dir /data/aptos-cli --local-repository-dir /data/aptos-cli \
  --username $USERNAME \
  --validator-host $ADDRESS:6180 \
  --full-node-host $ADDRESS:6182

cat <<EOF > layout.yaml
---
root_key: "0x5243ca72b0766d9e9cbf2debf6153443b01a1e0e6d086c7ea206eaf6f8043956"
users:
  - $USERNAME
chain_id: 23
EOF

sudo docker run --rm \
  -v $(pwd):/data/aptos-cli \
  jiangydev/aptos-cli:v0.1.1 \
  sh -c "rm -rf /data/aptos-cli/genesis.blob && rm -rf /data/aptos-cli/waypoint.txt && rm -rf /data/aptos-cli/framework && cp -r /framework /data/aptos-cli && aptos genesis generate-genesis --local-repository-dir /data/aptos-cli --output-dir /data/aptos-cli && rm -rf /data/aptos-cli/framework"

echo "=================================================="

echo -e "\e[1m\e[32m6. Starting Aptos Validator ... \e[0m" && sleep 1

docker compose up -d

echo "=================================================="

echo -e "\e[1m\e[32m7. Aptos Validator Started \e[0m" && sleep 1

docker ps

echo "=================================================="

echo -e "\e[1m\e[32m8. Info \e[0m" && sleep 1

echo -e "\e[1m\e[32mTo update docker image: \e[0m"
echo -e "\e[1m\e[39m    docker compose pull \n \e[0m"

echo -e "\e[1m\e[32mTo view validator logs: \e[0m"
echo -e "\e[1m\e[39m    docker logs -f testnet-validator-1 --tail 100 \n \e[0m"

echo -e "\e[1m\e[32mTo view fullnode logs: \e[0m"
echo -e "\e[1m\e[39m    docker logs -f testnet-fullnode-1 --tail 100 \n \e[0m"

echo -e "\e[1m\e[32mTo stop: \e[0m"
echo -e "\e[1m\e[39m    docker compose stop \n \e[0m"

echo "=================================================="

echo -e "\e[1m\e[32m9. Aptos Incentivized Testnet \e[0m"  && sleep 1

echo -e "\e[1m\e[32mTo Connect to Aptos Incentivized Testnet: \e[0m"
echo -e "\e[1m\e[39m    docker compose down --volumes \n \e[0m"
echo -e "\e[1m\e[39m    wget -P $HOME/aptos-node/testnet <URL for genesis.blob> \n \e[0m"
echo -e "\e[1m\e[39m    wget -P $HOME/aptos-node/testnet <URL for waypoint.txt> \n \e[0m"
echo -e "\e[1m\e[39m    docker compose up -d \n \e[0m"

echo "=================================================="

echo -e "\e[1m\e[32m10. To Register your node \e[0m"  && sleep 1

echo -e "\e[1m\e[32mRegistration site \e[0m"
echo -e "\e[1m\e[39m    https://community.aptoslabs.com/ \n \e[0m"

echo -e "\e[1m\e[32mRegistration parameter \e[0m"
echo -e "\e[1m\e[39m   $(cat $HOME/aptos-node/testnet/$USERNAME.yaml) \n \e[0m"

echo "=================================================="
