// Federated Identity Credential Module
// Links managed identities with Kubernetes service accounts for workload identity

@description('The name of the managed identity')
param managedIdentityName string

@description('The name of the federated credential')
param credentialName string

@description('The OIDC issuer URL (from AKS cluster)')
param issuer string

@description('The Kubernetes service account subject')
param subject string

@description('The audiences for the token exchange')
param audiences array = ['api://AzureADTokenExchange']

// Reference the existing managed identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

// Create the federated identity credential
resource federatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: credentialName
  parent: managedIdentity
  properties: {
    audiences: audiences
    issuer: issuer
    subject: subject
  }
}

output federatedCredentialId string = federatedCredential.id
output federatedCredentialName string = federatedCredential.name 
