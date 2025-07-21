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
param managedIdentityName string = 'mi-minecraft-${environment}'

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

// Deploy managed identity
module mi './modules/mi.bicep' = {
  name: 'managedIdentity'
  scope: rg
  params: {
    name: managedIdentityName
    location: location
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
    managedIdentityId: mi.outputs.miResourceId
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



// Outputs for other modules or external use
output aksResourceId string = aks.outputs.aksResourceId
output managedIdentityId string = mi.outputs.miResourceId
output managedIdentityPrincipalId string = mi.outputs.miPrincipalId
output staticPublicIP string = pip.outputs.publicIPAddress
