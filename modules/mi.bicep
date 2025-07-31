param location string = resourceGroup().location
param managedIdentities array

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = [for identity in managedIdentities: {
    name: identity.name
    location: location
    tags: contains(identity, 'tags') ? identity.tags : {}
}]

output managedIdentities array = [for i in range(0, length(managedIdentities)): {
    name: mi[i].name
    resourceId: mi[i].id
    principalId: mi[i].properties.principalId
    clientId: mi[i].properties.clientId
}]
