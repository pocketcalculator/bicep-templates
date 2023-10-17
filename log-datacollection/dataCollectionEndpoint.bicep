param location string
param application string
param environment string
var dataCollectionEndpointName = 'dce-${application}-${environment}-${location}'

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2022-06-01' = {
  name: dataCollectionEndpointName
  location: location
  kind: 'Windows'
  properties: {
    configurationAccess: {}
    logsIngestion: {}
    metricsIngestion: {}
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

output dataCollectionEndpointId string = dataCollectionEndpoint.id
output dataCollectionEndpointName string = dataCollectionEndpointName
