#!/bin/bash

# general azure variables
subscription=null
location=eastus
application=iisdatacollection
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location
vmName=vm3

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo vmName = $vmName

echo "Creating deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./monitoringAgentExtension.bicep \
	--parameters \
    "location=$location" \
		"application=$application" \
		"environment=$environment" \
		"vmName=$vmName"
echo "Deployment for ${environment} ${application} environment is complete."