# Managed Identity Storage Access Fix

## Problem
When running `az storage account list` on the VM, you get no results because the managed identity only has Storage Blob Contributor role on a specific storage account, but needs Reader permissions at the resource group level to list storage accounts.

## Immediate Fix (Manual)

Run these commands from your local machine to grant the necessary permissions:

```bash
# Get the VM's managed identity principal ID
VM_NAME="web-dockerxitk-dev-eastus"
RESOURCE_GROUP="rg-docker-dev-eastus"

PRINCIPAL_ID=$(az vm identity show --name "$VM_NAME" --resource-group "$RESOURCE_GROUP" --query principalId -o tsv)
echo "VM Managed Identity Principal ID: $PRINCIPAL_ID"

# Grant Reader role at resource group level (allows listing resources)
az role assignment create \
  --assignee "$PRINCIPAL_ID" \
  --role "Reader" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP"

echo "Reader role assigned successfully!"
```

## Testing on the VM

After applying the fix, SSH to your VM and test:

```bash
# Copy the troubleshooting script to the VM
chmod +x /path/to/troubleshoot-managed-identity.sh
./troubleshoot-managed-identity.sh

# Or test manually:
az login --identity
az storage account list
az storage account list --resource-group rg-docker-dev-eastus
```

## Long-term Fix (Bicep Template)

The bicep template has been updated to include both role assignments:

1. **Storage Blob Contributor** on the specific storage account (for data access)
2. **Reader** at the resource group level (for listing resources)

This will be applied on the next deployment.

## Expected Results After Fix

```bash
# Should now work:
az storage account list --output table

# Should show something like:
Name                      ResourceGroup           Location    Kind         AccessTier
------------------------  ----------------------  ----------  -----------  ------------
blobstoragedeveastus123   rg-docker-dev-eastus   eastus      StorageV2    Hot
```

## Security Note

The Reader role only allows read access to resource metadata and does not provide access to storage account keys or blob data. The actual data access is controlled by the Storage Blob Contributor role scoped to the specific storage account.
