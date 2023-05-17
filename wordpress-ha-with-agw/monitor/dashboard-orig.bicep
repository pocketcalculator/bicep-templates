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
          /**
          //Web VM Percentage CPU, Avg
          '0': {
            position: {
              x: 0
              y: 0
              rowSpan: 3
              colSpan: 12
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: vmId
                    chartType: 0
                    metrics: [
                      {
                        name: 'Percentage CPU'
                        resourceId: vmId
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //Web VM Disk operations/sec (average)
          '1': {
            position: {
              x: 0
              y: 3
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: vmId
                    chartType: 0
                    metrics: [
                      {
                        name: 'Disk Read Operations/Sec'
                        resourceId: vmId
                      }
                      {
                        name: 'Disk Write Operations/Sec'
                        resourceId: vmId
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //Web VM Disk I/O bytes (total)
          '2': {
            position: {
              x: 3
              y: 3
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: vmId
                    chartType: 0
                    metrics: [
                      {
                        name: 'Disk Read Bytes'
                        resourceId: vmId
                      }
                      {
                        name: 'Disk Write Bytes'
                        resourceId: vmId
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //Web VM Network I/O (total)
          '3': {
            position: {
              x: 6
              y: 3
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: vmId
                    chartType: 0
                    metrics: [
                      {
                        name: 'Network In Total'
                        resourceId: vmId
                      }
                      {
                        name: 'Network Out Total'
                        resourceId: vmId
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //Web VM Percenage Memory, Avg
          '4': {
            position: {
              x: 9
              y: 3
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: vmId
                    chartType: 0
                    metrics: [
                      {
                        name: 'Available Memory Bytes'
                        resourceId: vmId
                        aggregationType: 4
                        namespace: 'microsoft.compute/virtualmachines'
                        metricVisualization: {
                          displayName: 'Available Memory Bytes'
                          resourceDisplayName: vmId
                        }
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //AGW Compute Units, Avg
          '5': {
            position: {
              x: 0
              y: 5
              rowSpan: 3
              colSpan: 9
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: agwId
                    chartType: 0
                    metrics: [
                      {
                        name: 'ComputeUnits'
                        resourceId: agwId
                        aggregationType: 4
                        namespace: 'microsoft.network/applicationgateways'
                        metricVisualization: {
                          displayName: 'Current Compute Units'
                          resourceDisplayName: agwId
                        }
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          */
          //AGW Response by HttpStatus, Sum
          '6': {
            position: {
              x: 0
              y: 8
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
                            displayName: 'HTTP Response Status'
                            resourceDisplayName: agwId
                          }
                        }
                      ]
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
              type: 'Extension/HubExtension/PartType/MetricsChartPart'
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
          /*
          //AGW Total Requests
          '7': {
            position: {
              x: 0
              y: 11
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: agwId
                    chartType: 2
                    metrics: [
                      {
                        name: 'TotalRequests'
                        resourceId: agwId
                        aggregationType: 1
                        namespace: 'microsoft.network/applicationgateways'
                        metricVisualization: {
                          displayName: 'Sum Total Requests'
                          resourceDisplayName: agwId
                        }
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //AGW Failed Requests
          '8': {
            position: {
              x: 3
              y: 11
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: agwId
                    chartType: 2
                    metrics: [
                      {
                        name: 'FailedRequests'
                        resourceId: agwId
                        aggregationType: 1
                        namespace: 'microsoft.network/applicationgateways'
                        metricVisualization: {
                          displayName: 'Sum Failed Requests'
                          resourceDisplayName: agwId
                        }
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //AGW Throughput
          '9': {
            position: {
              x: 6
              y: 11
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: agwId
                    chartType: 2
                    metrics: [
                      {
                        name: 'Throughput'
                        resourceId: agwId
                        aggregationType: 1
                        namespace: 'microsoft.network/applicationgateways'
                        metricVisualization: {
                          displayName: 'Sum Throughput'
                          resourceDisplayName: agwId
                        }
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //AGW Current Connections
          '10': {
            position: {
              x: 0
              y: 13
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: agwId
                    chartType: 2
                    metrics: [
                      {
                        name: 'CurrentConnections'
                        resourceId: agwId
                        aggregationType: 1
                        namespace: 'microsoft.network/applicationgateways'
                        metricVisualization: {
                          displayName: 'Sum CurrentConnections'
                          resourceDisplayName: agwId
                        }
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //AGW Healthy Host Count
          '11': {
            position: {
              x: 3
              y: 13
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: agwId
                    chartType: 2
                    metrics: [
                      {
                        name: 'HealthyHostCount'
                        resourceId: agwId
                        aggregationType: 1
                        namespace: 'microsoft.network/applicationgateways'
                        metricVisualization: {
                          displayName: 'Healthy Host Count'
                          resourceDisplayName: agwId
                        }
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          //AGW Unhealthy Host Count
          '12': {
            position: {
              x: 6
              y: 13
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: agwId
                    chartType: 2
                    metrics: [
                      {
                        name: 'UnhealthyHostCount'
                        resourceId: agwId
                        aggregationType: 1
                        namespace: 'microsoft.network/applicationgateways'
                        metricVisualization: {
                          displayName: 'Unhealthy Host Count'
                          resourceDisplayName: agwId
                        }
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          */
        }
      }
    }
    metadata: {
      model: {}
    }
  }
}
