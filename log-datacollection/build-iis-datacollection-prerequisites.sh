#!/bin/bash

# general azure variables
subscription=null
location=eastus
application=iisdatacollection2
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location
vmName=vm4
userManagedIdentity=mi-iisdatacollection2-dev-eastus

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo vmName = $vmName
echo userManagedIdentity = $userManagedIdentity

echo "Creating deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./build-iisDataCollectionPreRequisites.bicep \
	--parameters \
    "location=$location" \
		"application=$application" \
		"environment=$environment" \
		"vmName=$vmName" \
		"userManagedIdentity=$userManagedIdentity"
echo "Deployment for ${environment} ${application} environment is complete."