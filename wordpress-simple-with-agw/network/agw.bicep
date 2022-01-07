param location string = resourceGroup().location
param application string
param environment string
param publicSubnetId string
param webServerId string
param webServerIP string
var agwName = 'agw-${application}-${environment}-${location}'
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
      capacity: 1
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
            id: concat(agwId, '/frontendIPConfigurations/agw-frontEndIPConfig')
          }
          frontendPort: {
            id: concat(agwId, '/frontendPorts/http80')
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
            id: concat(agwId, '/httpListeners/webHttpListener')
          }
          backendAddressPool: {
            id: concat(agwId, '/backendAddressPools/backend-web')
          }
          backendHttpSettings: {
            id: concat(agwId, '/backendHttpSettingsCollection/webServerHttp80')
          }
        }
      }
    ]
  }
}