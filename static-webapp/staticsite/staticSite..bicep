resource symbolicname 'Microsoft.Web/staticSites@2021-02-01' = {
  name: 'staticSite'
  location: 'East US 2'
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
  sku: {
    capabilities: [
      {
        name: 'Standard'
        reason: 'string'
        value: 'string'
      }
    ]
    capacity: 1
    family: 'string'
    locations: [
      'string'
    ]
    name: 'string'
    size: 'string'
    skuCapacity: {
      default: int
      elasticMaximum: int
      maximum: int
      minimum: int
      scaleType: 'string'
    }
    tier: 'string'
  }
  kind: 'string'
  identity: {
    type: 'string'
    userAssignedIdentities: {}
  }
  properties: {
    allowConfigFileUpdates: bool
    branch: 'string'
    buildProperties: {
      apiBuildCommand: 'string'
      apiLocation: 'string'
      appArtifactLocation: 'string'
      appBuildCommand: 'string'
      appLocation: 'string'
      githubActionSecretNameOverride: 'string'
      outputLocation: 'string'
      skipGithubActionWorkflowGeneration: bool
    }
    repositoryToken: 'string'
    repositoryUrl: 'string'
    stagingEnvironmentPolicy: 'string'
    templateProperties: {
      description: 'string'
      isPrivate: bool
      owner: 'string'
      repositoryName: 'string'
      templateRepositoryUrl: 'string'
    }
  }
}
