#! /bin/bash

if test -f .setup; then
  echo "Setup already done."
else
  #  setup environment for running hardhat and solidity deploy
  echo "Preparing setup."
  echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  sudo apt-get -y update
  sudo apt install curl git
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
#  sudo apt-get install -y npm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  source ~/.bashrc
  nvm install v16
  sudo apt-get install -y gcc g++ make
  sudo apt-get -y install jq
#  foundry deps
  sudo apt-get install -y cargo
  sudo apt-get install -y rustc
  source "$HOME/.cargo/env"
  sudo apt-get install --allow libssl1.1
  rustup update stable
  npm install --global yarn
  cargo install --git https://github.com/foundry-rs/foundry --profile local --locked foundry-cli anvil
  touch .setup
fi

sudo lsof -n -i:8545 | grep LISTEN | awk '{ print $2 }' | uniq | xargs kill -9
rm -rf hardhat && mkdir hardhat
cp /home/vagrant/sync_folder/da-bridge/hardhat.config.js /home/vagrant/hardhat/ || exit 1
cd /home/vagrant/hardhat && npm install --save-dev hardhat
echo "Starting hardhat"
cd /home/vagrant/hardhat && npx hardhat node &>/home/vagrant/hardhat/hardhat_logs.txt &
echo "Copy monorepo"

#not needed if contracts are already built
#cd /home/vagrant/monorepo && yarn && yarn bootstrap

echo "Deploy contracts to hardhat"
cd /home/vagrant/sync_folder/monorepo/packages/contracts-da-bridge || exit 1
export $(grep -v '^#' /home/vagrant/sync_folder/monorepo/packages/contracts-da-bridge/.env | xargs)
forge script contracts/script/DeployDemo.s.sol --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --private-key $PRIVATE_KEY --slow

cd /home/vagrant/monorepo/broadcast/DeployDemo.s.sol/31337/ || exit 1
export HOME=$(jq '.transactions[] | select(.contractName=="Home") | .contractAddress' run-latest.json | head -n 1)
export REPLICA=$(jq '.transactions[] | select(.contractName=="Replica") | .contractAddress' run-latest.json | head -n 1)
export BRIDGE=$(jq '.transactions[] | select(.contractName=="DABridgeRouter") | .contractAddress' run-latest.json | head -n 1)
export MANAGER=$(jq '.transactions[] | select(.contractName=="XAppConnectionManager") | .contractAddress' run-latest.json | head -n 1)
echo "Deployed contract addresses"

rm -rf /home/vagrant/agents/ && mkdir -p /home/vagrant/agents
# move config
cd /home/vagrant/sync_folder/da-bridge/agents/ || exit 1
cp config_local.json .env_local /home/vagrant/agents/
cd /home/vagrant || exit 1

# Move agents
echo "Move agents"
mkdir -p /home/vagrant/agents/updater
mkdir -p /home/vagrant/agents/relayer
mkdir -p /home/vagrant/agents/processor
mkdir -p /home/vagrant/agents/watcher
echo "Cp updater"
cp -r /home/vagrant/sync_folder/da-bridge/agents/updater /home/vagrant/agents/updater/
cp -r /home/vagrant/sync_folder/da-bridge/agents/relayer /home/vagrant/agents/relayer/
cp -r /home/vagrant/sync_folder/da-bridge/agents/processor /home/vagrant/agents/processor/
cp -r /home/vagrant/sync_folder/da-bridge/agents/watcher /home/vagrant/agents/watcher/

# Update deploed contracts

jq ".core.goerli.home.proxy=$HOME" /home/vagrant/agents/config_local.json >/home/vagrant/agents/config.json && mv /home/vagrant/agents/config.json /home/vagrant/agents/config_local.json
jq ".core.goerli.replicas.avail.proxy=$REPLICA" /home/vagrant/agents/config_local.json >/home/vagrant/agents/config.json && mv /home/vagrant/agents/config.json /home/vagrant/agents/config_local.json
jq ".bridge.goerli.bridgeRouter.proxy=$BRIDGE" /home/vagrant/agents/config_local.json >/home/vagrant/agents/config.json && mv /home/vagrant/agents/config.json /home/vagrant/agents/config_local.json
jq ".core.goerli.xAppConnectionManager=$MANAGER" /home/vagrant/agents/config_local.json >/home/vagrant/agents/config.json && mv /home/vagrant/agents/config.json /home/vagrant/agents/config_local.json
# todo watcher
# Start all agents
echo "Start agents"

cd /home/vagrant/agents || exit 1
cd updater && env $(cat ../.env_local | xargs) ./updater &>./updater_logs.txt &
cd relayer && env $(cat ../.env_local | xargs) ./relayer &>./relayer_logs.txt &
cd processor && env $(cat ../.env_local | xargs) ./processor &>./processor_logs.txt &
cd watcher && env $(cat ../.env_local | xargs) ./watcher &>./watcher_logs.txt &

