param location string
param application string
param environment string
var amaUserManagedIdentityName = 'mi-${application}-${environment}-${location}'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: amaUserManagedIdentityName
  location: location
}

output managedIdentityId string = managedIdentity.id
output managedIdentityName string = managedIdentity.name


