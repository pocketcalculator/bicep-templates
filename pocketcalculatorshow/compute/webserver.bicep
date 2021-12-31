param location string
param application string
param environment string
param adminUsername string
param adminPassword string
param publicSubnetId string
var webserverVMName = 'web-${application}-${environment}-${location}'
var webNICName = 'nic-${webserverVMName}'
var ipConfigName = 'ipconfig0-${webNICName}'
var publicIPAddressName = 'ip-${webserverVMName}'
@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
//var dnsLabelPrefix = toLower('${webserverVMName}-${uniqueString(resourceGroup().id)}')
var dnsLabelPrefix = toLower('${webserverVMName}')
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
            id: publicSubnetId
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

resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: webserverVMName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: webserverVMName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: 'name'
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
        enabled: false
      }
    }
  }
}
