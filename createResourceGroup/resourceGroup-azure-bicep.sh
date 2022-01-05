#!/bin/bash

subscription=''
location=eastus2
application=application
environment=dev

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment

echo "Creating deployment for ${environment} ${application} resource group..."
az deployment sub create \
	--name rg-$application-$environment-$location-deployment \
	--template-file ./resourceGroup.bicep \
	--parameters \
		"location=$location" \
		"application=$application" \
		"environment=$environment" \
	--location $location
echo "Deployment for ${environment} ${application} resource group is complete."