using '../main_sever.bicep'

param location = 'West Europe'
param resourceGroupName = 'rg-minecraft-server-staging'
param environment = 'staging'
param clusterName = 'aks-minecraft-staging'
param nodeCount = 2
param nodeSize = 'Standard_B4ms'
param managedIdentityName = 'mi-minecraft-staging'
param dnsPrefix = 'minecraft-staging'  // Add this line
param storageAccountName = 'minecraftw4xyz21312'  // Make this unique
param fileShareName = 'minecraft-world'
