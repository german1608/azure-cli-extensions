#!/bin/bash

set -x

# Get version from setup.py
VERSION=$(curl -s https://raw.githubusercontent.com/german1608/azure-cli-extensions/gerobayopaz/appnet-public-internal-temp/src/appnet-preview/setup.py | grep "VERSION = " | sed "s/VERSION = '//g" | sed "s/'//g")

APPNET_CLI_URL="https://github.com/german1608/azure-cli-extensions/raw/refs/heads/gerobayopaz/appnet-public-internal-temp/appnet_preview-${VERSION}-py3-none-any.whl"

# Get the final URL after following redirects
final_url=$(curl -Ls -o /dev/null -w '%{url_effective}' "$APPNET_CLI_URL")

# Extract the basename and strip query parameters
filename=$(basename "${final_url%%\?*}")

echo "Saving as: $filename"
curl -L "$final_url" -o "$filename"

echo "Installing extension in az"
az extension add --source "$filename" --yes
rm "$filename"
