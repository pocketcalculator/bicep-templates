param location string = resourceGroup().location
param application string
param environment string
// Web Server
@description('web server OS admin username')
@secure()
param adminUsername string
@description('web server OS admin password')
@secure()
param adminPassword string
// mySQL DB Server
@description('db server hadware family')
param mySqlHwFamily string
@description('db server hardware name')
param mySqlHwName string
@description('db server hardware tier')
param mySqlHwTier string
@secure()
param mySqlAdminLogin string
@secure()
param mySqlAdminPassword string

module nsg './network/networkSecurityGroup.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
  }
  name: 'nsg'
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

module nfsshare './storage/nfsShare.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
  }
  name: 'nfsshare'
}

module mysql 'mysql/mySQL.bicep' = {
  params: {
    application: application
    environment: environment
    location: location
    mySqlHwFamily: mySqlHwFamily
    mySqlHwName: mySqlHwName
    mySqlHwTier: mySqlHwTier
    mySqlAdminLogin: mySqlAdminLogin
    mySqlAdminPassword: mySqlAdminPassword
  }
  name: 'mysql'
}


module webserver './compute/webVM.bicep' = {
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

module agw './network/applicationGateway.bicep' = {
  params: {
    publicSubnetId: vnet.outputs.publicSubnetId
    application: application
    environment: environment
    webServerId: webserver.outputs.webServerId
    webServerIP: webserver.outputs.webServerIP
  }
  name: 'agw'
}
