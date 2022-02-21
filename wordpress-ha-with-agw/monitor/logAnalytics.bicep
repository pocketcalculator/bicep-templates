param location string
param application string
param environment string
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
