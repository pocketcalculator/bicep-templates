#!/bin/bash

location=<region>
application=<application_name>
repositoryUrl=<github_repository_url>
repositoryBranch=<git_branch>
appLocation=<content_directory>
repositoryToken=<github_personal_access_token>
environment=<environment>
owner=<owner_email_address>
resourceGroupName=rg-$application-$environment-$location
skuName=Standard
skuTier=Standard

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
		"repositoryUrl=$repositoryUrl" \
		"repositoryBranch=$repositoryBranch" \
		"repositoryToken=$repositoryToken" \
		"appLocation=$appLocation" \
		"skuName=$skuName" \
		"skuTier=$skuTier"
echo "Deployment for ${environment} ${application} static web app is complete."