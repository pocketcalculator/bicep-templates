param location string = resourceGroup().location
param application string
param environment string
param backupBlobStorageAccountName string
param backupBlobContainerName string

// Common tags
var commonTags = {
  Application: application
  Environment: environment
  CreatedBy: 'Bicep'
  Layer: 'Storage'
}

module storage './storage/storage.bicep' = {
  params: {
    location: location
    blobStorageAccountName: backupBlobStorageAccountName
    blobContainerName: backupBlobContainerName
  }
  name: 'storage-deployment'
}

// Output storage resource information for use by subsequent deployments
output storageAccountName string = storage.outputs.storageAccountName
output storageAccountId string = storage.outputs.storageAccountId
output blobContainerName string = backupBlobContainerName
