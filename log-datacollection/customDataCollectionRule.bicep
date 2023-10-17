param location string = resourceGroup().location
param application string
param environment string
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceId string
param dataCollectionEndpointId string
var customDataCollectionRuleName = 'dcr-${application}-${environment}-${location}'

resource iisDataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  location: location
  name: customDataCollectionRuleName
  kind: 'Windows'
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-CustomTextLog_CL': {
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
      extensions: null
      iisLogs: null
      logFiles: [
        {
          filePatterns: [
            'C:\\app\\applog.txt'
          ]
          format: 'text'
          name: 'CustomTextLog_CL'
          settings: {
            text: {
              recordStartTimestampFormat: 'ISO 8601'
            }
          }
          streams: [
            'Custom-CustomTextLog_CL'
          ]
        }
      ]
      performanceCounters: null
      syslog: null
      windowsEventLogs: null
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
        destinations: [
          logAnalyticsWorkspaceName
        ]
        outputStream: 'Custom-CustomTextLog_CL'
        streams: [
          'Custom-CustomTextLog_CL'
        ]
        transformKql: 'source | parse RawData with color:string\' \'dayOfWeek:string\' \'orderDate:datetime\' \'orderId:string\' \'orderStatus:string'
      }
    ]
  }
}

output iisDataCollectionRuleId string = iisDataCollectionRule.id
