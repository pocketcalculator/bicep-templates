#!/bin/bash

# build-mongodbvm.sh - Compute and Application Deployment
# This script deploys the compute resources: VM, monitoring, and related application infrastructure

# Load shared configuration
source ./shared-config.sh

echo "=========================================="
echo "Compute and Application Deployment"
echo "=========================================="

# Check if network outputs exist
if [ ! -f "./network-outputs.json" ]; then
    echo "Error: network-outputs.json not found. Please run ./build-network.sh first."
    exit 1
fi

# Check if storage outputs exist
if [ ! -f "./storage-outputs.json" ]; then
    echo "Error: storage-outputs.json not found. Please run ./build-storage.sh first."
    exit 1
fi

# Extract network resource IDs from network deployment outputs
databaseSubnetId=$(jq -r '.databaseSubnetId.value' ./network-outputs.json)
echo "Using Database Subnet ID: $databaseSubnetId"
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
  # MongoDB installation for Ubuntu 24.04
  - curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
  - echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
  - apt update
  - apt install -y mongodb-org
  # Configure MongoDB for remote access (bind to all interfaces)
  - sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
  # Enable MongoDB service
  - systemctl start mongod
  - systemctl enable mongod
  # Install MongoDB Shell (mongosh) and Database Tools
  - wget -qO- https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor | tee /usr/share/keyrings/mongodb-archive-keyring.gpg > /dev/null
  - apt install -y mongodb-mongosh mongodb-database-tools
EOF

echo "Using static Bicep template: compute-main.bicep"
echo "Creating compute deployment for ${environment} ${application} environment..."

az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-compute-deployment \
	--template-file ./compute-main.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
        "adminUsername=$adminUsername" \
        "adminPassword=$adminPassword" \
		"blobStorageAccountName=$backupBlobStorageAccountName" \
		"databaseSubnetId=$databaseSubnetId"

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
        --query 'properties.outputs.mongodbServerPublicIPResourceId.value' \
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
            --query 'properties.outputs.mongodbServerFQDN.value' \
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
        echo "- MongoDB 8.0 Community Edition"
        echo "- MongoDB Shell (mongosh) and Database Tools"
        echo "- Log Analytics Workspace"
        echo "- VM Data Collection Rule"
        echo "- Public IP and FQDN for external access"
        echo ""
        echo "MongoDB Connection:"
        echo "- Default port: 27017"
        echo "- Connection string: mongodb://$publicIP:27017"
        echo "- Note: Configure authentication before production use"
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
