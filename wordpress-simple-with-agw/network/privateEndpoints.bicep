param location string
param privateSubnetId string

resource fileSharePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'nfsSharePrivateEndpoint'
  location: location
  properties:{
    subnet: {
      id: privateSubnetId
    }
  }
}
