@description('The name of the AKS cluster')
param clusterName string
param location string
param nodeCount int
param nodeSize string
param managedIdentityId string
param dnsPrefix string
param nodeResourceGroupName string = '${resourceGroup().name}-AKS'



resource aks 'Microsoft.ContainerService/managedClusters@2023-05-01' = {
    name: clusterName
    location: location
    identity: {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${managedIdentityId}': {}
        }
    }
    properties: {
        dnsPrefix: dnsPrefix
        nodeResourceGroup: nodeResourceGroupName
        oidcIssuerProfile: {
            enabled: true
        }
        securityProfile: {
            workloadIdentity: {
                enabled: true
            }
        }
        agentPoolProfiles: [
            {
                name: 'agentpool'
                count: nodeCount
                vmSize: nodeSize
                mode: 'System'  // Add this line - required for system pool
                osType: 'Linux'  // Add this line - specify OS type
                type: 'VirtualMachineScaleSets'  // Add this line - specify VM type
            }
        ]
    }
}


output aksResourceId string = aks.id
output oidcIssuerUrl string = aks.properties.oidcIssuerProfile.issuerURL
