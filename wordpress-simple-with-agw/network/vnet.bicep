param location string
param application string
param environment string
param bastionNSGid string
param webNSGid string
param appNSGid string
param dbNSGid string
//var vnetName = '${application}-${environment}-vnet-${uniqueString(resourceGroup().id)}'
var vnetName = 'vnet-${application}-${environment}-${location}'
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
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.1.0/27'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: '10.0.2.0/27'
          networkSecurityGroup: {
            id: bastionNSGid
          }
        }
      }
      {
        name: publicSubnetName
        properties: {
          addressPrefix: '10.0.10.0/24'
          networkSecurityGroup: {
            id: webNSGid
          }
        }
      }
      {
        name: privateSubnetName
        properties: {
          addressPrefix: '10.0.20.0/24'
          networkSecurityGroup: {
            id: appNSGid
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: dbSubnetName
        properties: {
          addressPrefix: '10.0.30.0/24'
          networkSecurityGroup: {
            id: dbNSGid
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output gatewaySubnetId string = virtualNetwork.properties.subnets[0].id
output bastionSubnetId string = virtualNetwork.properties.subnets[1].id
output publicSubnetId string = virtualNetwork.properties.subnets[2].id
output privateSubnetId string = virtualNetwork.properties.subnets[3].id
output dbSubnetId string = virtualNetwork.properties.subnets[4].id
