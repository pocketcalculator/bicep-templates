#!/bin/bash

# general azure variables
subscription=null
location=eastus2
application=sczurek
environment=dev
owner=pocketcalculatorshow@gmail.com
#resourceGroupName=rg-$application-$environment-$location
resourceGroupName=testPaulSczurek

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName

echo "Creating deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name redisCacheEnterprise-getKeys \
	--template-file ./getKeys.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment"
echo "Deployment for ${environment} ${application} environment is complete."