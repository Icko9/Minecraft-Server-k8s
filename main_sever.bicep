// main_server.bicep
targetScope = 'subscription'

// Parameters for your Minecraft server deployment
param location string = 'West Europe'
param resourceGroupName string = 'rg-minecraft-server'
param environment string = 'dev'

// AKS Parameters
param clusterName string = 'aks-minecraft-${environment}'
param nodeCount int = 1
param nodeSize string = 'Standard_B4ms'
param dnsPrefix string = 'minecraft-${environment}'

// Managed Identity Parameters
param managedIdentities array
param identityRoleAssignments array = []

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

// Reference the custom-named resource group that AKS will create
resource mcRg 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: '${resourceGroupName}-AKS'
}

// Storage Account Parameters
param storageAccountName string 
param fileShareName string 

// Deploy managed identities
module mi './modules/mi.bicep' = {
  name: 'managedIdentities'
  scope: rg
  params: {
    location: location
    managedIdentities: managedIdentities
  }
}

// Deploy AKS cluster
module aks './modules/aks.bicep' = {
  name: 'aksCluster'
  scope: rg
  dependsOn: [
    mi
  ]
  params: {
    clusterName: clusterName
    location: location
    nodeCount: nodeCount
    nodeSize: nodeSize
    managedIdentityId: mi.outputs.managedIdentities[0].resourceId
    dnsPrefix: dnsPrefix
  }
}

module pip './modules/pip.bicep' = {
  name: 'minecraft-pip'
  scope: mcRg
  dependsOn: [
    aks
  ]
  params: {
    name: 'minecraft-static-ip'
    location: location
  }
}

module storage './modules/storage.bicep' = {
  name: storageAccountName
  scope: rg
  params: {
    location: location
    storageAccountName: storageAccountName
    fileShareName: fileShareName
  }
}

// Deploy role assignments from parameters  
module storageRoleAssignments './modules/storage.role.bicep' = [for (assignment, index) in identityRoleAssignments: if (assignment.resourceType == 'storage') {
  name: 'storage-role-assignment-${index}'
  scope: rg
  dependsOn: [
    storage
    mi
  ]
  params: {
    storageAccountName: contains(assignment, 'storageAccountName') ? assignment.storageAccountName : storageAccountName
    principalId: assignment.principalType == 'workloadIdentity' ? mi.outputs.managedIdentities[1].principalId : mi.outputs.managedIdentities[0].principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: assignment.roleDefinitionId
  }
}]

// Federated credential: Link workload identity with Kubernetes service account
module federatedCredential './modules/federatedcredential.bicep' = {
  name: 'minecraft-federated-credential'
  scope: rg
  dependsOn: [
    aks
    mi
  ]
  params: {
    managedIdentityName: managedIdentities[1].name // workload identity name
    credentialName: 'minecraft-k8s-fedcred'
    issuer: aks.outputs.oidcIssuerUrl
    subject: 'system:serviceaccount:default:minecraft-sa' // Kubernetes service account
  }
}


// Outputs for other modules or external use
output aksResourceId string = aks.outputs.aksResourceId
output managedIdentityId string = mi.outputs.managedIdentities[0].resourceId
output managedIdentityPrincipalId string = mi.outputs.managedIdentities[0].principalId
output workloadIdentityId string = mi.outputs.managedIdentities[1].resourceId
output workloadIdentityPrincipalId string = mi.outputs.managedIdentities[1].principalId
output workloadIdentityClientId string = mi.outputs.managedIdentities[1].clientId
output staticPublicIP string = pip.outputs.publicIPAddress
output storageAccountName string = storageAccountName
