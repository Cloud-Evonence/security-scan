#!/bin/bash

# Variables
PROJECT_ID="your-project-id"
SERVICE_ACCOUNT_NAME="sec-sa"
SECRET_ID="scan-secret"
USER_EMAIL="chap.utkarsh@gmail.com"

# Set the project
gcloud config set project $PROJECT_ID

# Delete the custom IAM role for Security Audit
gcloud iam roles delete SecurityAudit --project $PROJECT_ID

# Delete the custom IAM role for viewing service account keys
gcloud iam roles delete CustomServiceAccountKeyViewer --project $PROJECT_ID

# Delete the service account
gcloud iam service-accounts delete "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --quiet

# Delete the secret
gcloud secrets delete $SECRET_ID --quiet

echo "Resources deleted: custom IAM roles, service account, and secret."

