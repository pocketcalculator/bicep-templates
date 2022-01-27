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
var dbServerName = 'mysqldb-${application}-${environment}-${location}'

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
    storageProfile: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
      storageAutogrow: 'Enabled'
      storageMB: 51200
    }
    version: '5.7'
    createMode: 'Default'
    // For remaining properties, see ServerPropertiesForCreate objects
  }
}

output mySQLId string = mySQLdb.id
