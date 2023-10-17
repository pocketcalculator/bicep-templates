param location string
param iisDataCollectionRuleId string
param dataCollectionEndpointId string
param userAssignedManagedIdentity string
param systemAssignedManagedIdentity string
param vmName string

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' existing = {
  name: vmName
} 

resource extension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: 'AzureMonitorWindowsAgent'
  location: location
  parent: vm
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.13'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
            'identifier-value': systemAssignedManagedIdentity
//          'identifier-name': 'mi_res_id'
//          'identifier-value': userAssignedManagedIdentity
        }
      }
    }
  }
}

resource dataCollectionEndpointAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: 'configurationAccessEndpoint'
  scope: vm
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
  }
}

resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: 'configurationAccessEndpoint2'
  scope: vm
  properties: {
    dataCollectionRuleId: iisDataCollectionRuleId
  }
}

output vmName string = vm.name
output vmId string = vm.id
