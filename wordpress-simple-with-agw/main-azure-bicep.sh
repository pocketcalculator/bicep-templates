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
# Private Endpoint supported only on General Purpose
# mySqlHwName=B_Gen5_1
# mySqlvCoreCapacity=1
# mySqlHwTier=Basic
mySqlHwName=GP_Gen5_2
mySqlvCoreCapacity=2
mySqlHwTier=GeneralPurpose
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
echo mySqlvCoreCapacity = $mySqlvCoreCapacity
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
		"mySqlvCoreCapacity=$mySqlvCoreCapacity" \
		"mySqlAdminLogin=$mySqlAdminLogin" \
		"mySqlAdminPassword=$mySqlAdminPassword"		
echo "Deployment for ${environment} ${application} environment is complete."
