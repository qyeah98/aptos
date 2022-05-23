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

sleep 1

echo -e "\e[1m\e[32m1. Set Aptos validator info \e[0m" && sleep 1

echo -e "\e[1m\e[32m1.1 Set genesis.blob URL \e[0m" && sleep 1
while :
do
  read -p "INPUT URL: " GENESISURL
  if [ -n "$GENESISURL" ]; then
    break
  fi
done

echo "=================================================="

echo -e "\e[1m\e[32m1.2 Set waypoint.txt URL \e[0m" && sleep 1
while :
do
  read -p "INPUT URL: " WAYPOINTURL
  if [ -n "$WAYPOINTURL" ]; then
    break
  fi
done

echo "=================================================="

echo -e "\e[1m\e[32m2. Stopping your node and removing the data volumes ... \e[0m" && sleep 1

cd ~/aptos-node/testnet
docker compose down --volumes

echo "=================================================="

echo -e "\e[1m\e[32m3. Downloading Aptos Validator config files ... \e[0m" && sleep 1
wget -P ~/aptos-node/testnet $GENESISURL
wget -P ~/aptos-node/testnet $WAYPOINTURL

echo "=================================================="

echo -e "\e[1m\e[32m4. Starting Aptos Validator ... \e[0m" && sleep 1

docker compose up -d

echo "=================================================="

echo -e "\e[1m\e[32m5. Aptos Validator Started \e[0m" && sleep 1

docker ps

echo "=================================================="

echo -e "\e[1m\e[32m6. Info \e[0m" && sleep 1

echo -e "\e[1m\e[32mTo update docker image: \e[0m"
echo -e "\e[1m\e[39m    docker compose pull \n \e[0m"

echo -e "\e[1m\e[32mTo view validator logs: \e[0m"
echo -e "\e[1m\e[39m    docker logs -f testnet-validator-1 --tail 100 \n \e[0m"

echo -e "\e[1m\e[32mTo view fullnode logs: \e[0m"
echo -e "\e[1m\e[39m    docker logs -f testnet-fullnode-1 --tail 100 \n \e[0m"

echo -e "\e[1m\e[32mTo stop: \e[0m"
echo -e "\e[1m\e[39m    docker compose stop \n \e[0m"

echo "=================================================="