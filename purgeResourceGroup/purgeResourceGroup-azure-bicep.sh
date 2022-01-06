#!/bin/bash

subscription=''
location=eastus2
application=application
environment=dev

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment

echo "Purging contents of ${environment} ${application} resource group..."
az deployment group create \
	--mode complete \
	--name rg-$application-$environment-$location-deployment \
	--resource-group rg-$application-$environment-$location \
	--template-file ./rgPurge.bicep
echo "Deployment for ${environment} ${application} resource group is complete."