param repositoryUrl string
param repositoryBranch string
param staticWebAppName string
param location string
param skuName string
param skuTier string

resource symbolicname 'Microsoft.Web/staticSites@2021-02-01' = {
  name: staticWebAppName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    allowConfigFileUpdates: true
    branch: repositoryBranch
    repositoryToken: 'string'
    repositoryUrl: repositoryUrl
  }
}
