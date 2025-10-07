#!/bin/bash

set -x

PREVIEW_CLI_URL=https://aka.ms/applink/preview-cli

# Get the final URL after following redirects
final_url=$(curl -Ls -o /dev/null -w '%{url_effective}' "$PREVIEW_CLI_URL")

# Extract the basename and strip query parameters
filename=$(basename "${final_url%%\?*}")

echo "Saving as: $filename"
curl -L "$final_url" -o "$filename"

echo "Installing extension in az"
az extension add --source "$filename"
rm "$filename"