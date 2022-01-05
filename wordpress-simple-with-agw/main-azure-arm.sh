#!/bin/bash

subscription=''
region=eastus2
application=pocketcalculatorshow
environment=dev
owner=paul.sczurek@outlook.com
resourceGroupName=rg-$application-$environment-$region
vnetName=vnet-$application-$environment-$region
vnetCIDRPrefix=10.0

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo vnetName = $vnetName
echo vnetCIDRPrefix = $vnetCIDRPrefix

echo "Creating deployment for ${environment} ${application} network..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $vnetName-deployment \
	--template-file ./network.bicep \
	--parameters \
		"vnetName=$vnetName" \
		"location=$region"
echo "Deployment for ${environment} ${application} network is complete."
