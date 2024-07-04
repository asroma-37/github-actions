#!/bin/bash

# Input: Project ID
PROJECT_ID=$1

# Check if project ID is provided
if [ -z "$PROJECT_ID" ]; then
  echo "Usage: $0 <PROJECT_ID>"
  exit 1
fi

# Authenticate with GCP
echo $GOOGLE_APPLICATION_CREDENTIALS | base64 --decode > /tmp/account.json
gcloud auth activate-service-account --key-file=/tmp/account.json
gcloud config set project $PROJECT_ID

# Define the bucket name
BUCKET_NAME="${PROJECT_ID}-tf-state"

# Create GCS bucket
echo "Creating GCS bucket: gs://$BUCKET_NAME"
gsutil mb -p $PROJECT_ID gs://$BUCKET_NAME

# Define the service account
SERVICE_ACCOUNT="terraform@airman1.iam.gserviceaccount.com"

# Assign roles to the service account
echo "Assigning roles to $SERVICE_ACCOUNT on project $PROJECT_ID"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/iam.serviceAccountAdmin"

echo "Script execution completed."
