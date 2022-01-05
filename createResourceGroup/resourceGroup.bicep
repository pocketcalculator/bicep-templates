param location string
param application string
param environment string
var resourceGroupName = 'rg-${application}-${environment}-${location}'

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}
