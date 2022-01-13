#!/bin/bash

subscription=null
location=eastus2
application=
repositoryUrl=
repositoryBranch=main
appLocation=build
repositoryToken=
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location
skuName=Standard
skuTier=Standard

echo subscription = $subscription
echo location = $location
echo application = $application
echo repositoryUrl = $repositoryUrl
echo repositoryBranch = $repositoryBranch
echo appLocation = $appLocation
echo repositoryToken = $repositoryToken

echo skuName = $skuName
echo skuTier = $skuTier
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName

echo "Creating deployment for ${environment} ${application} static web app..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./staticWebApp.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"application=$application" \
		"repositoryUrl=$repositoryUrl" \
		"repositoryBranch=$repositoryBranch" \
		"repositoryToken=$repositoryToken" \
		"appLocation=$appLocation" \
		"skuName=$skuName" \
		"skuTier=$skuTier"
echo "Deployment for ${environment} ${application} static web app is complete."