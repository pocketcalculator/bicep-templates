#!/bin/bash

subscription=null
location=eastus2
application=keyvault
environment=prod
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName

echo "Creating deployment for ${environment} ${application} key vault..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./keyVault.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"application=$application" 
echo "Deployment for ${environment} ${application} key vault is complete."