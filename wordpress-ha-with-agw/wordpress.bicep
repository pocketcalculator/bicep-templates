param location string = resourceGroup().location
param application string
param environment string
// Keyvault
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
// Storage
param nfsStorageAccountName string
param blobStorageAccountName string
param logAnalyticsStorageAccountName string
param nfsShareName string

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
    nfsStorageAccountName: nfsStorageAccountName
    nfsShareName: nfsShareName
  }
  name: 'nfsshare'
}

module blobStorage './storage/blobStorage.bicep' = {
  params: {
    location: location
    blobStorageAccountName: blobStorageAccountName
    logAnalyticsStorageAccountName: logAnalyticsStorageAccountName
  }
  name: 'blob'
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
  scope: resourceGroup(kvResourceGroup)
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
    mySqlAdminPassword: kv.getSecret('mySqlAdminPassword')
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
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
    customData: base64(loadTextContent('./compute/cloudInit.txt'))
    vmDataCollectionRuleId: vmDataCollectionRule.outputs.vmDataCollectionRuleId
  }
  name: 'webserver'
}

module agw './network/applicationGateway.bicep' = {
  params: {
    location: location
    publicSubnetId: vnet.outputs.publicSubnetId
    application: application
    environment: environment
    webServerIP: webserver.outputs.webServerIP
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
  name: 'agw'
}

module logAnalytics './monitor/logAnalytics.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
  }
  name: 'loganalytics'
}

module vmDataCollectionRule './monitor/vmDataCollectionRule.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
    logAnalyticsWorkspaceName: logAnalytics.outputs.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
  name: 'vmDataCollectionRule'
}
