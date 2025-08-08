#!/bin/bash

location=eastus2
application=application
environment=dev
resourceGroupName=rg-$application-$environment-$location
vmId=
agwId=
mySQLId=
dashboardName=dashboard-$application-$environment-$location

echo location = $location
echo application = $application
echo environment = $environment
echo resourceGroupName = $resourceGroupName
echo vmId = $vmId
echo agwId = $agwId
echo mySQLId = $mySQLId
echo dashboardName = $dashboardName

echo "Creating deployment for ${environment} ${application} dashboard..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-dashboard \
	--template-file ./monitor/dashboard.bicep \
	--parameters \
    "location=$location" \
		"application=$application" \
		"environment=$environment" \
		"vmId=$vmId" \
		"agwId=$agwId" \
		"mySQLId=$mySQLId"
echo "Deployment for ${environment} ${application} dashboard is complete."