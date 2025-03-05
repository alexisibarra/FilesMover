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

  # Check if the source subdirectory exists
  if [ -d "$source_subdir" ]; then
    #Check if the source subdirectory is empty.
    if [[ $(ls -A "$source_subdir") ]]; then
      # Create the target subdirectory if it doesn't exist
      mkdir -p "$target_subdir"

      # Move all contents from source to target
      # The -n option prevents overwriting existing files in the target.
      # The -v option gives verbose output.
      # The --preserve=all option preserves as much as possible of the original files metadata.
      mv -nv "$source_subdir"/* "$target_subdir"

      # Optionally, remove the now-empty source directory
      # If you want to keep the empty directories, remove the next line.
      # if [ "$(ls -A $source_subdir)" ]; then
      #     echo "Source directory $source_subdir is not empty. Review before deleting."
      # else
      #     rmdir "$source_subdir"
      # fi
    else
      echo "Skipping empty source directory: $source_subdir"
    fi
  else
    echo "Source subdirectory '$source_subdir' not found."
  fi
done

echo "Move operation completed."