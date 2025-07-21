using '../main_sever.bicep'

param location = 'West Europe'
param resourceGroupName = 'rg-minecraft-server-dev'
param environment = 'dev'
param clusterName = 'aks-minecraft-dev-v2'
param nodeCount = 1
param nodeSize = 'Standard_B2s'
param managedIdentityName = 'mi-minecraft-dev'
param dnsPrefix = 'minecraft-dev'  // Add this line
param storageAccountName = 'minecraftw4xyz2132ts12'  // Make this unique
param fileShareName = 'minecraft-world'
