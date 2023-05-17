param location string = resourceGroup().location
param environment string
param repositoryUrl string
param repositoryBranch string
param appLocation string
param repositoryToken string
param skuName string
param skuTier string
param application string
var staticWebAppName = 'staticwebapp-${application}-${environment}-${location}'

resource symbolicname 'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticWebAppName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    allowConfigFileUpdates: true
    branch: repositoryBranch
    repositoryToken: repositoryToken
    repositoryUrl: repositoryUrl
    buildProperties: {
      appLocation: appLocation
    }
  }
}
