#!/bin/bash

set -e

# Version from setup.py
VERSION=$(grep "VERSION = " src/appnet-preview/setup.py | sed "s/VERSION = '//g" | sed "s/'//g")

# Define wheel file name
WHEEL="appnet_preview-${VERSION}-py3-none-any.whl"

echo "=== Building AppNet Preview Extension ==="
azdev extension build appnet-preview

echo ""
echo "=== Moving Extension to Repo Root ==="

# Move wheel file to repo root
echo "Moving wheel: $WHEEL"
mv dist/$WHEEL .

echo ""
echo "=== Committing Extension ==="
git add $WHEEL
git commit -m "updating appnet preview azure cli extension"

echo ""
echo "✅ Successfully built and committed extension:"
echo "  - $WHEEL"
