param location string
param application string
param environment string
param bastionNSGid string
param frontendNSGid string
param applicationNSGid string
param databaseNSGid string
param vnetCIDRPrefix string
//var vnetName = '${application}-${environment}-vnet-${uniqueString(resourceGroup().id)}'
var vnetName = 'vnet-${application}-${environment}-${location}'
var vnetAddressPrefix = '${vnetCIDRPrefix}.0.0/16'
var gatewaySubnetAddressPrefix = '${vnetCIDRPrefix}.1.0/27'
var bastionSubnetAddressPrefix = '${vnetCIDRPrefix}.2.0/27'
var publicSubnetAddressPrefix = '${vnetCIDRPrefix}.10.0/24'
var privateSubnetAddressPrefix = '${vnetCIDRPrefix}.20.0/24'
var dbSubnetAddressPrefix = '${vnetCIDRPrefix}.30.0/24'
var bastionSubnetName = 'snet-bastion-${application}-${environment}-${location}'
var frontendSubnetName = 'snet-frontend-${application}-${environment}-${location}'
var applicationSubnetName = 'snet-application-${application}-${environment}-${location}'
var databaseSubnetName = 'snet-database-${application}-${environment}-${location}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetAddressPrefix
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: bastionNSGid
          }
        }
      }
      {
        name: frontendSubnetName
        properties: {
          addressPrefix: publicSubnetAddressPrefix
          networkSecurityGroup: {
            id: frontendNSGid
          }
        }
      }
      {
        name: applicationSubnetName
        properties: {
          addressPrefix: privateSubnetAddressPrefix
          networkSecurityGroup: {
            id: applicationNSGid
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: databaseSubnetName
        properties: {
          addressPrefix: dbSubnetAddressPrefix
          networkSecurityGroup: {
            id: databaseNSGid
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
output gatewaySubnetId string = virtualNetwork.properties.subnets[0].id
output bastionSubnetId string = virtualNetwork.properties.subnets[1].id
output frontendSubnetId string = virtualNetwork.properties.subnets[2].id
output applicationSubnetId string = virtualNetwork.properties.subnets[3].id
output databaseSubnetId string = virtualNetwork.properties.subnets[4].id
