param location string = resourceGroup().location
param name string


resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
    name: name
    location: location
}

output miName string = mi.name
output miResourceId string = mi.id
output miPrincipalId string = mi.properties.principalId
