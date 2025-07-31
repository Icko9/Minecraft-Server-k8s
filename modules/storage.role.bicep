// Storage Role Assignment Module
// Assigns roles to managed identities for storage accounts

@description('The name of the storage account')
param storageAccountName string

@description('The principal type of the assigned principal ID')
@allowed([
  'ServicePrincipal'
  'User'
  'Group'
])
param principalType string

@description('The principal ID (object ID) of the managed identity')
param principalId string

@description('The role definition ID to assign')
param roleDefinitionId string

// Reference the existing storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Create the role assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, roleDefinitionId)
  scope: storageAccount
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}

output roleAssignmentId string = roleAssignment.id 
