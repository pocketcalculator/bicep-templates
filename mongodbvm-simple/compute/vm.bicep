param location string
param application string
param environment string
@secure()
param adminUsername string
@secure()
param adminPassword string
param customData string
param databaseSubnetId string
param vmDataCollectionRuleId string
param blobStorageAccountName string
var mongodbServerName = 'mongodb-${application}-${environment}'
var mongodbNICName = 'nic-${mongodbServerName}'
var ipConfigName = 'ipconfig0-${mongodbNICName}'
var publicIPAddressName = 'ip-${mongodbServerName}'
var osDiskName = 'disk-os-${mongodbServerName}'
var dnsLabelPrefix = toLower('${mongodbServerName}')
var osDiskType = 'Standard_LRS'
//globally unique identifier for Storage Blob Contributor Role
// Note: Consider using more specific roles like "Storage Blob Data Contributor" (ba92f5b4-2d11-453d-a403-e96b0029c9fe)
// or "Storage Blob Data Reader" (2a2b9908-6ea1-4ae2-8e65-a410df84e7d1) based on actual requirements
var blobContributorRoleDefinitionName = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
//globally unique identifier for Reader Role (needed for az storage account list)
var readerRoleDefinitionName = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: mongodbNICName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ipConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: databaseSubnetId
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'  // Standard SKU only supports Static
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
    idleTimeoutInMinutes: 4
  }
}

resource mongodbServer 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: mongodbServerName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: mongodbServerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
      customData: customData
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        name: osDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  resource AzureMonitorLinuxAgent 'extensions@2023-07-01' = {
    name: 'AzureMonitorLinuxAgent'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.Monitor'
      type: 'AzureMonitorLinuxAgent'
      enableAutomaticUpgrade: true
      autoUpgradeMinorVersion: true
      typeHandlerVersion: '1.36'
    }
  }
  resource NetworkWatcherAgentLinux 'extensions@2023-07-01' = {
    name: 'NetworkWatcherAgentLinux'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.NetworkWatcher'
      type: 'NetworkWatcherAgentLinux'
      enableAutomaticUpgrade: true
      autoUpgradeMinorVersion: true
      typeHandlerVersion: '1.4'
    }
  }
}

resource blobStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: blobStorageAccountName
}

resource blobContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: blobContributorRoleDefinitionName
}

resource readerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: readerRoleDefinitionName
}

/*
resource blobContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: blobStorageAccount
  name: guid(blobStorageAccountName, mongodbServerName, blobContributorRoleDefinitionName)
  properties: {
    roleDefinitionId:  blobContributorRoleDefinition.id
    principalId: mongodbServer.identity.principalId
  }
}

resource readerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: guid(resourceGroup().id, mongodbServerName, readerRoleDefinitionName)
  properties: {
    roleDefinitionId: readerRoleDefinition.id
    principalId: mongodbServer.identity.principalId
  }
}
*/

resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: 'dcrassociation'
  scope: mongodbServer
  properties: {
    dataCollectionRuleId: vmDataCollectionRuleId
  }
}

output mongodbServerId string = mongodbServer.id
output mongodbServerIP string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
output mongodbServerIdentity string = mongodbServer.identity.principalId
output mongodbServerPublicIPResourceId string = publicIP.id
output mongodbServerFQDN string = publicIP.properties.dnsSettings.fqdn
