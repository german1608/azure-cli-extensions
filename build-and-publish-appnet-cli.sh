#!/bin/bash

set -e

# Version from setup.py
VERSION=$(grep "VERSION = " src/appnet-preview/setup.py | sed "s/VERSION = '//g" | sed "s/'//g")

# Define wheel file name
PRIVATE_WHEEL="appnet_private_preview-${VERSION}-py3-none-any.whl"

echo "=== Building Private Preview Extension ==="
# Transform to private preview and build
./appnet-private-preview.sh
azdev extension build appnet-preview
git add src/appnet-preview
if ! git diff --cached --quiet; then
    git commit -m 'Update new aaz modules and commands'
fi

echo ""
echo "=== Moving Extension to Repo Root ==="

# Move wheel file to repo root
echo "Moving private preview wheel: $PRIVATE_WHEEL"
mv dist/$PRIVATE_WHEEL .

echo ""
echo "=== Committing Extension ==="
git add $PRIVATE_WHEEL
git commit -m "updating our azure cli extensions"

echo ""
echo "✅ Successfully built and committed extension:"
echo "  - Private: $PRIVATE_WHEEL"
