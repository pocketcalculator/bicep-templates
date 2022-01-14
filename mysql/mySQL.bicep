param dbName string
param location string = resourceGroup().location
param hwFamily string = 'Gen5'
param hwName string = 'B_Gen5_1'
param hwTier string = 'Basic'

@secure()
param administratorLogin string
@secure()
param administratorLoginPassword string

resource mySQLdb 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: dbName
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
    sslEnforcement: 'Disabled'
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
