param location string = resourceGroup().location
param blobStorageAccountName string
param logAnalyticsStorageAccountName string
var storageAccountSku = 'Standard_LRS'

resource blobStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: blobStorageAccountName
  location: location
  sku: {
    name: storageAccountSku
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
        file: null
        queue: null
        table: null
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    largeFileSharesState: null
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: false
  }

  resource blobService 'blobServices@2021-06-01' = {
    name: 'default'

    resource backupContainer 'containers@2021-06-01' = {
      name: 'backup'
      properties: {
        metadata: {
          publicAccess: 'Blob'
        }
      }
    }

    resource letsEncryptContainer 'containers@2021-06-01' = {
      name: 'letsencrypt'
      properties: {
        metadata: {
          publicAccess: 'Blob'
        }
      }
    }
  }
}

resource logAnalyticsStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: logAnalyticsStorageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
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
        file: null
        queue: null
        table: null
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    largeFileSharesState: null
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: false
  }
}

output blobArchiveId string = blobStorage.id
output logAnalyticsId string = logAnalyticsStorage.id
