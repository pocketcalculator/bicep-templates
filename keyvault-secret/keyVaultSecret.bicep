param keyVaultName string
param secretName string
param secretValue string
var keyVaultSecretName = '${keyVaultName}/${secretName}'

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: keyVaultSecretName
  properties: {
    value: secretValue
    contentType: 'text/plain'
  }
}
