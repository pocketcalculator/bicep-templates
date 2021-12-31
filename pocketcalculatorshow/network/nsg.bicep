param location string
param application string
param environment string
var bastionNSGName = 'nsg-bastion-${application}-${environment}-${location}'
var webNSGName = 'nsg-web-${application}-${environment}-${location}'
var appNSGName = 'nsg-app-${application}-${environment}-${location}'
var dbNSGName = 'nsg-db-${application}-${environment}-${location}'

resource bastionNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: bastionNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'sshRule'
        properties: {
          description: 'allow all inbound on port 22 (SSH)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'rdpRule'
        properties: {
          description: 'allow all inbound on port 3389 (RDP)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource webNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: webNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'http80Rule'
        properties: {
          description: 'allow all inbound on port 80 (HTTP)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'http443Rule'
        properties: {
          description: 'allow all inbound on port 443 (HTTPS)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource appNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: appNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'http80Rule'
        properties: {
          description: 'allow all inbound on port 80 (HTTP)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'http443Rule'
        properties: {
          description: 'allow all inbound on port 443 (HTTPS)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'http8080Rule'
        properties: {
          description: 'allow all inbound on port 8080 (HTTPS)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource dbNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: dbNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'mySQLRule'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

output bastionNSGid string = bastionNetworkSecurityGroup.id
output webNSGid string = webNetworkSecurityGroup.id
output appNSGid string = appNetworkSecurityGroup.id
output dbNSGid string = dbNetworkSecurityGroup.id
