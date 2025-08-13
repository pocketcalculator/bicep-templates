#!/bin/bash

# build-web-network.sh - Network Infrastructure Deployment
# This script deploys the network foundation: VNet, subnets, and network security groups

# Load shared configuration
source ./shared-config.sh

echo "=========================================="
echo "Network Infrastructure Deployment"
echo "=========================================="

echo "Using static Bicep template: network-main.bicep"
echo "Creating network deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-network-deployment \
	--template-file ./network-main.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"adminSourceIP=$adminSourceIP" \
		"vnetCIDRPrefix=$vnetCIDRPrefix"

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "Network deployment completed successfully!"
    echo "=========================================="
    
    # Save deployment outputs to a file for use by subsequent scripts
    az deployment group show \
        --resource-group $resourceGroupName \
        --name $application-network-deployment \
        --query 'properties.outputs' \
        --output json > ./network-outputs.json
    
    echo "Network resource information saved to: ./network-outputs.json"
    echo ""
    echo "Key network resources deployed:"
    echo "- Virtual Network with 5 subnets (Gateway, Bastion, Frontend, Application, Database)"
    echo "- Network Security Groups for each subnet"
    echo ""
    echo "Next steps:"
    echo "1. Run ./build-web-storage.sh to deploy storage infrastructure"
    echo "2. Run ./build-web-docker.sh to deploy compute and application resources"
    echo "=========================================="
else
    echo "Network deployment failed. Please check the error messages above."
    exit 1
fi
