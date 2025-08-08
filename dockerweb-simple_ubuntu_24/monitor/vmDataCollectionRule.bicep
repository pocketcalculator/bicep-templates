param location string = resourceGroup().location
param application string
param environment string
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceId string
var vmDataCollectionRuleName = 'dcr-${application}-${environment}-${location}'

resource vmDataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  location: location
  name: vmDataCollectionRuleName
  kind: 'Linux'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          counterSpecifiers: [
            'Processor(*)\\% Processor Time'
            'Processor(*)\\% Idle Time'
            'Processor(*)\\% User Time'
            'Processor(*)\\% Nice Time'
            'Processor(*)\\% Privileged Time'
            'Processor(*)\\% IO Wait Time'
            'Processor(*)\\% Interrupt Time'
            'Processor(*)\\% DPC Time'
            'Memory(*)\\Available MBytes Memory'
            'Memory(*)\\% Available Memory'
            'Memory(*)\\Used Memory MBytes'
            'Memory(*)\\% Used Memory'
            'Memory(*)\\Pages/sec'
            'Memory(*)\\Page Reads/sec'
            'Memory(*)\\Page Writes/sec'
            'Memory(*)\\Available MBytes Swap'
            'Memory(*)\\% Available Swap Space'
            'Memory(*)\\Used MBytes Swap Space'
            'Memory(*)\\% Used Swap Space'
            'Logical Disk(*)\\% Free Inodes'
            'Logical Disk(*)\\% Used Inodes'
            'Logical Disk(*)\\Free Megabytes'
            'Logical Disk(*)\\% Free Space'
            'Logical Disk(*)\\% Used Space'
            'Logical Disk(*)\\Logical Disk Bytes/sec'
            'Logical Disk(*)\\Disk Read Bytes/sec'
            'Logical Disk(*)\\Disk Write Bytes/sec'
            'Logical Disk(*)\\Disk Transfers/sec'
            'Logical Disk(*)\\Disk Reads/sec'
            'Logical Disk(*)\\Disk Writes/sec'
            'Network(*)\\Total Bytes Transmitted'
            'Network(*)\\Total Bytes Received'
            'Network(*)\\Total Bytes'
            'Network(*)\\Total Packets Transmitted'
            'Network(*)\\Total Packets Received'
            'Network(*)\\Total Rx Errors'
            'Network(*)\\Total Tx Errors'
            'Network(*)\\Total Collisions'
          ]
          samplingFrequencyInSeconds: 60
          streams: [
            'Microsoft-InsightsMetrics'
          ]
          name: 'perfCounterDataSource'
        }
      ]
      syslog: [
        {
          streams: [
            'Microsoft-Syslog'
          ]
          facilityNames: [
              'auth'
              'authpriv'
              'cron'
              'daemon'
              'mark'
              'kern'
              'local0'
              'local1'
              'local2'
              'local3'
              'local4'
              'local5'
              'local6'
              'local7'
              'lpr'
              'mail'
              'news'
              'syslog'
              'user'
              'uucp'
          ]
          logLevels: [
              'Debug'
              'Info'
              'Notice'
              'Warning'
              'Error'
              'Critical'
              'Alert'
              'Emergency'
          ]
          name: 'sysLogsDataSource'
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
      azureMonitorMetrics: {
          name: 'azureMonitorMetrics-default'
      }
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-InsightsMetrics'
        ]
        destinations: [
          'azureMonitorMetrics-default'
        ]
      }
      {
        streams: [
          'Microsoft-Syslog'
        ]
        destinations: [
          logAnalyticsWorkspaceName
        ]
      }
    ]
  }
}

output vmDataCollectionRuleId string = vmDataCollectionRule.id
