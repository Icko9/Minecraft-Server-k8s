param name string
param location string

resource pip 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output publicIPAddress string = pip.properties.ipAddress
output publicIPId string = pip.id
