#!/bin/bash

set -x

PRIVATE_PREVIEW_CLI_URL=https://github.com/german1608/azure-cli-extensions/raw/refs/heads/gerobayopaz/appnet-internal/appnet_private_preview-1.0.0b1-py3-none-any.whl

# Get the final URL after following redirects
final_url=$(curl -Ls -o /dev/null -w '%{url_effective}' "$PRIVATE_PREVIEW_CLI_URL")

# Extract the basename and strip query parameters
filename=$(basename "${final_url%%\?*}")

echo "Saving as: $filename"
curl -L "$final_url" -o "$filename"

echo "Installing extension in az"
az extension add --source "$filename" --yes
rm "$filename"
