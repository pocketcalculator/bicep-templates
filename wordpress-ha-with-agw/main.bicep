param location string = resourceGroup().location
param application string
param environment string
param kvResourceGroup string
param kvName string
// Web Server
@description('web server OS admin username')
@secure()
param adminUsername string
// mySQL DB Server
@description('db server hadware family')
param mySqlHwFamily string
@description('db server hardware name')
param mySqlHwName string
@description('db server vcore capacity')
param mySqlvCoreCapacity int
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

module privateEndpoints './network/privateEndpoints.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
    fileShareId: nfsshare.outputs.nfsShareId
    mySQLId: mysql.outputs.mySQLId
    vnetId: vnet.outputs.vnetId
    privateSubnetId: vnet.outputs.privateSubnetId
    dbSubnetId: vnet.outputs.dbSubnetId
  }
  name: 'privateendpoints'
}

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: kvName
  scope: resourceGroup(kvResourceGroup )
}

module mysql 'mysql/mySQL.bicep' = {
  params: {
    application: application
    environment: environment
    location: location
    mySqlHwFamily: mySqlHwFamily
    mySqlHwName: mySqlHwName
    mySqlHwTier: mySqlHwTier
    mySqlvCoreCapacity: mySqlvCoreCapacity
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
    adminPassword: kv.getSecret('adminPassword')
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