param location string
param application string
param environment string
param adminSourceIP string
var bastionNSGName = 'nsg-bastion-${application}-${environment}-${location}'
var frontendNSGName = 'nsg-frontend-${application}-${environment}-${location}'
var applicationNSGName = 'nsg-application-${application}-${environment}-${location}'
var databaseNSGName = 'nsg-database-${application}-${environment}-${location}'

resource bastionNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: bastionNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'sshRule'
        properties: {
          description: 'allow SSH from admin IP only'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: adminSourceIP
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'rdpRule'
        properties: {
          description: 'allow RDP from admin IP only'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: adminSourceIP
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource frontendNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: frontendNSGName
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

resource applicationNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: applicationNSGName
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
      {
        name: 'ssh22Rule'
        properties: {
          description: 'allow access for admin on current IP, port 22 (SSH)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: adminSourceIP
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource databaseNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: databaseNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'mongoDBRule'
        properties: {
          description: 'Allow MongoDB traffic'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '27017'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'sshRule'
        properties: {
          description: 'Allow SSH from admin IP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: adminSourceIP
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

output bastionNSGid string = bastionNetworkSecurityGroup.id
output frontendNSGid string = frontendNetworkSecurityGroup.id
output applicationNSGid string = applicationNetworkSecurityGroup.id
output databaseNSGid string = databaseNetworkSecurityGroup.id
