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
mySqlHwFamily=Gen5
mySqlHwName=B_Gen5_1
mySqlHwTier=Basic
mySqlAdminLogin=mysqldbadmin
mySqlAdminPassword=pA55w0rrD!!!

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo vnetCIDRPrefix = $vnetCIDRPrefix
echo adminUsername = $adminUsername
echo adminPassword = '**********'
echo dbServerName = $dbServerName
echo mySqlHwFamily = $mySqlHwFamily
echo mySqlHwName = $mySqlHwName
echo mySqlHwTier = $mySqlHwTier
echo mySqlAdminLogin = $mySqlAdminLogin
echo mySqlAdminPassword = '************'

echo "Creating deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./main.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"adminUsername=$adminUsername" \
		"adminPassword=$adminPassword" \
		"mySqlHwFamily=$mySqlHwFamily" \
		"mySqlHwName=$mySqlHwName" \
		"mySqlHwTier=$mySqlHwTier" \
		"mySqlAdminLogin=$mySqlAdminLogin" \
		"mySqlAdminPassword=$mySqlAdminPassword"		
echo "Deployment for ${environment} ${application} environment is complete."
