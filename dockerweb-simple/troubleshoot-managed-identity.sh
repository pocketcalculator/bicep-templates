#!/bin/bash

echo "=== Managed Identity Troubleshooting Script ==="
echo "Date: $(date)"
echo ""

echo "1. Testing Managed Identity Token Acquisition..."
TOKEN=$(curl -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/" -s)
if echo "$TOKEN" | jq -r .access_token > /dev/null 2>&1; then
    echo "✓ Successfully obtained management API access token"
else
    echo "✗ Failed to obtain management API access token"
    echo "Response: $TOKEN"
fi

echo ""
echo "2. Testing Storage API Token..."
STORAGE_TOKEN=$(curl -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/" -s)
if echo "$STORAGE_TOKEN" | jq -r .access_token > /dev/null 2>&1; then
    echo "✓ Successfully obtained storage API access token"
else
    echo "✗ Failed to obtain storage API access token"
    echo "Response: $STORAGE_TOKEN"
fi

echo ""
echo "3. Testing Azure CLI Login with Managed Identity..."
az login --identity
LOGIN_STATUS=$?
if [ $LOGIN_STATUS -eq 0 ]; then
    echo "✓ Azure CLI login with managed identity successful"
else
    echo "✗ Azure CLI login failed with exit code: $LOGIN_STATUS"
fi

echo ""
echo "4. Getting Current Identity Information..."
PRINCIPAL_ID=$(curl -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/" -s | jq -r .client_id)
echo "Principal ID: $PRINCIPAL_ID"

echo ""
echo "5. Testing Storage Account Access..."
echo "Attempting: az storage account list"
az storage account list --output table
STORAGE_LIST_STATUS=$?
echo "Exit code: $STORAGE_LIST_STATUS"

echo ""
echo "6. Testing Role Assignments..."
echo "Checking role assignments for this identity..."
az role assignment list --assignee "$PRINCIPAL_ID" --output table 2>/dev/null || echo "Unable to list role assignments (may need Reader permission)"

echo ""
echo "7. Testing Resource Group Access..."
RESOURCE_GROUP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2021-02-01" -s | jq -r .compute.resourceGroupName)
echo "Resource Group: $RESOURCE_GROUP"
echo "Attempting: az group show --name $RESOURCE_GROUP"
az group show --name "$RESOURCE_GROUP" --output table
GROUP_ACCESS_STATUS=$?
echo "Exit code: $GROUP_ACCESS_STATUS"

echo ""
echo "8. Testing Specific Storage Account Access..."
echo "Testing access to configured storage account..."
# This should work since we have Storage Blob Contributor on the specific account
az storage account show --name "blobstoragedeveastus123" --resource-group "$RESOURCE_GROUP" --output table 2>/dev/null || echo "Cannot access specific storage account"

echo ""
echo "=== Troubleshooting Summary ==="
echo "- If storage account list fails but other tests pass: Need Reader role at subscription/RG level"
echo "- If all tests fail: Managed identity not properly configured"
echo "- If token acquisition fails: VM may not have managed identity enabled"
echo ""
echo "Recommended fixes:"
echo "1. Add Reader role at resource group level for listing resources"
echo "2. Keep Storage Blob Contributor for actual storage operations"
