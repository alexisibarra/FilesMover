#!/bin/bash

# === Configuration ===
# Source base directory (usually the current directory)
SOURCE_DIR="."
# Remote server details (REPLACE THESE WITH YOUR ACTUAL VALUES)
REMOTE_USER="your_ssh_username"
REMOTE_HOST="your_remote_hostname_or_ip"
REMOTE_BASE_DIR="/path/to/remote/target/directory" # e.g., /home/user/Videos

# Array of subdirectories to process relative to SOURCE_DIR
SUBDIRS=("Concerts" "DC" "Documentaries" "Movies" "StandUps")

# === Script Logic ===

# Verbose flag
VERBOSE=false

# --- Function Definitions ---

# Function to log messages if VERBOSE is true
log_verbose() {
  if $VERBOSE; then
    echo "[VERBOSE] $1"
  fi
}

# Function to log error messages
log_error() {
  echo "[ERROR] $1" >&2
}

# --- Argument Parsing ---

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose)
      VERBOSE=true
      shift
      ;;
    *)
      log_error "Unknown argument: $1"
      echo "Usage: $0 [--verbose]"
      exit 1
      ;;
  esac
done

# --- Main Processing Loop ---

log_verbose "Starting file transfer process..."
log_verbose "Remote target: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE_DIR}"

# Check if remote user and host are set (basic check)
if [[ "$REMOTE_USER" == "your_ssh_username" ]] || [[ "$REMOTE_HOST" == "your_remote_hostname_or_ip" ]] || [[ "$REMOTE_BASE_DIR" == "/path/to/remote/target/directory" ]]; then
    log_error "Please configure REMOTE_USER, REMOTE_HOST, and REMOTE_BASE_DIR variables in the script."
    exit 1
fi


# Loop through each subdirectory
for subdir in "${SUBDIRS[@]}"; do
  source_subdir="$SOURCE_DIR/$subdir"
  # Ensure remote path doesn't have double slashes if REMOTE_BASE_DIR ends with /
  remote_target_subdir="${REMOTE_BASE_DIR%/}/$subdir"

  log_verbose "Processing subdirectory: '$subdir'"
  log_verbose "Local source: '$source_subdir'"
  log_verbose "Remote target dir: '$remote_target_subdir'"

  # Check if the local source subdirectory exists
  if [ ! -d "$source_subdir" ]; then
    log_verbose "Source subdirectory '$source_subdir' not found. Skipping."
    continue # Skip to the next subdir
  fi

  # Check if the local source subdirectory is empty (ignoring hidden files)
  if ! ls -A "$source_subdir"/* 1>/dev/null 2>&1; then
     log_verbose "Source subdirectory '$source_subdir' is empty or contains no files to move. Skipping."
     continue # Skip to the next subdir
  fi

  # 1. Create the target subdirectory on the remote server via SSH
  log_verbose "Attempting to create remote directory: '$remote_target_subdir'"
  ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p '$remote_target_subdir'"
  if [ $? -ne 0 ]; then
      log_error "Failed to create remote directory '$remote_target_subdir' on $REMOTE_HOST. Check SSH connection and permissions."
      # Decide if you want to stop the script or continue with the next directory
      # For now, we'll log the error and continue
      continue
  fi
  log_verbose "Remote directory check/creation successful."

  # 2. Use rsync to move files
  #    -a: archive mode (recursive, preserves permissions, times, etc.)
  #    -v: verbose (shows files being transferred) - controlled by script's VERBOSE flag
  #    --remove-source-files: deletes files from source after successful transfer (mimics mv)
  #    --progress: show transfer progress
  #    Source path ends with '/' to copy contents, not the directory itself.
  #    Target path specifies the remote user, host, and directory.
  log_verbose "Starting rsync transfer for '$source_subdir'..."
  rsync_opts="-a --remove-source-files --progress"
  if $VERBOSE; then
      rsync_opts+=" -v"
  fi

  # Use eval to correctly handle spaces in paths if any (though less likely here)
  # Ensure quoting is correct for the remote path specification
  eval rsync $rsync_opts "\"$source_subdir/\"" "\"$REMOTE_USER@$REMOTE_HOST:'$remote_target_subdir/'\""

  # Check rsync exit status
  rsync_status=$?
  if [ $rsync_status -eq 0 ]; then
    log_verbose "Successfully transferred and removed files from '$source_subdir'."
  else
    log_error "rsync transfer failed for '$source_subdir' with exit code $rsync_status."
    log_error "Source files in '$source_subdir' were NOT removed due to the error."
    # Consider adding more robust error handling here if needed
  fi

done

echo "Remote move operation completed."
