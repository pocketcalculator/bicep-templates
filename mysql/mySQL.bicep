param dbServerName string
param location string = resourceGroup().location
param hwFamily string
param hwName string
param hwTier string
@secure()
param administratorLogin string
@secure()
param administratorLoginPassword string

resource mySQLdb 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: dbServerName
  location: location
  sku: {
    capacity: 1
    family: hwFamily
    name: hwName
    tier: hwTier
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
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
