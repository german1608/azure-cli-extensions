#!/bin/bash

# Build wheel file
azdev extension build applink-preview

STORAGE_ACCOUNT=applinkpreviewcli # or any other where you wish to publish
STORAGE_CONTAINER=applink-preview-cli # or any other where you wish to publish
STORAGE_BLOB_NAME=applink_preview-1.0.0b1-py3-none-any.whl

# Upload the blob to the storage account using azure cli
# You may need to update the --name and --file arguments when releasing a new version
# --name should be the name of your wheel file
# and --file is the relative path
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $STORAGE_CONTAINER \
  --name $STORAGE_BLOB_NAME \
  --file dist/applink_preview-1.0.0b1-py3-none-any.whl \
  --overwrite
