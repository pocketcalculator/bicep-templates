param location string
param application string
param environment string
@secure()
param adminUsername string
@secure()
param adminPassword string
param customData string
param privateSubnetId string
param vmDataCollectionRuleId string
param blobStorageAccountName string
var webServerName = 'web-${application}-${environment}-${location}'
var webNICName = 'nic-${webServerName}'
var ipConfigName = 'ipconfig0-${webNICName}'
var publicIPAddressName = 'ip-${webServerName}'
var osDiskName = 'disk-os-${webServerName}'
var dnsLabelPrefix = toLower('${webServerName}')
var osDiskType = 'Standard_LRS'
//globally unique identifier for Storage Blob Contributor Role
var blobContributorRoleDefinitionName = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: webNICName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ipConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: privateSubnetId
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
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
    idleTimeoutInMinutes: 4
  }
}

resource webServer 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: webServerName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: webServerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPassword
            }
          ]
        }
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
  resource AzureMonitorLinuxAgent 'Extensions@2021-07-01' = {
    name: 'AzureMonitorLinuxAgent'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.Monitor'
      type: 'AzureMonitorLinuxAgent'
      enableAutomaticUpgrade: true
      autoUpgradeMinorVersion: true
      typeHandlerVersion: '1.26'
    }
  }
  resource NetworkWatcherAgentLinux 'Extensions@2021-07-01' = {
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

resource blobContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: blobStorageAccount
  name: guid(blobStorageAccountName, webServerName, blobContributorRoleDefinitionName)
  properties: {
    roleDefinitionId:  blobContributorRoleDefinition.id
    principalId: webServer.identity.principalId
  }
}

resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = {
  name: 'dcrassociation'
  scope: webServer
  properties: {
    dataCollectionRuleId: vmDataCollectionRuleId
  }
}

output webServerId string = webServer.id
output webServerIP string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
output webserverIdentity string = webServer.identity.principalId
output webServerPublicIPResourceId string = publicIP.id
output webServerFQDN string = publicIP.properties.dnsSettings.fqdn
