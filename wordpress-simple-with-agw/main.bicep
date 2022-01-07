param location string = resourceGroup().location
param application string
param environment string
@secure()
param adminUsername string
@secure()
param adminPassword string

module nsg './network/nsg.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
  }
  name: 'nsg-group'
}

module vnet './network/vnet.bicep' = {
  params: {
    application: application
    location: location
    environment: environment
    bastionNSGid: nsg.outputs.bastionNSGid
    webNSGid: nsg.outputs.webNSGid
    appNSGid: nsg.outputs.appNSGid
    dbNSGid: nsg.outputs.dbNSGid
  }
  name: 'vnet'
}

module webserver './compute/webserver.bicep' = {
  params: {
    privateSubnetId: vnet.outputs.privateSubnetId
    location: location
    application: application
    environment: environment
    adminUsername:  adminUsername
    adminPassword: adminPassword
  }
  name: 'webserver'
}

module agw './network/agw.bicep' = {
  params: {
    publicSubnetId: vnet.outputs.publicSubnetId
    application: application
    environment: environment
    webServerId: webserver.outputs.webServerId
    webServerIP: webserver.outputs.webServerIP
  }
  name: 'agw'
}
