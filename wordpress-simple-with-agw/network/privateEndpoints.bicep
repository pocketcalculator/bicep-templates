param location string
param application string
param environment string
param privateSubnetId string
param dbSubnetId string
param fileShareId string
param mySQLId string

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
}
