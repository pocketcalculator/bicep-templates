#!/bin/bash

subscription=null
location=eastus2
application=application
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location

dbServerName=db-$application-$environment-$location
hwFamily=Gen5
hwName=B_Gen5_1
hwTier=Basic
administratorLogin=mysqldbadmin
administratorLoginPassword=

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo dbServerName = $dbServerName
echo hwFamily = $hwFamily
echo hwName = $hwName
echo hwTier = $hwTier
echo administratorLogin = $administratorLogin
echo administratorLoginPassword = **********

echo "Creating deployment for ${environment} ${application} MySql Server..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./mySQL.bicep \
	--parameters \
		"dbServerName=$dbServerName" \
		"hwFamily=$hwFamily" \
		"hwName=$hwName" \
		"hwTier=$hwTier" \
		"administratorLogin=$administratorLogin" \
		"administratorLoginPassword=$administratorLoginPassword"
echo "Deployment for ${environment} ${application} MySQL Server is complete."