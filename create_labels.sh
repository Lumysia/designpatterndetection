#!/bin/bash

INPUT_DIR="input"
OUTPUT_FILE="p-mart-output-final.csv"
FILES_PER_PROJECT=3 # How many classes to label from each project

# A small list of patterns to randomly assign.
# We add "None" multiple times to make it more common.
PATTERNS=("Singleton" "Observer" "FactoryMethod" "None" "None" "None" "None")

# --- Script Start ---
set -e # Exit immediately if a command fails

echo "🔎 Finding projects in '$INPUT_DIR'..."

# Create an empty file, overwriting any old one
> "$OUTPUT_FILE"

# Loop through each project directory in the input folder
for project_path in "$INPUT_DIR"/*; do
    if [ -d "$project_path" ]; then
        project_name=$(basename "$project_path")
        echo "   - Processing project: $project_name"

        # Find a few .java files within the project directory
        find "$project_path" -name "*.java" | head -n "$FILES_PER_PROJECT" | while read -r java_file; do
            # Get the class name by removing the path and the .java extension
            class_name=$(basename "$java_file" .java)

            # Pick a random pattern from our list
            random_index=$((RANDOM % ${#PATTERNS[@]}))
            pattern_name=${PATTERNS[$random_index]}

            # Write the final line to our CSV file
            echo "$project_name,$class_name,$pattern_name" >> "$OUTPUT_FILE"
        done
    fi
done

echo "✅ Done! Created '$OUTPUT_FILE' with auto-generated labels."
echo "Example content:"
head -n 5 "$OUTPUT_FILE"