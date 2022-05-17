# How to build aptos validator
  
# 1. Run Validator Using GCP (k8s)

## 1-1. Preparation

1. Create Google Cloud Platform account (https://cloud.google.com/free)
2. Create a new project for deploying Aptos node  
   Manage resources > CREATE PROJECT
3. Enable "Compute Engine API" and "Kubernetes Engine API"  
   APIs & Services > Enabled APIs & services > Library > Search "Compute Engine API" and "Kubernetes Engine API" > ENABLE
4. Add "Service Account Admin" role  
   IAM & Admin > Service Account > PERMISSION > GRANT ACCESS > Add "Service Account Admin" Role
5. Prepare Execution environment.

- Option1 : Cloud Shell  
Recommend for Beginner

- Option2 : Client  
Install pre-requisites if needed:

   * Terraform 1.1.7: https://www.terraform.io/downloads.html
   * Kubernetes CLI: https://kubernetes.io/docs/tasks/tools/
   * Google Cloud CLI: https://cloud.google.com/sdk/docs/install-sdk


## 1-2. Configuration
Need these parameter to deploy.  
Please prepare.
```
INPUT Validator Name:  # Name of Your Validator, no space, e.g. aptosbot
INPUT Username      :  # Select a username for your node
INPUT Project ID    :  # Specify your GCP project ID
INPUT Region        :  # Specify the region
INPUT Zone          :  # Specify the zone
INPUT Bucket Name   :  # bucket name
INPUT Workspace Name:  # Specify Terraform workspace name
```

Example
```
INPUT Validator Name:  aptosbot
INPUT Username      :  qyeah
INPUT Project ID    :  aptos
INPUT Region        :  us-central1
INPUT Zone          :  c
INPUT Bucket Name   :  qyeah-aptos-terraform-dev
INPUT Workspace Name:  testnet
```

## 1-3. Deploy
```bash
wget -O aptos-validator-gke.sh https://raw.githubusercontent.com/qyeah98/aptos/main/validator/aptos-validator-gke.sh && chmod +x aptos-validator-gke.sh && ./aptos-validator-gke.sh
```

and then input your node info prepared at 1-2. Configuration

```bash
Ex.
INPUT Validator Name:  aptosbot
INPUT Username      :  qyeah
INPUT Project ID    :  aptos
INPUT Region        :  us-central1
INPUT Zone          :  c
INPUT Bucket Name   :  qyeah-aptos-terraform-dev
INPUT Workspace Name:  testnet
```

Finally, Validator node info will be displayed.

```bash
Ex.
account_address: 69f9***************************************************64ade
consensus_key: "0x87***************************************************9059"
account_key: "0x87***************************************************beb2"
validator_network_key: "0x76***************************************************af2f"
validator_host:
  host: 35.187.222.22
  port: 6180
full_node_network_key: "0xb2***************************************************7856"
full_node_host:
  host: 35.221.79.15
  port: 6182
stake_amount: 1
```


## 1-4. Reference
* Aptos developer tutorial  
https://aptos.dev/tutorials/validator-node/connect-to-testnet/


# 2. Run Validator Using Docker
  
## 2-1. Requirements
Refering to formal aptos site.  
https://aptos.dev/tutorials/validator-node/intro  


### 2-1-1. Hardware requirements
  
For running an aptos node on incentivized testnet we recommend the following:  

* CPU: 4 cores (Intel Xeon Skylake or newer)
* Memory: 8GiB RAM
  

### 2-1-2. Storage requirements  
The amount of data stored by Aptos depends on the ledger history (length) of the blockchain and the number of on-chain states (e.g., accounts).  
These values depend on several factors, including: the age of the blockchain, the average transaction rate and the configuration of the ledger pruner.  

We recommend nodes have at least 300GB of disk space to ensure adequate storage space for load testing.  
You have the option to start with a smaller size and adjust based upon demands.  
You will be responsible for monitoring your node's disk usage and adjusting appropriately to ensure node uptime.  
  
### 2-1-3. Networking configuration requirements
For Validator node:  
* Open TCP port 6180, for validators to talk to each other.
* Open TCP port 9101, for getting validator metrics to validate the health stats. (only needed during registration stage)

For Fullnode:
* Open TCP port 6182, for fullnodes to talk to each other.
* Open TCP port 9101, for getting fullnode metrics to validate the health stats. (only needed during registration stage)
* Open TCP port 80/8080, for REST API access.


## 2-2. Installation using docker
```bash
sudo su -
cd &HOME

wget -O aptos-validator.sh https://raw.githubusercontent.com/qyeah98/aptos/main/validator/aptos-validator.sh && chmod +x aptos-validator.sh && ./aptos-validator.sh
```

and then input your node info

```bash
INPUT Your IP/DNS : ******
INPUT Username: ******

Ex.
INPUT Your IP/DNS : 13.114.220.201
INPUT Username: aptos-testnet-qyeah
```

Finally, Validator node info will be displayed.

```bash
Ex.
account_address: 69f9***************************************************64ade
consensus_key: "0x87***************************************************9059"
account_key: "0x87***************************************************beb2"
validator_network_key: "0x76***************************************************af2f"
validator_host:
  host: 35.187.222.22
  port: 6180
full_node_network_key: "0xb2***************************************************7856"
full_node_host:
  host: 35.187.222.22
  port: 6182
stake_amount: 1
```

To check your node is fine, you should use these node monitor.  
https://node.aptos.zvalid.com/  
https://www.nodex.run/  
  

# 3. Registor your node
https://community.aptoslabs.com/  

[Reference]  
https://medium.com/aptoslabs/launch-of-aptos-incentivized-testnet-registration-2e85696a62d0

