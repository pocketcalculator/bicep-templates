#!/bin/bash

# build-web-docker.sh - Compute and Application Deployment
# This script deploys the compute resources: VM, monitoring, and related application infrastructure

# Load shared configuration
source ./shared-config.sh

echo "=========================================="
echo "Compute and Application Deployment"
echo "=========================================="

# Check if network outputs exist
if [ ! -f "./network-outputs.json" ]; then
    echo "Error: network-outputs.json not found. Please run ./build-web-network.sh first."
    exit 1
fi

# Check if storage outputs exist
if [ ! -f "./storage-outputs.json" ]; then
    echo "Error: storage-outputs.json not found. Please run ./build-web-storage.sh first."
    exit 1
fi

# Extract network resource IDs from network deployment outputs
applicationSubnetId=$(jq -r '.applicationSubnetId.value' ./network-outputs.json)
echo "Using Application Subnet ID: $applicationSubnetId"
echo "Using Storage Account: $backupBlobStorageAccountName"

# Generate cloud-init configuration
cat << EOF > ./compute/cloudInit.txt
#cloud-config
package_upgrade: true
packages:
  - binutils
  - curl
  - sysstat
  - collectd
  - collectd-utils
  - openssl
  - nfs-common
  - net-tools
  - certbot
  - python3
  - python-is-python3
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release

runcmd:
  # Docker installation steps
  - cd /tmp; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  - echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt update
  - apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  - curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
  - chmod +x /usr/local/bin/docker-compose
  - systemctl start docker
  - systemctl enable docker
  - usermod -aG docker $adminUsername
  # Install AzCopy - Updated method
  - cd /tmp
  - curl -sL -o downloadazcopy-v10-linux.tar.gz https://aka.ms/downloadazcopy-v10-linux
  - tar -xvf downloadazcopy-v10-linux.tar.gz --strip-components=1
  - cp ./azcopy /usr/bin/
  - chmod 755 /usr/bin/azcopy
  # Azure CLI installation for Ubuntu 24.04
  - curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
  - echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ \$(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list
  - apt update
  - apt install -y azure-cli
EOF

echo "Using static Bicep template: compute-main.bicep"
echo "Creating compute deployment for ${environment} ${application} environment..."
echo "Note: Using Key Vault in same subscription: $keyVaultName"
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-compute-deployment \
	--template-file ./compute-main.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"kvResourceGroup=$kvResourceGroup" \
		"kvName=$keyVaultName" \
		"adminUsername=$adminUsername" \
		"blobStorageAccountName=$backupBlobStorageAccountName" \
		"applicationSubnetId=$applicationSubnetId"

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "Compute deployment completed successfully!"
    echo "=========================================="
    
    # Save deployment outputs
    az deployment group show \
        --resource-group $resourceGroupName \
        --name $application-compute-deployment \
        --query 'properties.outputs' \
        --output json > ./compute-outputs.json
    
    echo "Compute resource information saved to: ./compute-outputs.json"
    
    # Get the public IP address from the deployment outputs
    echo "Retrieving public IP address..."
    
    # First get the public IP resource ID from deployment outputs
    publicIPResourceId=$(az deployment group show \
        --resource-group $resourceGroupName \
        --name $application-compute-deployment \
        --query 'properties.outputs.webServerPublicIPResourceId.value' \
        --output tsv)
    
    # Then get the actual IP address from the public IP resource
    if [ ! -z "$publicIPResourceId" ] && [ "$publicIPResourceId" != "null" ]; then
        publicIP=$(az network public-ip show \
            --ids $publicIPResourceId \
            --query 'ipAddress' \
            --output tsv)
        
        fqdn=$(az deployment group show \
            --resource-group $resourceGroupName \
            --name $application-compute-deployment \
            --query 'properties.outputs.webServerFQDN.value' \
            --output tsv)
    else
        publicIP=""
        fqdn=""
    fi
    
    # Display the public IP address
    if [ ! -z "$publicIP" ] && [ "$publicIP" != "null" ]; then
        echo ""
        echo "=========================================="
        echo "VM Public IP Address: $publicIP"
        if [ ! -z "$fqdn" ] && [ "$fqdn" != "null" ]; then
            echo "VM FQDN: $fqdn"
        fi
        echo "=========================================="
        echo ""
        echo "You can SSH to the VM using:"
        echo "ssh -i ~/.ssh/$adminUsername $adminUsername@$publicIP"
        if [ ! -z "$fqdn" ] && [ "$fqdn" != "null" ]; then
            echo "Or using FQDN:"
            echo "ssh -i ~/.ssh/$adminUsername $adminUsername@$fqdn"
        fi
        echo ""
        echo "Key compute resources deployed:"
        echo "- Docker-enabled VM with monitoring"
        echo "- Log Analytics Workspace"
        echo "- VM Data Collection Rule"
        echo "- Public IP and FQDN for external access"
        echo ""
    else
        echo "Warning: Could not retrieve public IP address from deployment."
        echo "The VM may still be starting up. You can check the public IP in the Azure portal."
        echo "Resource Group: $resourceGroupName"
    fi
    
    echo "=========================================="
    echo "All deployments completed successfully!"
    echo "=========================================="
else
    echo "Compute deployment failed. Please check the error messages above."
    exit 1
fi
