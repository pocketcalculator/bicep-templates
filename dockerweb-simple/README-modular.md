# Docker Web Simple - Modular Deployment

This folder contains a modular approach to deploying Docker-enabled web infrastructure on Azure using Bicep templates.

## Architecture Overview

The deployment is split into three logical layers:

1. **Network Layer** - VNet, subnets, and network security groups
2. **Storage Layer** - Blob storage for backups and data
3. **Compute Layer** - VM with Docker, monitoring, and application components

## Files Structure

### Deployment Scripts

- `shared-config.sh` - Shared configuration ensuring consistent naming across all scripts
- `build-web-network.sh` - Deploys network infrastructure (VNet, NSGs, subnets)
- `build-web-storage.sh` - Deploys storage infrastructure (blob storage)
- `build-web-docker.sh` - Deploys compute infrastructure (VM, monitoring)
- `cleanup.sh` - Removes generated files and optionally deletes Azure resources
- `test-shared-config.sh` - Tests the shared configuration system

### Bicep Modules (Reused)
- `network/` - Network-related Bicep modules
- `storage/` - Storage-related Bicep modules  
- `compute/` - Compute-related Bicep modules
- `monitor/` - Monitoring-related Bicep modules

## Usage

### Prerequisites
- Azure CLI installed and authenticated
- Appropriate Azure permissions to create resources
- Key Vault with admin password (referenced in scripts)

### Step-by-Step Deployment
```bash
# 1. Deploy network infrastructure
chmod +x ./build-web-network.sh
./build-web-network.sh

# 2. Deploy storage infrastructure  
chmod +x ./build-web-storage.sh
./build-web-storage.sh

# 3. Deploy compute infrastructure
chmod +x ./build-web-docker.sh
./build-web-docker.sh
```

### Individual Layer Deployment
You can deploy individual layers as needed:

```bash
# Deploy only network layer
./build-web-network.sh

# Deploy only storage layer (requires network to be deployed first)
./build-web-storage.sh

# Deploy only compute layer (requires network and storage)
./build-web-docker.sh
```

### Configuration
Edit the variables at the top of each script to customize:
- `subscription` - Your Azure subscription ID
- `location` - Azure region (default: eastus)
- `applicationName` - Base name for resources (default: docker)
- `environment` - Environment name (default: dev)
- Key Vault details for admin password retrieval

### Cleanup
```bash
# Remove generated files and optionally delete Azure resources
chmod +x ./cleanup.sh
./cleanup.sh
```

## Generated Files

During deployment, the following files are created:

### Bicep Templates
- `network-deployment.bicep` - Network layer template
- `storage-deployment.bicep` - Storage layer template
- `compute-deployment.bicep` - Compute layer template

### Output Files
- `network-outputs.json` - Network resource IDs for use by subsequent layers
- `storage-outputs.json` - Storage resource information
- `compute-outputs.json` - Compute resource information and connection details

### Configuration Files

- `compute/cloudInit.txt` - VM initialization script (generated)
- `deployment-config.txt` - Shared configuration with consistent naming suffix (generated)

## Shared Configuration System

The modular deployment uses a shared configuration system to ensure consistent naming across all resources:

- **First deployment**: `shared-config.sh` generates a random 4-character suffix and saves it to `deployment-config.txt`
- **Subsequent runs**: All scripts reuse the same suffix from the saved configuration
- **Benefits**: All resources have consistent naming, proper relationships, and easier management

Example resource names with suffix `sods`:
- Resource Group: `rg-docker-dev-eastus`
- Application Name: `dockersods`  
- Storage Account: `bkupdockersods`
- VM: `web-dockersods-dev-eastus`

To start fresh with a new suffix, delete `deployment-config.txt` or run `./cleanup.sh`.

## Benefits of Modular Approach

1. **Faster Development** - Deploy only the layer you're working on
2. **Better Testing** - Test individual components in isolation
3. **Improved Reusability** - Network and storage can be shared across applications
4. **Easier Troubleshooting** - Isolate issues to specific layers
5. **Cost Management** - Deploy only what you need for development/testing
6. **Parallel Development** - Teams can work on different layers independently

## Dependencies

- **Network Layer**: No dependencies (can be deployed first)
- **Storage Layer**: No dependencies (can be deployed independently)  
- **Compute Layer**: Requires network and storage layers to be deployed first

The scripts automatically check for required dependencies and will fail with helpful messages if prerequisites are missing.

## Resource Naming Convention

Resources follow the naming pattern: `<type>-<application>-<environment>-<location>`

Example:
- Resource Group: `rg-docker1234-dev-eastus`
- Virtual Network: `vnet-docker1234-dev-eastus`
- Storage Account: `bkupdocker1234`

## Troubleshooting

### Common Issues
1. **Key Vault Access**: Ensure your account has access to the specified Key Vault
2. **Quota Limits**: Check Azure quotas for VM sizes in your region
3. **Network Dependencies**: Ensure network layer is deployed before compute
4. **Storage Dependencies**: Ensure storage layer is deployed before compute

### Debugging
- Check the generated Bicep files for syntax issues
- Review the JSON output files for resource IDs
- Use Azure Portal to verify resource deployment status
- Check VM boot diagnostics if the VM fails to start

### Log Files
Each deployment creates detailed logs. Check the terminal output for specific error messages and deployment status.
