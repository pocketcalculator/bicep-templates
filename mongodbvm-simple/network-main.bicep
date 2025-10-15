param location string = resourceGroup().location
param application string
param environment string
param vnetCIDRPrefix string
param adminSourceIP string

// Common tags
var commonTags = {
  Application: application
  Environment: environment
  CreatedBy: 'Bicep'
  Layer: 'Network'
}

module nsg './network/networkSecurityGroup.bicep' = {
  params: {
    adminSourceIP: adminSourceIP
    location: location
    application: application
    environment: environment
  }
  name: 'nsg-deployment'
}

module vnet './network/vnet.bicep' = {
  params: {
    vnetCIDRPrefix: vnetCIDRPrefix
    application: application
    location: location
    environment: environment
    bastionNSGid: nsg.outputs.bastionNSGid
    frontendNSGid: nsg.outputs.frontendNSGid
    applicationNSGid: nsg.outputs.applicationNSGid
    databaseNSGid: nsg.outputs.databaseNSGid
  }
  name: 'vnet-deployment'
}

// Output network resource IDs for use by subsequent deployments
output vnetId string = vnet.outputs.vnetId
output gatewaySubnetId string = vnet.outputs.gatewaySubnetId
output bastionSubnetId string = vnet.outputs.bastionSubnetId
output frontendSubnetId string = vnet.outputs.frontendSubnetId
output applicationSubnetId string = vnet.outputs.applicationSubnetId
output databaseSubnetId string = vnet.outputs.databaseSubnetId
output bastionNSGid string = nsg.outputs.bastionNSGid
output frontendNSGid string = nsg.outputs.frontendNSGid
output applicationNSGid string = nsg.outputs.applicationNSGid
output databaseNSGid string = nsg.outputs.databaseNSGid
