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

echo -e "\e[1m\e[32m1. Set Validator Parameter \e[0m" && sleep 1

echo -e "\e[1m\e[32m1.1 Set Validator Name \e[0m"
read -p "INPUT Validator Name: " VALIDATOR_NAME

echo "=================================================="

echo -e "\e[1m\e[32m1.2 Set USERNAME \e[0m"
read -p "INPUT Username: " USERNAME

echo "=================================================="

echo -e "\e[1m\e[32m1.3 Set Project ID \e[0m"
read -p "INPUT Project ID: " PROJECT_ID

echo "=================================================="
echo -e "\e[1m\e[32m1.4 Set Google Cloud Region \e[0m"
read -p "INPUT Region: " REGION

echo "=================================================="
echo -e "\e[1m\e[32m1.5 Set Google Cloud Zone \e[0m"
read -p "INPUT Zone: " ZONE

echo "=================================================="
echo -e "\e[1m\e[32m1.6 Set Google Cloud Storage \e[0m"
read -p "INPUT Bucket Name: " BUCKET

echo "=================================================="

echo -e "\e[1m\e[32m1.7 Set Workspace Name \e[0m"
read -p "INPUT Workspace Name: " WORKSPACE

echo "=================================================="

echo -e "\e[1m\e[32m2. Updating list of dependencies... \e[0m" && sleep 1

echo -e "\e[1m\e[32m2.1 Set project $PROJECT_ID \e[0m"
gcloud config set project $PROJECT_ID

if ! which cargo &> /dev/null
then
    echo -e "\e[1m\e[32m2.2 Installing rust... \e[0m"
    apt-get update
    curl https://sh.rustup.rs -sSf | sh
    source $HOME/.cargo/bin
fi

if ! which aptos &> /dev/null
then
    echo -e "\e[1m\e[32m2.3 Installing aptos cli... \e[0m"
    apt install clang
    cargo install --git https://github.com/aptos-labs/aptos-core.git aptos --tag aptos-cli-latest
fi

echo "=================================================="

echo -e "\e[1m\e[32m3. Creating Terraform configuration... \e[0m" && sleep 1

echo -e "\e[1m\e[32m3.1 Creating Workspace... \e[0m" && sleep 1

rm -rf ~/$WORKSPACE
mkdir -p ~/$WORKSPACE

echo -e "\e[1m\e[32m3.2 Creating Google Cloud Storage... \e[0m" && sleep 1

gsutil mb gs://$BUCKET

echo -e "\e[1m\e[32m3.2 Creating Terafform main.tf... \e[0m" && sleep 1

cd ~/$WORKSPACE

cat <<EOF > main.tf
terraform {
  required_version = "~> 1.1.0"
  backend "gcs" {
    bucket = $BUCKET
    prefix = "state/aptos-node"
  }
}

module "aptos-node" {
  source        = "github.com/aptos-labs/aptos-core.git//terraform/aptos-node/gcp?ref=testnet"
  region        = "$REGION"
  zone          = "$ZONE"
  project       = "$PROJECT_ID"
  era           = 1
  chain_id      = 23
  image_tag     = "testnet"
  validator_name = "$VALIDATOR_NAME"
}
EOF

echo "=================================================="

echo -e "\e[1m\e[32m4. Terraform init and apply... \e[0m" && sleep 1

terraform init

terraform workspace new $WORKSPACE
terraform apply

echo "=================================================="

echo -e "\e[1m\e[32m5. Getting address... \e[0m" && sleep 1

gcloud container clusters get-credentials aptos-$WORKSPACE --zone=$REGION-$ZONE --project=$PROJECT_ID

export VALIDATOR_ADDRESS="$(kubectl get svc ${WORKSPACE}-aptos-node-validator-lb --output jsonpath='{.status.loadBalancer.ingress[0].ip}')"
export FULLNODE_ADDRESS="$(kubectl get svc ${WORKSPACE}-aptos-node-fullnode-lb --output jsonpath='{.status.loadBalancer.ingress[0].ip}')"

echo "=================================================="

echo -e "\e[1m\e[32m6. Creating Aptos Validator config files... \e[0m" && sleep 1

echo -e "\e[1m\e[32m6.1 Generate key pairs... \e[0m" && sleep 1

aptos genesis generate-keys --output-dir ~/$WORKSPACE

echo -e "\e[1m\e[32m6.2 Generate validator/fullnode config file... \e[0m" && sleep 1

aptos genesis set-validator-configuration --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE --username $USERNAME --validator-host $VALIDATOR_ADDRESS:6180 --full-node-host $FULLNODE_ADDRESS:6182

echo -e "\e[1m\e[32m6.3 Creating YAML file... \e[0m" && sleep 1

cat <<EOF > layout.yaml
---
root_key: "0x5243ca72b0766d9e9cbf2debf6153443b01a1e0e6d086c7ea206eaf6f8043956"
users:
  - $USERNAME
chain_id: 23
EOF

echo -e "\e[1m\e[32m6.4 Downloading AptosFramework Move bytecode... \e[0m" && sleep 1
wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip
unzip framework.zip

echo -e "\e[1m\e[32m6.5 Compiling genesis blob and waypoint.... \e[0m" && sleep 1
aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE

echo "=================================================="

echo -e "\e[1m\e[32m7. Inserting genesis.blob, waypoint.txt and identity files... \e[0m" && sleep 1
kubectl create secret generic ${WORKSPACE}-aptos-node-genesis-e1 \
    --from-file=genesis.blob=genesis.blob \
    --from-file=waypoint.txt=waypoint.txt \
    --from-file=validator-identity.yaml=validator-identity.yaml \
    --from-file=validator-full-node-identity.yaml=validator-full-node-identity.yaml

echo "=================================================="

echo -e "\e[1m\e[32m8. Aptos Validator Info \e[0m" && sleep 1
echo -e "\e[1m\e[39m"    $(cat ~/$WORKSPACE/$USERNAME.yaml)" \n \e[0m"

echo "=================================================="

echo -e "\e[1m\e[32Just wait... " && sleep 30

echo -e "\e[1m\e[32m8. Aptos Validator Started \e[0m" && sleep 1
kubectl get pods

echo "=================================================="

