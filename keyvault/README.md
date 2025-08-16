# General Purpose Key Vault Deployment

This directory contains the Bicep template and deployment scripts for creating a general-purpose Azure Key Vault for subscription-wide use.

## Files

- `keyvault.bicep` - Main Bicep template for general-purpose Key Vault deployment
- `deploy-keyvault.sh` - Comprehensive bash deployment script
- `parameters.json` - Sample parameters file
- `README.md` - This file

## Key Features

This Key Vault is designed for general use within your Azure subscription and can store:

- **Application Secrets** - Database connection strings, API keys, etc.
- **Certificates** - SSL/TLS certificates for applications
- **SSH Keys** - Private keys for server access
- **Service Principal Secrets** - Authentication credentials for applications
- **Encryption Keys** - Customer-managed encryption keys
- **Configuration Values** - Sensitive configuration parameters

## Quick Start

### Prerequisites

1. Azure CLI installed and logged in (`az login`)
2. Appropriate permissions to create Key Vault and assign RBAC roles
3. Bash shell (Linux/macOS/WSL)

### Basic Deployment

```bash
# Deploy with minimal parameters
./deploy-keyvault.sh -g my-resource-group -l eastus

# Deploy with a secret file
./deploy-keyvault.sh -g my-resource-group -l eastus -f /path/to/secret.txt

# Deploy with parameter file
./deploy-keyvault.sh -g my-resource-group -p parameters.json

# Create resource group and deploy
./deploy-keyvault.sh -g my-new-rg -l eastus -c
```

### Advanced Options

```bash
# Dry run (validation only)
./deploy-keyvault.sh -g my-rg -d

# Verbose output
./deploy-keyvault.sh -g my-rg -v

# Skip what-if analysis
./deploy-keyvault.sh -g my-rg -w

# Custom deployment name
./deploy-keyvault.sh -g my-rg -n my-keyvault-deployment

# Specify subscription
./deploy-keyvault.sh -g my-rg -s "12345678-1234-1234-1234-123456789012"
```

## Deployment Script Features

The `deploy-keyvault.sh` script provides:

- **Comprehensive Error Handling**: Proper error checking and cleanup
- **Parameter Validation**: Validates all inputs before deployment
- **What-If Analysis**: Shows what resources will be created/modified
- **Secret File Integration**: Automatically adds secrets from files to vault
- **RBAC Setup**: Configures appropriate permissions for current user
- **Resource Group Management**: Can create resource groups if needed
- **Flexible Configuration**: Supports parameter files and command-line options
- **Verbose Logging**: Detailed output with timestamps and colored messages
- **Dry Run Support**: Validation-only mode for testing
- **Template Deployment Support**: Enables ARM/Bicep template access by default

## Template Parameters

Key parameters you can customize:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `keyVaultName` | Name of the Key Vault | Auto-generated |
| `location` | Azure region | Resource group location |
| `skuName` | SKU (standard/premium) | standard |
| `publicNetworkAccess` | Enable public access | Disabled |
| `principalId` | User/SP object ID for RBAC | Current user |
| `createPrivateEndpoint` | Create private endpoint | false |
| `enableDiagnostics` | Enable diagnostic logging | true |
| `enabledForTemplateDeployment` | Allow ARM template access | true |
| `enabledForDiskEncryption` | Allow VM disk encryption | false |
| `enabledForDeployment` | Allow VM deployment access | false |
| `createSampleSecrets` | Create sample secrets | false |

## Security Best Practices Implemented

1. **Standard SKU** - Cost-effective with essential security features
2. **RBAC Authorization** - Azure AD-based access control
3. **Soft Delete & Purge Protection** - Data protection and recovery
4. **Network Isolation** - Public access disabled by default (can be enabled for dev)
5. **Diagnostic Logging** - Full audit trail
6. **Proper Tagging** - Resource management and governance
7. **Secure Parameter Handling** - Sensitive values protected
8. **Template Integration** - ARM/Bicep deployment support enabled

## Usage Examples

### Development Environment

```bash
# Dev environment with public access enabled
./deploy-keyvault.sh -g dev-rg -e dev -l eastus
```

### Production Environment

```bash
# Production with private endpoint
./deploy-keyvault.sh -g prod-rg -e prod -p parameters.json
```

### With Secret File

```bash
# Deploy and store a secret from file
./deploy-keyvault.sh -g my-rg -f /path/to/database-connection-string.txt
```

## Troubleshooting

### Common Issues

1. **Authentication Error**: Run `az login` to authenticate
2. **Permission Denied**: Ensure you have Contributor role on subscription/RG
3. **Resource Group Not Found**: Use `-c` flag to create RG automatically
4. **SSH Key Not Found**: Verify the path to your SSH private key file

### Debug Mode

Use `-v` flag for verbose output to see detailed deployment information:

```bash
./deploy-keyvault.sh -g my-rg -v
```

### Validation Only

Test your configuration without deploying:

```bash
./deploy-keyvault.sh -g my-rg -d
```

## Cost Optimization

This template is configured for cost-effectiveness:

- **Standard SKU**: $0.30/month base cost (vs $1.00 for Premium)
- **No Private Endpoint**: Saves ~$7.30/month
- **Public Network Access**: Disabled by default for security, can be enabled for dev environments
- **Pay-per-use**: Only pay for actual secret/key operations ($0.03 per 10,000 transactions)

**Estimated Monthly Cost**: $0.50-$2.00 for typical usage

### When to Consider Premium SKU:
- Need Hardware Security Module (HSM) protected keys
- Require advanced threat protection
- Enterprise compliance requirements
- High-value cryptographic operations

## Post-Deployment

After successful deployment, the script will output:

- Key Vault name and URI
- Sample secret details (if created)
- Private endpoint details (if created)

You can then use the Key Vault to:

1. Store application secrets and configuration
2. Manage SSL/TLS certificates
3. Store SSH keys for server access
4. Provide secrets to Azure services via Key Vault references
5. Enable customer-managed encryption keys
6. Set up additional RBAC permissions for teams and applications

## Cleanup

To remove all resources:

```bash
# Delete the resource group (if dedicated to Key Vault)
az group delete --name my-resource-group

# Or delete just the Key Vault
az keyvault delete --name your-keyvault-name
```

Note: Key Vaults with purge protection enabled require additional steps for complete removal.
