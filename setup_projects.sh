#!/bin/bash

# --- Configuration ---
URL="https://groups.inf.ed.ac.uk/cup/javaGithub/java_projects.tar.gz"
FILENAME="java_projects.tar.gz"
OUTPUT_DIR="input"
NUM_PROJECTS=50

# --- Script Start ---
set -e # Exit immediately if a command fails

# Step 1: Download the file if it doesn't exist
if [ -f "$FILENAME" ]; then
    echo "✅ '$FILENAME' already exists, skipping download."
else
    echo "🔽 Downloading '$FILENAME'..."
    wget --progress=bar:force -O "$FILENAME" "$URL"
    echo "✅ Download complete."
fi

# Step 2: Get the first 10 unique project names from the archive list.
echo "🔎 Finding the first $NUM_PROJECTS unique projects..."
PROJECT_LIST=$(tar -tf "$FILENAME" | awk -F/ 'NF > 2 {print $3}' | sort -u | head -n "$NUM_PROJECTS")

echo "Selected projects to extract:"
echo "$PROJECT_LIST"
echo "" # Newline for readability

# Step 3: Build the full paths for tar to extract
PATHS_TO_EXTRACT=()
for proj in $PROJECT_LIST; do
    # THE FIX IS HERE: Add the './' prefix to match the archive's path structure
    PATHS_TO_EXTRACT+=("./java_projects/$proj")
done

# Step 4: Create the output directory and extract the selected projects
echo "📦 Creating directory '$OUTPUT_DIR'..."
mkdir -p "$OUTPUT_DIR"

echo "🚀 Extracting selected projects into '$OUTPUT_DIR'..."
tar -xvf "$FILENAME" \
    --strip-components=2 \
    -C "./$OUTPUT_DIR" \
    "${PATHS_TO_EXTRACT[@]}"

echo "✅ Done! Your projects are ready in the '$OUTPUT_DIR' directory."