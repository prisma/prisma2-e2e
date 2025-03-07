#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run with a service account JSON file
if [ -z "$FIREBASE_PRIVATE_KEY" ]; then
    echo "Please provide a FIREBASE_PRIVATE_KEY environment variable with the service account key in json format"
    exit 1
fi

# Write the service account key to a file
echo "$FIREBASE_PRIVATE_KEY" > "./privateKey.json"

# Authenticate using the provided service account key file
echo "Authenticating with service account..."
gcloud auth activate-service-account --key-file="./privateKey.json"

# Get the currently authenticated service account email
SERVICE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")

if [ -z "$SERVICE_ACCOUNT" ]; then
    echo "Authentication failed. No active service account found."
    exit 1
fi

echo "Using service account: $SERVICE_ACCOUNT"

# Get list of function names in the region
FUNCTIONS=$(gcloud functions list --project=prisma-e2e-tests-265911 --format="value(name)")

# Delete each function
for FUNCTION in $FUNCTIONS; do
    echo "Deleting function: $FUNCTION"
    gcloud functions delete --project=prisma-e2e-tests-265911 "$FUNCTION" --quiet
done

echo "All functions deleted successfully."