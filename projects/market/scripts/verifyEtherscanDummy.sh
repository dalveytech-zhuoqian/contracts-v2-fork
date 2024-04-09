#!/bin/bash

# Check if network argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <network>"
    exit 1
fi

# Set the network variable
network="$1"

# Run the commands using the network input argument
cd ../diamond-etherscan && yarn run generate-dummy-from-abi ../market/deployments/"$network"/MarketDiamond.json && cp ./contracts/dummy/DummyDiamondImplementation.sol ../market/src/dummy/DummyDiamondImplementation.sol && cd ../market && yarn deploy "$network" && yarn verify "$network"
