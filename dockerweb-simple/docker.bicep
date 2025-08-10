param location string = resourceGroup().location
param application string
param environment string
param vnetCIDRPrefix string
// Keyvault
param kvResourceGroup string
param kvName string
param adminSourceIP string
// Web Server
@description('web server OS admin username')
@secure()
param adminUsername string
// Storage
param backupBlobStorageAccountName string
param backupBlobContainerName string

// Common tags
var commonTags = {
  Application: application
  Environment: environment
  CreatedBy: 'Bicep'
}

module nsg './network/networkSecurityGroup.bicep' = {
  params: {
    adminSourceIP: adminSourceIP
    location: location
    application: application
    environment: environment
  }
  name: 'nsg'
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
  name: 'vnet'
}

module storage './storage/storage.bicep' = {
  params: {
    location: location
    blobStorageAccountName: backupBlobStorageAccountName
    blobContainerName: backupBlobContainerName
  }
  name: 'storage'
}

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: kvName
  scope: resourceGroup(kvResourceGroup)
}

module webserver './compute/vm.bicep' = {
  params: {
    applicationSubnetId: vnet.outputs.applicationSubnetId
    blobStorageAccountName: backupBlobStorageAccountName
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

module logAnalytics './monitor/logAnalytics.bicep' = {
  params: {
    application: application
    environment: environment
    location: location
  }
  name: 'logAnalytics'
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

output webServerPublicIPResourceId string = webserver.outputs.webServerPublicIPResourceId
output webServerFQDN string = webserver.outputs.webServerFQDN
