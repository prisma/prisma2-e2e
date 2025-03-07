#!/bin/bash

# Exit on error
set -e

# Take argument from command line
FN_RESOURCE_GROUP=$1 # prisma-e2e-windows or prisma-e2e-linux

# Check if the argument is valid
if [ -z "$FN_RESOURCE_GROUP" ]; then
    echo "Usage: $0 <resource-group>"
    echo "Usually <resource-group> is either prisma-e2e-windows or prisma-e2e-linux"
    exit 1
fi

# Ensure the user is logged in
if ! az account show > /dev/null 2>&1; then
    echo "You are not logged into Azure. Please run 'az login' first."
    exit 1
fi

# Get the subscription ID
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
echo "Using subscription: $SUBSCRIPTION_ID"

# Get all Function Apps in the current subscription
echo "Fetching all Function Apps in resource group $FN_RESOURCE_GROUP..."
FUNCTION_APPS=$(az functionapp list --resource-group $FN_RESOURCE_GROUP --query "[].{name:name, resourceGroup:resourceGroup, appInsights:appInsights}" -o json)

# Check if there are any function apps
if [ "$FUNCTION_APPS" == "[]" ]; then
    echo "No Function Apps found in the subscription."
    exit 0
fi

# Loop through each function app and delete it along with Application Insights
echo "Deleting all Function Apps and their associated Application Insights..."
echo "$FUNCTION_APPS" | jq -c '.[]' | while IFS= read -r app; do
    NAME=$(echo "$app" | jq -r '.name')
    RESOURCE_GROUP=$(echo "$app" | jq -r '.resourceGroup')

    # Get Application Insights instance name
    APP_INSIGHTS_NAME=$(az webapp show --name "$NAME" --resource-group "$RESOURCE_GROUP" --query "siteConfig.appInsightsKey" -o tsv)

    echo "Deleting Function App: $NAME (Resource Group: $RESOURCE_GROUP)..."
    az functionapp delete --name "$NAME" --resource-group "$RESOURCE_GROUP"

    if [ -n "$APP_INSIGHTS_NAME" ]; then
        echo "Deleting Application Insights: $APP_INSIGHTS_NAME (Resource Group: $RESOURCE_GROUP)..."
        az resource delete --resource-group "$RESOURCE_GROUP" --name "$APP_INSIGHTS_NAME" --resource-type "Microsoft.Insights/components"
    fi
done

echo "All Function Apps and their related Application Insights have been deleted."