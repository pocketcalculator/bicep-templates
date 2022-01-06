#!/bin/bash

subscription=null
location=eastus2
application=application
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location
vnetCIDRPrefix=10.0
adminUsername=azureuser
adminPassword=cHanG3-pA55w0rrD!!!

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo vnetCIDRPrefix = $vnetCIDRPrefix
echo adminUsername = $adminUsername
echo adminPassword = '**********'

echo "Creating deployment for ${environment} ${application} network..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./main.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"adminUsername=$adminUsername" \
		"adminPassword=$adminPassword"
echo "Deployment for ${environment} ${application} network is complete."
