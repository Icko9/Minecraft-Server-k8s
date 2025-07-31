param roleAssignments array
param targetResourceId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in roleAssignments: {
  name: guid(assignment.principalId, assignment.roleDefinitionId, targetResourceId)
  properties: {
    roleDefinitionId: assignment.roleDefinitionId
    principalId: assignment.principalId
    principalType: 'ServicePrincipal'
  }
}] 
