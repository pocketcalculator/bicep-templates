metadata description = 'Creates a general-purpose Azure Key Vault for the subscription with security best practices'

@description('The name of the Key Vault. If not provided, a unique name will be generated.')
param keyVaultName string = 'kv-general-${uniqueString(resourceGroup().id)}'

@description('The location for the Key Vault and all associated resources')
param location string = resourceGroup().location

@description('Tags to apply to all resources')
param tags object = {
  Purpose: 'General Key Vault'
  Environment: 'Production'
  CreatedBy: 'Bicep Template'
}

@description('The pricing tier of the Key Vault')
@allowed(['standard', 'premium'])
param skuName string = 'standard'

@description('Enable RBAC authorization instead of access policies')
param enableRbacAuthorization bool = true

@description('Enable soft delete for the Key Vault')
param enableSoftDelete bool = true

@description('Enable purge protection for the Key Vault')
param enablePurgeProtection bool = true

@description('Number of days to retain deleted vaults')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

@description('Enable template deployment access for ARM/Bicep templates')
param enabledForTemplateDeployment bool = true

@description('Enable disk encryption access for Azure VMs')
param enabledForDiskEncryption bool = false

@description('Enable deployment access for Azure VMs')
param enabledForDeployment bool = false

@description('Disable public network access (recommended for production)')
param publicNetworkAccess string = 'Disabled'

@description('The object ID of the principal that should have full access to the Key Vault')
param principalId string = ''

@description('The principal type (User, Group, or ServicePrincipal)')
@allowed(['User', 'Group', 'ServicePrincipal'])
param principalType string = 'User'

@description('Create a private endpoint for the Key Vault')
param createPrivateEndpoint bool = false

@description('The subnet resource ID for the private endpoint (required if createPrivateEndpoint is true)')
param subnetId string = ''

@description('The private DNS zone resource ID for Key Vault (required if createPrivateEndpoint is true)')
param privateDnsZoneId string = ''

@description('Enable diagnostic settings for the Key Vault')
param enableDiagnostics bool = true

@description('The Log Analytics workspace resource ID for diagnostic logs')
param logAnalyticsWorkspaceId string = ''

@description('Create sample secrets for testing (optional)')
param createSampleSecrets bool = false

@description('The name of a sample secret to create')
param sampleSecretName string = 'sample-secret'

@description('The value of a sample secret (if provided during deployment)')
@secure()
param sampleSecretValue string = ''

// Key Vault resource
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: skuName
    }
    tenantId: subscription().tenantId
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: enableSoftDelete
    enablePurgeProtection: enablePurgeProtection ? true : null
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    publicNetworkAccess: publicNetworkAccess
    accessPolicies: enableRbacAuthorization ? [] : [
      {
        tenantId: subscription().tenantId
        objectId: principalId
        permissions: {
          secrets: ['get', 'list', 'set', 'delete', 'recover', 'backup', 'restore']
          keys: ['get', 'list', 'create', 'delete', 'recover', 'backup', 'restore', 'encrypt', 'decrypt', 'wrapKey', 'unwrapKey', 'sign', 'verify']
        }
      }
    ]
    networkAcls: {
      defaultAction: publicNetworkAccess == 'Disabled' ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

// RBAC role assignment for Key Vault Secrets Officer (if RBAC is enabled and principalId is provided)
resource keyVaultSecretsOfficerRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableRbacAuthorization && !empty(principalId)) {
  scope: keyVault
  name: guid(keyVault.id, principalId, 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Secrets Officer
    principalId: principalId
    principalType: principalType
  }
}

// RBAC role assignment for Key Vault Crypto Officer (if RBAC is enabled and principalId is provided)
resource keyVaultCryptoOfficerRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableRbacAuthorization && !empty(principalId)) {
  scope: keyVault
  name: guid(keyVault.id, principalId, '14b46e9e-c2b7-41b4-b07b-48a6ebf60603')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '14b46e9e-c2b7-41b4-b07b-48a6ebf60603') // Key Vault Crypto Officer
    principalId: principalId
    principalType: principalType
  }
}

// Private endpoint for Key Vault (if enabled)
resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-06-01' = if (createPrivateEndpoint) {
  name: '${keyVaultName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${keyVaultName}-connection'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
  }
}

// Private DNS zone group for the private endpoint
resource keyVaultPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-06-01' = if (createPrivateEndpoint) {
  parent: keyVaultPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'vault'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Diagnostic settings for Key Vault
resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && !empty(logAnalyticsWorkspaceId)) {
  scope: keyVault
  name: '${keyVaultName}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 365
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 365
        }
      }
    ]
  }
}

// Sample secret (if provided)
resource sampleSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (createSampleSecrets && !empty(sampleSecretValue)) {
  parent: keyVault
  name: sampleSecretName
  properties: {
    value: sampleSecretValue
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
  tags: union(tags, {
    SecretType: 'Sample Secret'
  })
}

// Network security group for subnet (if private endpoint is created)
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-06-01' = if (createPrivateEndpoint) {
  name: '${keyVaultName}-nsg'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4000
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// Outputs
@description('The name of the created Key Vault')
output keyVaultName string = keyVault.name

@description('The resource ID of the created Key Vault')
output keyVaultId string = keyVault.id

@description('The URI of the created Key Vault')
output keyVaultUri string = keyVault.properties.vaultUri

@description('The name of the sample secret (if created)')
output sampleSecretName string = createSampleSecrets ? sampleSecretName : ''

@description('Whether sample secrets were created')
output sampleSecretsCreated bool = createSampleSecrets

@description('The private endpoint name (if created)')
output privateEndpointName string = createPrivateEndpoint ? '${keyVaultName}-pe' : ''

@description('The private endpoint ID (if created)')
output privateEndpointId string = createPrivateEndpoint ? keyVaultPrivateEndpoint.id : ''
