param location string = resourceGroup().location
param nfsStorageAccountName string
param nfsShareName string
var storageAccountSku = 'Premium_ZRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: nfsStorageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'FileStorage'
  properties: {
    supportsHttpsTrafficOnly: false
  }

  resource fileService 'fileServices@2021-06-01' existing = {
    name: 'default'

    resource fileShare 'shares@2021-06-01' = {
      name: nfsShareName
      properties: {
        enabledProtocols: 'NFS'
        rootSquash: 'NoRootSquash'
        shareQuota: 1024
      }
    }
  }
}

output nfsShareId string = storageAccount.id
