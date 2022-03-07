param location string = resourceGroup().location
param application string
param environment string
param mySqlHwFamily string
param mySqlHwName string
param mySqlHwTier string
param mySqlvCoreCapacity int
@secure()
param mySqlAdminLogin string
@secure()
param mySqlAdminPassword string
param logAnalyticsWorkspaceId string
var dbServerName = 'mysqldb-${application}-${environment}-${location}'
var mysqlDiagSetting = 'daig-${dbServerName}'

resource mySQLdb 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: dbServerName
  location: location
  sku: {
    capacity: mySqlvCoreCapacity
    family: mySqlHwFamily
    name: mySqlHwName
    tier: mySqlHwTier
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: mySqlAdminLogin
    administratorLoginPassword: mySqlAdminPassword
    infrastructureEncryption: 'Disabled'
    minimalTlsVersion: 'TLS1_2'
    sslEnforcement: 'Enabled'
    publicNetworkAccess: 'Disabled'
    storageProfile: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
      storageAutogrow: 'Enabled'
      storageMB: 51200
    }
    version: '5.7'
    createMode: 'Default'
  }

  resource mySQLdbConfigurationAuditLog 'configurations@2017-12-01' = {
    name: 'audit_log_enabled'
    properties: {
      value: 'ON'
    }
  }

  resource mySQLdbConfigurationAuditLogEvents 'configurations@2017-12-01' = {
    name: 'audit_log_events'
    properties: {
      value: 'CONNECTION,GENERAL'
    }
  }
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: mySQLdb
  name: mysqlDiagSetting
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'MySqlSlowLogs'
        enabled: true
      }
      {
        category: 'MySqlAuditLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output mySQLId string = mySQLdb.id
