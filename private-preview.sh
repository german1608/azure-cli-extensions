#!/bin/bash

# Script to transform AppLink files from public to private preview
# Transforms:
# - Microsoft.AppLink -> Private.CloudAppLink
# - 2025-08-01-preview -> 2025-04-01-preview

set -e

# Directory to process
TARGET_DIR="src/applink-preview/azext_applink_preview/aaz/latest"

# Check if the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' not found!"
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
    
    # Check if changes were made
    if ! diff -q "$file" "$file.bak" > /dev/null 2>&1; then
        echo "  ✓ Changes applied"
    else
        echo "  - No changes needed"
    fi
    
    # Remove backup
    rm "$file.bak"
done

echo ""
echo "✅ Transformation completed successfully!"
echo "All files have been transformed to private preview format:"
echo "  - Microsoft.AppLink → Private.CloudAppLink"
echo "  - 2025-08-01-preview → 2025-04-01-preview"
echo ""
echo "To revert these changes, run: ./public-preview.sh"