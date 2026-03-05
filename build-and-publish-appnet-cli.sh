#!/bin/bash

set -e

# Version from setup.py
VERSION=$(grep "VERSION = " src/appnet-preview/setup.py | sed "s/VERSION = '//g" | sed "s/'//g")

# Define wheel file names
PUBLIC_WHEEL="appnet_preview-${VERSION}-py3-none-any.whl"
PRIVATE_WHEEL="appnet_private_preview-${VERSION}-py3-none-any.whl"

echo "=== Building Public Preview Extension ==="
# Transform to public preview and build
./appnet-public-preview.sh
azdev extension build appnet-preview

echo ""
echo "=== Building Private Preview Extension ==="
# Transform to private preview and build
./appnet-private-preview.sh
azdev extension build appnet-preview

echo ""
echo "=== Moving Extensions to Repo Root ==="

# Move wheel files to repo root
echo "Moving public preview wheel: $PUBLIC_WHEEL"
mv dist/$PUBLIC_WHEEL .

echo "Moving private preview wheel: $PRIVATE_WHEEL"
mv dist/$PRIVATE_WHEEL .

echo ""
echo "=== Committing Extensions ==="
git add $PUBLIC_WHEEL $PRIVATE_WHEEL
git commit -m "updating our azure cli extensions"

echo ""
echo "✅ Successfully built and committed both extensions:"
echo "  - Public: $PUBLIC_WHEEL"
echo "  - Private: $PRIVATE_WHEEL"

./appnet-public-preview.sh > /dev/null
