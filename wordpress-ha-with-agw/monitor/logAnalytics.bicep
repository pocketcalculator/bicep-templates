param location string
param application string
param environment string
param logAnalyticsStorageAccountNameId string
var logAnalyticsWorkspaceName = 'log-${application}-${environment}-${location}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

/*
resource dependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: '${webServerName}/DAExtension'
  dependsOn: [
    webServer
  ]
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    enableAutomaticUpgrade: true
    autoUpgradeMinorVersion: true
    typeHandlerVersion: '9.5'
  }
}

resource diagnosticAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: '${webServerName}/LinuxDiagnostic'
  dependsOn: [
    webServer
  ]
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'LinuxDiagnostic'
    enableAutomaticUpgrade: false
    autoUpgradeMinorVersion: true
    typeHandlerVersion: '3.0'
    settings: {
      StorageAccount: logAnalyticsStorageAccountNameId
    }
  }
}
*/
