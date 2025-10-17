#!/bin/bash

FILENAME="java_projects.tar.gz"
OUTPUT_DIR="input"
PROJECT_LIST_FILE="target_projects.txt"

# Exit immediately if a command fails
set -e

# Check if the target project list file exists
if [ ! -f "$PROJECT_LIST_FILE" ]; then
    echo "Error: '$PROJECT_LIST_FILE' not found!"
    exit 1
fi

# Clean up old directories to ensure a fresh start
echo "🧹 Cleaning up old 'input' and 'output' directories..."
rm -rf "$OUTPUT_DIR"/*
rm -rf output/*

# Read the project list from the file, filtering out the "Project" header
PROJECTS_TO_EXTRACT=$(cat "$PROJECT_LIST_FILE" | grep -v '^Project$')

# Build the full paths needed for the tar command
PATHS_TO_EXTRACT=()
for proj in $PROJECTS_TO_EXTRACT; do
    # tar requires the full path inside the archive, e.g., ./java_projects/jbehave-core
    PATHS_TO_EXTRACT+=("./java_projects/$proj")
done

# Create the output directory
echo "📦 Creating directory '$OUTPUT_DIR'..."
mkdir -p "$OUTPUT_DIR"

# Extract all projects from the list into the output directory
echo "🚀 Extracting all projects from the list in '$FILENAME' into '$OUTPUT_DIR'..."
tar -xvf "$FILENAME" \
    --strip-components=2 \
    -C "./$OUTPUT_DIR" \
    "${PATHS_TO_EXTRACT[@]}"

# Confirm completion
echo "✅ Success! All target projects are now ready in the '$OUTPUT_DIR' directory."