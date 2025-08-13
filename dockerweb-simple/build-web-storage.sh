#!/bin/bash

# build-web-storage.sh - Storage Infrastructure Deployment
# This script deploys the storage components: blob storage account and containers

# Load shared configuration
source ./shared-config.sh

echo "=========================================="
echo "Storage Infrastructure Deployment"
echo "=========================================="

echo "Using static Bicep template: storage-main.bicep"
echo "Creating storage deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-storage-deployment \
	--template-file ./storage-main.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"backupBlobStorageAccountName=$backupBlobStorageAccountName" \
		"backupBlobContainerName=$backupBlobContainerName"

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "Storage deployment completed successfully!"
    echo "=========================================="
    
    # Save deployment outputs to a file for use by subsequent scripts
    az deployment group show \
        --resource-group $resourceGroupName \
        --name $application-storage-deployment \
        --query 'properties.outputs' \
        --output json > ./storage-outputs.json
    
    echo "Storage resource information saved to: ./storage-outputs.json"
    echo ""
    echo "Key storage resources deployed:"
    echo "- Blob Storage Account: $backupBlobStorageAccountName"
    echo "- Blob Container: $backupBlobContainerName"
    echo ""
    echo "Next steps:"
    echo "1. Ensure network infrastructure is deployed (./build-web-network.sh)"
    echo "2. Run ./build-web-docker.sh to deploy compute and application resources"
    echo "=========================================="
else
    echo "Storage deployment failed. Please check the error messages above."
    exit 1
fi
