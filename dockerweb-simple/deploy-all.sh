#!/bin/bash

# deploy-all.sh - Master deployment script
# This script runs all three deployment scripts in the correct order

echo "=========================================="
echo "Master Deployment Script"
echo "Deploying complete dockerweb infrastructure"
echo "=========================================="

# Set script permissions
chmod +x ./build-web-network.sh
chmod +x ./build-web-storage.sh
chmod +x ./build-web-docker.sh

echo "Step 1/3: Deploying Network Infrastructure..."
echo "=========================================="
./build-web-network.sh
if [ $? -ne 0 ]; then
    echo "Network deployment failed. Stopping deployment."
    exit 1
fi

echo ""
echo "Step 2/3: Deploying Storage Infrastructure..."
echo "=========================================="
./build-web-storage.sh
if [ $? -ne 0 ]; then
    echo "Storage deployment failed. Stopping deployment."
    exit 1
fi

echo ""
echo "Step 3/3: Deploying Compute Infrastructure..."
echo "=========================================="
./build-web-docker.sh
if [ $? -ne 0 ]; then
    echo "Compute deployment failed. Stopping deployment."
    exit 1
fi

echo ""
echo "=========================================="
echo "🎉 Complete deployment finished successfully!"
echo "=========================================="
echo ""
echo "Deployment artifacts created:"
echo "- network-outputs.json (network resource IDs)"
echo "- storage-outputs.json (storage resource information)"  
echo "- compute-outputs.json (compute resource information)"
echo ""
echo "Static Bicep templates used:"
echo "- network-main.bicep (network infrastructure)"
echo "- storage-main.bicep (storage infrastructure)"
echo "- compute-main.bicep (compute infrastructure)"
echo ""
echo "Your dockerweb infrastructure is now ready to use!"
echo "=========================================="
