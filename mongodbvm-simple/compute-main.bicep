param location string = resourceGroup().location
param application string
param environment string
@secure()
param adminPassword string
param adminUsername string
param blobStorageAccountName string
param databaseSubnetId string

// Common tags
var commonTags = {
  Application: application
  Environment: environment
  CreatedBy: 'Bicep'
  Layer: 'Compute'
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

// Deploy the MongoDB VM
module mongodbServer './compute/vm.bicep' = {
  params: {
    databaseSubnetId: databaseSubnetId
    blobStorageAccountName: blobStorageAccountName
    location: location
    application: application
    environment: environment
    adminUsername: adminUsername
    adminPassword: adminPassword
    customData: base64(loadTextContent('./compute/cloudInit.txt'))
    vmDataCollectionRuleId: vmDataCollectionRule.outputs.vmDataCollectionRuleId
  }
  name: 'mongodbServer-deployment'
}

// Output important resource information
output mongodbServerPublicIPResourceId string = mongodbServer.outputs.mongodbServerPublicIPResourceId
output mongodbServerFQDN string = mongodbServer.outputs.mongodbServerFQDN
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName
output vmDataCollectionRuleId string = vmDataCollectionRule.outputs.vmDataCollectionRuleId
