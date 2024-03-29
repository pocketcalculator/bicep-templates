param location string
param application string
param environment string
param bastionNSGid string
param webNSGid string
param appNSGid string
param dbNSGid string
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
var publicSubnetName = 'snet-public-${application}-${environment}-${location}'
var privateSubnetName = 'snet-private-${application}-${environment}-${location}'
var dbSubnetName = 'snet-db-${application}-${environment}-${location}'

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
        name: publicSubnetName
        properties: {
          addressPrefix: publicSubnetAddressPrefix
          networkSecurityGroup: {
            id: webNSGid
          }
        }
      }
      {
        name: privateSubnetName
        properties: {
          addressPrefix: privateSubnetAddressPrefix
          networkSecurityGroup: {
            id: appNSGid
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: dbSubnetName
        properties: {
          addressPrefix: dbSubnetAddressPrefix
          networkSecurityGroup: {
            id: dbNSGid
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
output publicSubnetId string = virtualNetwork.properties.subnets[2].id
output privateSubnetId string = virtualNetwork.properties.subnets[3].id
output dbSubnetId string = virtualNetwork.properties.subnets[4].id
