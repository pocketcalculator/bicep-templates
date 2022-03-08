param location string
param application string
param environment string
param vmId string
var dashboardName = 'dashboard-${application}-${environment}-${location}'


resource dashboard 'Microsoft.Portal/dashboards@2020-09-01-preview' ={
  location: location
  name: dashboardName
  properties: {
    lenses: [
      {
        order: 0
        parts: [
          {
            position: {
              x: 0
              y: 0
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
              ]
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '## Azure Virtual Machines Overview\r\nNew team members should watch this video to get familiar with Azure Virtual Machines.'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 3
              y: 0
              rowSpan: 4
              colSpan: 8
            }
            metadata: {
              inputs: [
              ]
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: 'This is the team dashboard for the test VM we use on our team. Here are some useful links:\r\n\r\n1. [Create a Linux virtual machine](https://docs.microsoft.com/azure/virtual-machines/linux/quick-create-portal)\r\n1. [Create a Windows virtual machine](https://docs.microsoft.com/azure/virtual-machines/windows/quick-create-portal)\r\n1. [Create a virtual machine scale set](https://docs.microsoft.com/azure/virtual-machine-scale-sets/quick-create-portal),'
                    title: 'Test VM Dashboard'
                    subtitle: 'Contoso'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 0
              y: 2
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
              ]
              type: 'Extension/HubsExtension/PartType/VideoPart'
              settings: {
                content: {
                  settings: {
                    src: 'https://www.youtube.com/watch?v=rOiSRkxtTeU'
                    autoplay: false
                  }
                }
              }
            }
          }
          {
            position: {
              x: 0
              y: 4
              rowSpan: 3
              colSpan: 11
            }
            metadata: {
              inputs: [
                {
                  name: 'queryInputs'
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
          {
            position: {
              x: 0
              y: 7
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'queryInputs'
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
          {
            position: {
              x: 3
              y: 7
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'queryInputs'
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
          {
            position: {
              x: 6
              y: 7
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'queryInputs'
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
          {
            position: {
              x: 9
              y: 7
              rowSpan: 2
              colSpan: 2
            }
            metadata: {
              inputs: [
                {
                  name: 'id'
                  value: vmId
                }
              ]
              type: 'Extension/Microsoft_Azure_Compute/PartType/VirtualMachinePart'
              asset: {
                idInputName: 'id'
                type: 'VirtualMachine'
              }
            }
          }
        ]
      }
    ]
  }
}
