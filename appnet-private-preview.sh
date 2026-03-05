#!/bin/bash

# Script to transform AppNet files from public to private preview
# Transforms:
# - Microsoft.AppLink -> Private.CloudAppLink
# - 2025-08-01-preview -> 2025-04-01-preview

set -e

# Directory to process
TARGET_DIR="src/appnet-preview/azext_appnet_preview/aaz/latest"
SETUP_FILE="src/appnet-preview/setup.py"
INIT_FILE="src/appnet-preview/azext_appnet_preview/__init__.py"

# Check if the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' not found!"
    exit 1
fi

# Check if setup.py exists
if [ ! -f "$SETUP_FILE" ]; then
    echo "Error: File '$SETUP_FILE' not found!"
    exit 1
fi

# Check if __init__.py exists
if [ ! -f "$INIT_FILE" ]; then
    echo "Error: File '$INIT_FILE' not found!"
    exit 1
fi

echo "Starting transformation to private preview..."
echo "Processing files in: $TARGET_DIR"

# Find all Python files in the target directory
FILES=$(find "$TARGET_DIR" -name "*.py" -type f)

if [ -z "$FILES" ]; then
    echo "No Python files found in $TARGET_DIR"
    exit 1
fi

# Count total files
TOTAL_FILES=$(echo "$FILES" | wc -l)
echo "Found $TOTAL_FILES Python files to process"

# Process each file
PROCESSED=0
for file in $FILES; do
    PROCESSED=$((PROCESSED + 1))
    echo "[$PROCESSED/$TOTAL_FILES] Processing: $file"

    # Create a backup
    cp "$file" "$file.bak"

    # Perform the transformations using sed
    sed -i 's/Microsoft\.AppLink/Private.CloudAppLink/g' "$file"
    sed -i 's/2025-08-01-preview/2025-04-01-preview/g' "$file"
    sed -i 's/CLIENT_TYPE = "MgmtClient"/CLIENT_TYPE = "AppnetMgmtClient"/g' "$file"

    # Check if changes were made
    if ! diff -q "$file" "$file.bak" > /dev/null 2>&1; then
        echo "  ✓ Changes applied"
    else
        echo "  - No changes needed"
    fi

    # Remove backup
    rm "$file.bak"
done

# Update setup.py to use private preview name
echo "Updating setup.py for private preview..."
cp "$SETUP_FILE" "$SETUP_FILE.bak"
sed -i "s/name='appnet-preview'/name='appnet-private-preview'/g" "$SETUP_FILE"

if ! diff -q "$SETUP_FILE" "$SETUP_FILE.bak" > /dev/null 2>&1; then
    echo "✓ setup.py updated to use 'appnet-private-preview' name"
else
    echo "- setup.py name was already correct"
fi
rm "$SETUP_FILE.bak"

# Update __init__.py to enable INJECT_HEADERS for private preview
echo "Updating __init__.py to enable INJECT_HEADERS..."
cp "$INIT_FILE" "$INIT_FILE.bak"
sed -i 's/INJECT_HEADERS = False/INJECT_HEADERS = True/g' "$INIT_FILE"

if ! diff -q "$INIT_FILE" "$INIT_FILE.bak" > /dev/null 2>&1; then
    echo "✓ __init__.py updated to enable INJECT_HEADERS"
else
    echo "- __init__.py INJECT_HEADERS was already correct"
fi
rm "$INIT_FILE.bak"

echo ""
echo "✅ Transformation completed successfully!"
echo "All files have been transformed to private preview format:"
echo "  - Microsoft.AppLink → Private.CloudAppLink"
echo "  - 2025-08-01-preview → 2025-04-01-preview"
echo "  - CLIENT_TYPE MgmtClient → AppnetMgmtClient"
