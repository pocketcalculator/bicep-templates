param location string = resourceGroup().location
param application string
param environment string
param publicSubnetId string
param webServerIP string
param logAnalyticsWorkspaceId string
var agwName = 'agw-${application}-${environment}-${location}'
var agwDiagSetting = 'diag-${agwName}'
var agwPublicIP = 'ip-${agwName}'
// https://github.com/Azure/bicep/issues/1852
var agwId = resourceId('Microsoft.Network/applicationGateways', agwName)

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: agwPublicIP
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: agwName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    enableHttp2: true
    autoscaleConfiguration: {
        minCapacity: 1
        maxCapacity: 10
    }
    gatewayIPConfigurations: [
      {
        name: 'agw-gatewayIPConfig'
        properties: {
          subnet: {
            id: publicSubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'agw-frontEndIPConfig'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'http80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend-web'
        properties: {
          backendAddresses: [
            {
              ipAddress: webServerIP
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'webServerHttp80'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'webHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: '${agwId}/frontendIPConfigurations/agw-frontEndIPConfig'
          }
          frontendPort: {
            id: '${agwId}/frontendPorts/http80'
          }
          protocol: 'Http'
          sslCertificate: null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule-http80'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${agwId}/httpListeners/webHttpListener'
          }
          backendAddressPool: {
            id: '${agwId}/backendAddressPools/backend-web'
          }
          backendHttpSettings: {
            id: '${agwId}/backendHttpSettingsCollection/webServerHttp80'
          }
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      fileUploadLimitInMb: 100
      firewallMode: 'Prevention'
      maxRequestBodySizeInKb: 128
      requestBodyCheck: true
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
      exclusions: [
      ]
      disabledRuleGroups: [
      ]
    }
  }
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGateway
  name: agwDiagSetting
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
