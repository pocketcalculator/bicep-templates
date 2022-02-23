param location string
param application string
param environment string
@secure()
param adminUsername string
@secure()
param adminPassword string
param customData string
param privateSubnetId string
var webServerName = 'web-${application}-${environment}-${location}'
var webNICName = 'nic-${webServerName}'
var ipConfigName = 'ipconfig0-${webNICName}'
var publicIPAddressName = 'ip-${webServerName}'
var osDiskName = 'disk-os-${webServerName}'
var dnsLabelPrefix = toLower('${webServerName}')
var osDiskType = 'Standard_LRS'

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
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
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
      enableAutomaticUpgrade: false
      autoUpgradeMinorVersion: true
      typeHandlerVersion: '1.15'
    }
  }
}

output webServerId string = webServer.id
output webServerIP string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
