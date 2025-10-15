#!/bin/bash

# cleanup.sh - Cleanup deployment artifacts
# This script removes generated files and optionally the resource group

# general azure variables (should match your deployment)
applicationName=docker
environment=dev
location=eastus
resourceGroupName=rg-$applicationName-$environment-$location

echo "=========================================="
echo "Cleanup Script"
echo "=========================================="

# Function to prompt for confirmation
confirm() {
    while true; do
        read -p "$1 [y/N]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Clean up generated files
echo "Cleaning up generated deployment files..."

files_to_remove=(
    "network-outputs.json"
    "storage-outputs.json"
    "compute-outputs.json"
    "compute/cloudInit.txt"
    "deployment-config.txt"
)

for file in "${files_to_remove[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "Removed: $file"
    fi
done

echo ""
echo "Generated files cleaned up."
echo "Note: Static Bicep templates (network-main.bicep, storage-main.bicep, compute-main.bicep) are preserved."

# Optionally remove resource group
echo ""
if confirm "Do you want to delete the Azure resource group ($resourceGroupName) and all its resources?"; then
    echo "Deleting resource group: $resourceGroupName"
    az group delete --name $resourceGroupName --yes --no-wait
    if [ $? -eq 0 ]; then
        echo "Resource group deletion initiated. This will run in the background."
        echo "You can check the status in the Azure portal."
    else
        echo "Failed to initiate resource group deletion."
    fi
else
    echo "Resource group deletion skipped."
    echo "Note: Your Azure resources are still running and incurring costs."
    echo "To delete manually: az group delete --name $resourceGroupName"
fi

echo ""
echo "=========================================="
echo "Cleanup completed!"
echo "=========================================="
