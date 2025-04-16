#!/bin/bash

# Source and target directories
SOURCE_DIR="."
TARGET_DIR="/Volumes/AI-Movies/Videos"

# Array of subdirectories to process
SUBDIRS=("Concerts" "DC" "Documentaries" "Movies" "Series" "StandUps")

# Verbose flag
VERBOSE=false

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Loop through each subdirectory
for subdir in "${SUBDIRS[@]}"; do
  source_subdir="$SOURCE_DIR/$subdir"
  target_subdir="$TARGET_DIR/$subdir"

  if $VERBOSE; then
    echo "Processing subdirectory: $subdir"
    echo "Source: $source_subdir"
    echo "Target: $target_subdir"
  fi

  # Check if the source subdirectory exists
  if [ -d "$source_subdir" ]; then

    # Check if the source subdirectory is empty.
    if [[ $(ls -A "$source_subdir") ]]; then

      # Create the target subdirectory if it doesn't exist
      mkdir -p "$target_subdir"

      # Check if there are any files to move by checking the glob expansion
      if [[ -n "$(shopt -s nullglob; echo "$source_subdir"/*)" ]]; then
        if $VERBOSE; then
            echo "Files found: $(shopt -s nullglob; echo "$source_subdir"/*)"
        fi

        # Move all contents from source to target
        mv -nv "$source_subdir"/* "$target_subdir"
      else
        if $VERBOSE; then
            echo "Source subdirectory '$source_subdir' is empty of files. Skipping move."
        fi
      fi
    else
      if $VERBOSE; then
        echo "Skipping empty source directory: $source_subdir"
      fi
    fi

  else
    if $VERBOSE; then
        echo "Source subdirectory '$source_subdir' not found."
    fi
  fi
done

echo "Move operation completed."
