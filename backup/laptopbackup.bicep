param location string = resourceGroup().location

resource paulsczurekbackup 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'paulsczurekbackup'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
    allowBlobPublicAccess: true
    allowCrossTenantReplication: true
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: null
        table: null
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    largeFileSharesState: null
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: null
    supportsHttpsTrafficOnly: true
  }
}

resource paulsczureklaptopbackup 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: 'paulsczurekbackup/default/paulsczureklaptop'
  properties: {
    metadata: {}
    publicAccess: 'Blob'
  }
}
