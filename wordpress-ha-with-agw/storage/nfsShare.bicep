param location string = resourceGroup().location
param application string
param environment string
var storageAccountName = 'nfsshare${uniqueString(resourceGroup().id)}'
var nfsShareName = 'nfsshare'
var storageAccountSku = 'Premium_ZRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
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
