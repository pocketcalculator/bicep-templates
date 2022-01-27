param location string
param application string
param environment string
param privateSubnetId string
param dbSubnetId string
param fileShareId string
param mySQLId string
param vnetId string
param fileSharePrivateDNSZoneName string = 'privatelink.file.core.windows.net'
param mySQLPrivateDNSZoneName string = 'privatelink.mysql.database.azure.com'
param privateDNSZoneGroupNameStorage string = 'MyStorageZoneGroup'
param privateDNSZoneGroupNameDatabase string = 'MyDatabaseZoneGroup'

resource fileSharePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'nfsSharePrivateEndpoint'
  location: location
  properties: {
    subnet: {
      id: privateSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'file-privateserviceconnection-${application}-${environment}-${location}'
        properties: {
          privateLinkServiceId: fileShareId
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }

  resource Identifier 'privateDnsZoneGroups@2021-05-01' = {
    name: privateDNSZoneGroupNameStorage
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'storage'
          properties: {
            privateDnsZoneId: fileShareDNSZone.id
          }
        }
      ]
    }
  }
}

resource mySQLPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'mySQLPrivateEndpoint'
  location: location
  properties: {
    subnet: {
      id: dbSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'mysql-privateserviceconnection-${application}-${environment}-${location}'
        properties: {
          privateLinkServiceId: mySQLId
          groupIds: [
            'mysqlServer'
          ]
        }
      }
    ]
  }

  resource Identifier 'privateDnsZoneGroups@2021-05-01' = {
    name: privateDNSZoneGroupNameDatabase
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'database'
          properties: {
            privateDnsZoneId: mySQLDNSZone.id
          }
        }
      ]
    }
  }
}

resource fileShareDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: fileSharePrivateDNSZoneName
  location: 'global'

  resource fileSharePrivateDnsZoneVnetLink 'virtualNetworkLinks@2020-06-01' = {
    name: '${fileSharePrivateDNSZoneName}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

resource mySQLDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: mySQLPrivateDNSZoneName
  location: 'global'

  resource mySQLPrivateDnsZoneVnetLink 'virtualNetworkLinks@2020-06-01' = {
    name: '${mySQLPrivateDNSZoneName}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}


