#!/bin/bash

# Set the log file paths
DEBUG_LOG="/var/log/apt_key_debug.log"
ERROR_LOG="/var/log/apt_key_error.log"

# Function to log messages to the debug log
log_debug() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$DEBUG_LOG"
  echo "$message"
}

# Function to log errors to the error log
log_error() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $message" >> "$ERROR_LOG"
  echo "ERROR: $message"
}

# Function to install missing GPG keys
install_missing_keys() {
  local key_id="$1"
  log_debug "Installing missing GPG key: $key_id"
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$key_id" >> "$DEBUG_LOG" 2>> "$ERROR_LOG"
  if [ $? -eq 0 ]; then
    log_debug "Successfully installed missing GPG key: $key_id"
  else
    log_error "Failed to install missing GPG key: $key_id"
  fi
}

# Get the list of NO_PUBKEY errors
errors=$(apt update 2>&1 | grep 'NO_PUBKEY')

# Check if there are any errors
if [ -n "$errors" ]; then
  log_debug "Found NO_PUBKEY errors:"
  log_debug "$errors"
  
  # Iterate through each error and install the missing key
  while read -r line; do
    key_id=$(echo "$line" | awk '{print $NF}')
    install_missing_keys "$key_id"
  done <<< "$errors"
else
  log_debug "No NO_PUBKEY errors found."
fi

echo "Script execution completed. Debug log: $DEBUG_LOG, Error log: $ERROR_LOG"