#!/bin/bash

subscription=null
location=eastus2
application=www.pocketcalculator.io
staticWebAppName=www.pocketcalculator.io
repositoryUrl='https://github.com/pocketcalculator/pocketcalculator.io'
repositoryBranch=main
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location
skuName=Standard
skuTier=Standard

echo subscription = $subscription
echo location = $location
echo application = $application
echo staticWebAppName = $staticWebAppName
echo repositoryUrl = $repositoryUrl
echo repositoryBranch = $repositoryBranch
echo skuName = $skuName
echo skuTier = $skuTier
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName

echo "Creating deployment for ${environment} ${application} static web app..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./main.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
"subscription=$subscription"
"application=$application"
echo staticWebAppName = $staticWebAppName
echo repositoryUrl = $repositoryUrl
echo repositoryBranch = $repositoryBranch
echo skuName = $skuName
echo skuTier = $skuTier
echo "Deployment for ${environment} ${application} network is complete."