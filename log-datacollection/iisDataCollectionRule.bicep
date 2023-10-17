param location string = resourceGroup().location
param application string
param environment string
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceId string
param dataCollectionEndpointId string
var iisDataCollectionRuleName = 'dcr-${application}-${environment}-${location}'

resource iisDataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  location: location
  name: iisDataCollectionRuleName
  kind: 'Windows'
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-MyTable_CL': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawData'
            type: 'string'
          }
        ]
      }
    }
    dataSources: {
      iisLogs: [
        {
          streams: [
            'Microsoft-W3CIISLog'
          ]
          name: 'iisLogsDataSource'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: logAnalyticsWorkspaceName
          workspaceResourceId: logAnalyticsWorkspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-W3CIISLog'
        ]
        destinations: [
          logAnalyticsWorkspaceName
        ]
        transformKql: 'source'
        outputStream: 'Microsoft-W3CIISLog'
      }
    ]
  }
}

output iisDataCollectionRuleId string = iisDataCollectionRule.id
