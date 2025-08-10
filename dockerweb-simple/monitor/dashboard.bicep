param location string
param application string
param environment string
param vmId string
param agwId string
param mySQLId string
var dashboardName = 'dashboard-${application}-${environment}-${location}'

resource dashboard 'Microsoft.Portal/dashboards@2015-08-01-preview' = {
  location: location
  name: dashboardName
  properties: {
    lenses: {
      '0': {
        order: 0
        parts: {
          //AGW Response by HttpStatus, Sum
          '0': {
            position: {
              x: 0
              y: 0
              rowSpan: 3
              colSpan: 9
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: agwId
                          }
                          name: 'ResponseStatus'
                          aggregationType: 1
                          metricVisualization: {
                            displayName: 'Response Status'
                            resourceDisplayName: agwId
                          }
                        }
                      ]
                      title: 'Sum Response Status by HttpStatus'
                      titleKind: 2
                      grouping: {
                        dimension: 'HttpStatusGroup'
                      }
                      visualization: {
                        chartType: 2
                      }
                      openBladeOnClick: {
                        openBlade: true
                      }
                    }
                  }
                  isOptional: true
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              filters: {
                MsPortalFx_TimeRange: {
                  model: {
                    format: 'local'
                    granularity: 'auto'
                    relative: '60m'
                  }
                }
              }
            }
          }
        }
      }
    }
    metadata: {
      model: {}
    }
  }
}
