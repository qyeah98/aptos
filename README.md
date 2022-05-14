# aptos


# How to build aptos validator
## Requirements
Refering to formal aptos site.
https://aptos.dev/tutorials/validator-node/intro


### Hardware requirements

For running an aptos node on incentivized testnet we recommend the following:

CPU: 4 cores (Intel Xeon Skylake or newer).
Memory: 8GiB RAM.


### Storage requirements
The amount of data stored by Aptos depends on the ledger history (length) of the blockchain and the number of on-chain states (e.g., accounts). These values depend on several factors, including: the age of the blockchain, the average transaction rate and the configuration of the ledger pruner.

We recommend nodes have at least 300GB of disk space to ensure adequate storage space for load testing. You have the option to start with a smaller size and adjust based upon demands. You will be responsible for monitoring your node's disk usage and adjusting appropriately to ensure node uptime.


### Networking configuration requirements
For Validator node:

Open TCP port 6180, for validators to talk to each other.
Open TCP port 9101, for getting validator metrics to validate the health stats. (only needed during registration stage)
For Fullnode:

Open TCP port 6182, for fullnodes to talk to each other.
Open TCP port 9101, for getting fullnode metrics to validate the health stats. (only needed during registration stage)
Open TCP port 80/8080, for REST API access.


## Installation using docker
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

To check your node is fine, you should use these node monitor.
https://www.nodex.run/


## Registor your node
https://community.aptoslabs.com/

Reference
https://medium.com/aptoslabs/launch-of-aptos-incentivized-testnet-registration-2e85696a62d0

