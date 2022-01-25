#!/bin/bash

subscription=null
location=eastus2
application=application
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location

echo "Creating deployment for ${environment} ${application} NFS share..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./storage.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" 
echo "Deployment for ${environment} ${application} NFS share is complete."