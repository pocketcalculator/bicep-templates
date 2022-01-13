#!/bin/bash

subscription=null
location=eastus2
application=keyvault
environment=prod
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location

keyVaultName=
secretName=
secretValue=

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo keyVaultName = $keyVaultName
echo secretName = $secretName
echo secretValue = $secretValue

echo "Creating deployment for ${environment} ${application} key vault secret..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./keyVaultSecret.bicep \
	--parameters \
		"keyVaultName=$keyVaultName" \
		"secretName=$secretName" \
		"secretValue=$secretValue"
echo "Deployment for ${environment} ${application} key vault secret is complete."