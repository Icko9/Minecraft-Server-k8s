using '../main_sever.bicep'

param location = 'West Europe'
param resourceGroupName = 'rg-minecraft-server-dev'
param environment = 'dev'
param clusterName = 'aks-minecraft-dev-v2'
param nodeCount = 1
param nodeSize = 'Standard_B2s'
param dnsPrefix = 'minecraft-dev'
param storageAccountName = 'minecraftw4xyz2132ts12'
param fileShareName = 'minecraft-world'

param managedIdentities = [
  {
    name: 'mi-minecraft-dev'
    tags: {
      purpose: 'aks-cluster'
      environment: 'dev'
    }
  }
  {
    name: 'minecraft-workload-identity'
    tags: {
      purpose: 'minecraft-workload'
      environment: 'dev'
    }
  }
]

param identityRoleAssignments = [
  {
    resourceType: 'storage'
    principalType: 'workloadIdentity'
    roleDefinitionId: '69566ab7-960f-475b-8e7c-b3118f30c6bd' // Storage File Data Contributor
    description: 'Allow Minecraft workload to access file share'
    storageAccountName: storageAccountName
  }
]
