#!/bin/bash

# StarVault Deployment Script
# This script helps deploy the StarVault smart contract to Stellar testnet

set -e

echo "🚀 StarVault Deployment Script"
echo "================================"

# Check if stellar CLI is installed
if ! command -v stellar &> /dev/null; then
    echo "❌ Stellar CLI not found. Please install it first:"
    echo "cargo install --locked stellar-cli --features opt"
    exit 1
fi

echo "✅ Stellar CLI found"

# Build the contract
echo ""
echo "📦 Building contract..."
cd contracts/vault
stellar contract build

if [ $? -eq 0 ]; then
    echo "✅ Contract built successfully"
else
    echo "❌ Contract build failed"
    exit 1
fi

# Check if identity exists
echo ""
echo "🔑 Checking for deployer identity..."
if ! stellar keys list | grep -q "deployer"; then
    echo "Creating new deployer identity..."
    stellar keys generate deployer --network testnet
    echo "✅ Deployer identity created"
    echo "⚠️  Please fund this account before deploying:"
    stellar keys address deployer
    echo "Get testnet XLM from: https://laboratory.stellar.org/#account-creator?network=test"
    read -p "Press enter when account is funded..."
else
    echo "✅ Deployer identity found"
fi

# Deploy the contract
echo ""
echo "🚀 Deploying contract to testnet..."
CONTRACT_ID=$(stellar contract deploy \
    --wasm target/wasm32-unknown-unknown/release/vault_contract.wasm \
    --source deployer \
    --network testnet)

if [ $? -eq 0 ]; then
    echo "✅ Contract deployed successfully!"
    echo ""
    echo "📋 Contract ID: $CONTRACT_ID"
    echo ""
    echo "Save this contract ID to your frontend/.env file:"
    echo "VITE_VAULT_CONTRACT_ID=$CONTRACT_ID"
    echo ""

    # Optionally initialize the contract
    read -p "Do you want to initialize the contract now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ADMIN_ADDRESS=$(stellar keys address deployer)
        echo "Initializing contract with:"
        echo "  Admin: $ADMIN_ADDRESS"
        echo "  Token: CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC (Native XLM)"
        echo "  APY: 500 (5%)"

        stellar contract invoke \
            --id "$CONTRACT_ID" \
            --source deployer \
            --network testnet \
            -- \
            initialize \
            --admin "$ADMIN_ADDRESS" \
            --token CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC \
            --apy 500

        echo "✅ Contract initialized!"
    fi
else
    echo "❌ Contract deployment failed"
    exit 1
fi

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Update frontend/.env with the contract ID above"
echo "2. cd frontend && npm install"
echo "3. npm run dev"
echo ""
