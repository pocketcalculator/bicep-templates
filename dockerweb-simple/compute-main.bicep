param location string = resourceGroup().location
param application string
param environment string
param kvResourceGroup string
param kvName string
param adminUsername string
param blobStorageAccountName string
param applicationSubnetId string

// Common tags
var commonTags = {
  Application: application
  Environment: environment
  CreatedBy: 'Bicep'
  Layer: 'Compute'
}

// Reference existing Key Vault
resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: kvName
  scope: resourceGroup(kvResourceGroup)
}

// Deploy monitoring components first
module logAnalytics './monitor/logAnalytics.bicep' = {
  params: {
    application: application
    environment: environment
    location: location
  }
  name: 'logAnalytics-deployment'
}

module vmDataCollectionRule './monitor/vmDataCollectionRule.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
    logAnalyticsWorkspaceName: logAnalytics.outputs.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
  name: 'vmDataCollectionRule-deployment'
}

// Deploy the VM
module webserver './compute/vm.bicep' = {
  params: {
    applicationSubnetId: applicationSubnetId
    blobStorageAccountName: blobStorageAccountName
    location: location
    application: application
    environment: environment
    adminUsername: adminUsername
    adminPassword: kv.getSecret('adminPassword')
    customData: base64(loadTextContent('./compute/cloudInit.txt'))
    vmDataCollectionRuleId: vmDataCollectionRule.outputs.vmDataCollectionRuleId
  }
  name: 'webserver-deployment'
}

// Output important resource information
output webServerPublicIPResourceId string = webserver.outputs.webServerPublicIPResourceId
output webServerFQDN string = webserver.outputs.webServerFQDN
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName
output vmDataCollectionRuleId string = vmDataCollectionRule.outputs.vmDataCollectionRuleId
