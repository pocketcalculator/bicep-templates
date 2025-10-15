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
applicationName=remix
application=${applicationName}${applicationSuffix}
environment=dev
owner=markese.bryant@shiftdatmix.org
resourceGroupName=rg-$applicationName-$environment

# Network variables
vnetCIDRPrefix=10.10
adminSourceIP=`wget -O - v4.ident.me 2>/dev/null`

# VM Admin Password (for non-production use)
# For production, use Key Vault or SSH keys only
adminPassword='YourSecureP@ssw0rd123!'

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
