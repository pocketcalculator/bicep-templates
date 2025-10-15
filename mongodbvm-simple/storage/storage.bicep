param location string = resourceGroup().location
param blobStorageAccountName string
param blobContainerName string
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
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }

  resource blobService 'blobServices@2021-06-01' = {
    name: 'default'

    resource blobContainer 'containers@2021-06-01' = {
      name: blobContainerName
      properties: {
        metadata: {
          publicAccess: 'Blob'
        }
      }
    }
  }
}

output blobStorageId string = blobStorage.id
output storageAccountId string = blobStorage.id
output storageAccountName string = blobStorage.name
