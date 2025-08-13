#!/bin/bash

# shared-config.sh - Shared configuration for all deployment scripts
# Source this file in each deployment script to ensure consistent naming

# Check if application suffix already exists (from previous deployment)
if [ -f "./deployment-config.txt" ]; then
    echo "Reading existing deployment configuration..."
    source ./deployment-config.txt
else
    echo "Creating new deployment configuration..."
    # Generate a new random suffix for this deployment
    applicationSuffix=$(cat /dev/urandom | tr -cd 'a-z0-9' | head -c 4)
    
    # Save configuration for reuse
    cat > ./deployment-config.txt << EOF
# Deployment Configuration - Generated $(date)
# This file ensures consistent naming across all deployment scripts
applicationSuffix=$applicationSuffix
EOF
fi

# General Azure variables
subscription=null
location=eastus
applicationName=docker
application=${applicationName}${applicationSuffix}
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$applicationName-$environment-$location

# Network variables
vnetCIDRPrefix=10.10
adminSourceIP=`wget -O - v4.ident.me 2>/dev/null`

# Key vault variables
kvResourceGroup=rg-keyvault-prod-eastus2
kvName=kv-keyvault-prod-eastus2

# Linux VM variables
adminUsername=azureuser

# Storage variables
backupBlobStorageAccountName="bkup$application"
backupBlobContainerName="backup"

echo "=== Shared Configuration ==="
echo "Application Suffix: $applicationSuffix"
echo "Application Name: $application"
echo "Resource Group: $resourceGroupName"
echo "Storage Account: $backupBlobStorageAccountName"
echo "============================"
