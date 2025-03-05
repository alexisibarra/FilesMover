#!/bin/bash

# Source and target directories
SOURCE_DIR="."
TARGET_DIR="/Volumes/AI-Movies/Videos"

# Array of subdirectories to process
SUBDIRS=("Concerts" "DC" "Documentaries" "Movies" "StandUps")

# Loop through each subdirectory
for subdir in "${SUBDIRS[@]}"; do
  source_subdir="$SOURCE_DIR/$subdir"
  target_subdir="$TARGET_DIR/$subdir"

  # echo "Source: $source_subdir"
  # echo "Target: $target_subdir"

  # Check if the source subdirectory exists
  if [ -d "$source_subdir" ]; then

    # Check if the source subdirectory is empty.
    if [[ $(ls -A "$source_subdir") ]]; then

        # Create the target subdirectory if it doesn't exist
        mkdir -p "$target_subdir"
        # echo "Files found: $(shopt -s nullglob; echo "$source_subdir"/*)"

        # Check if there are any files to move by checking the glob expansion
        if [[ -n "$(shopt -s nullglob; echo "$source_subdir"/*)" ]]; then
          # Move all contents from source to target
          mv -nv "$source_subdir"/* "$target_subdir"
        else
            echo "Source subdirectory '$source_subdir' is empty of files. Skipping move."
        fi

    else
        echo "Skipping empty source directory: $source_subdir"
    fi

  else
    echo "Source subdirectory '$source_subdir' not found."
  fi
done

echo "Move operation completed."