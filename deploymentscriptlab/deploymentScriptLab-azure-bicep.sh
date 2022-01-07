#!/bin/bash

templateFile="main.bicep"
today=$(date +"%d-%b-%Y")
deploymentName="deploymentscript-"$today
location=eastus2
application=application
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=learndeploymentscript_exercise_1

az deployment group create \
    --resource-group $resourceGroupName \
    --name $deploymentName \
    --template-file $templateFile