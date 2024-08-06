#!/bin/bash

# Variables
PROJECT_ID="Your_project_id"
REGION="us-central1"
SERVICE_ACCOUNT_NAME="sec-sa"
SERVICE_ACCOUNT_DISPLAY_NAME="Security Scan Service Account"
SECRET_ID="scan-secret"
USER_EMAIL="utkarsh.pandey@evonence.com"

# Set the project
gcloud config set project $PROJECT_ID

# Create the custom IAM role
gcloud iam roles create SecurityAudit --project $PROJECT_ID \
  --title "Security Audit" \
  --description "Custom role for Security Audit" \
  --permissions "cloudasset.assets.listResource,cloudkms.cryptoKeys.list,cloudkms.keyRings.list,cloudsql.instances.list,cloudsql.users.list,compute.autoscalers.list,compute.backendServices.list,compute.disks.list,compute.firewalls.list,compute.healthChecks.list,compute.instanceGroups.list,compute.instances.getIamPolicy,compute.instances.list,compute.networks.list,compute.projects.get,compute.securityPolicies.list,compute.subnetworks.list,compute.targetHttpProxies.list,container.clusters.list,dns.managedZones.list,iam.serviceAccountKeys.list,iam.serviceAccounts.list,logging.logMetrics.list,logging.sinks.list,monitoring.alertPolicies.list,resourcemanager.hierarchyNodes.listTagBindings,resourcemanager.projects.get,resourcemanager.projects.getIamPolicy,resourcemanager.resourceTagBindings.list,resourcemanager.tagKeys.get,resourcemanager.tagKeys.getIamPolicy,resourcemanager.tagKeys.list,resourcemanager.tagValues.get,resourcemanager.tagValues.getIamPolicy,resourcemanager.tagValues.list,storage.buckets.getIamPolicy,storage.buckets.list,deploymentmanager.deployments.list,dataproc.clusters.list,artifactregistry.repositories.list,composer.environments.list" \
  --stage "GA"

# Create the service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --display-name "$SERVICE_ACCOUNT_DISPLAY_NAME"

# Bind the custom role to the service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="projects/$PROJECT_ID/roles/SecurityAudit"

# Create a temporary file to store the service account key
KEY_FILE=$(mktemp)

# Create the service account key and save it to the temporary file
gcloud iam service-accounts keys create $KEY_FILE \
  --iam-account="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create the secret
gcloud secrets create $SECRET_ID 

# Add the service account key to the secret
gcloud secrets versions add $SECRET_ID --data-file="$KEY_FILE"

# Create the custom role for viewing service account keys
gcloud iam roles create CustomServiceAccountKeyViewer --project $PROJECT_ID \
  --title "Custom Service Account Key Viewer" \
  --description "Custom role for viewing service account keys" \
  --permissions "secretmanager.versions.access" \
  --stage "GA"

# Bind the custom service account key viewer role to the user
gcloud secrets add-iam-policy-binding $SECRET_ID \
  --member="user:$USER_EMAIL" \
  --role="projects/$PROJECT_ID/roles/CustomServiceAccountKeyViewer"

# Clean up the temporary file
rm -f $KEY_FILE

echo "Setup complete. The service account key has been securely added to the secret $SECRET_ID and the temporary key file has been deleted."
