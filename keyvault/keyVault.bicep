param uniqueSuffix string = uniqueString(resourceGroup().id)
param location string = resourceGroup().location
param application string
param environment string
var keyVaultName = 'kv-${application}${uniqueSuffix}-${environment}-${location}'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: true
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}
