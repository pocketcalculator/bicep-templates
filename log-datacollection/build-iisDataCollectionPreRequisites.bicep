param location string = resourceGroup().location
param application string
param environment string
param vmName string
param userManagedIdentity string

module logAnalyticsWorkspace './logAnalyticsWorkspace.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
  }
  name: 'logAnalyticsWorkspace'
}

module dataCollectionEndpoint './dataCollectionEndpoint.bicep' = {
  params: {
    location: location
    application: application
    environment: environment  
  }
  name: 'dataCollectionEndpoint'
}

resource amaUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
    name: userManagedIdentity
}

module iisDataCollectionRule './iisDataCollectionRule.bicep' = {
  params: {
    location: location
    application: application
    environment: environment
    dataCollectionEndpointId: dataCollectionEndpoint.outputs.dataCollectionEndpointId
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
  name: 'iisDataCollectionRule'
}

module monitoringAgentExtension './monitoringAgentExtension.bicep' = {
  params: {
    dataCollectionEndpointId: dataCollectionEndpoint.outputs.dataCollectionEndpointId
    iisDataCollectionRuleId: iisDataCollectionRule.outputs.iisDataCollectionRuleId
    location: location
    vmName: vmName
    userAssignedManagedIdentity: amaUserManagedIdentity.id
  }
  name: 'monitoringAgentExtension'
}
