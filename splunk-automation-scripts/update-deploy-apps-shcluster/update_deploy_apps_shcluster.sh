#!/bin/bash

# Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Change these variables according to your environment
SPLUNK_HOME="${SPLUNK_HOME:-/opt/splunk}"
SPLUNK_APPS="${SPLUNK_HOME}/etc/shcluster/apps"
SPLUNK_BACKUP_FOLDER="/home/backup"
SPLUNK_BIN="${SPLUNK_HOME}/bin/splunk"
SPLUNK_HOST="https://xxx.xx:8089"
SPLUNK_USER="spladmin"

# Do not change these variables
SPLUNK_PASS=""
USER_CHOICE=""

# Enable strict error handling
set -e

# Dry run and debug modes
DRY_RUN=false
DEBUG=false
for arg in "$@"; do
  if [[ "$arg" == "--dry-run" ]]; then
    DRY_RUN=true
  elif [[ "$arg" == "--debug" ]]; then
    DEBUG=true
  fi
done

# Functions
log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

log_debug() {
    if $DEBUG; then
        echo -e "${ORANGE}[DEBUG] $1${NC}"
    fi
}

# Command execution wrapper for dry run
run_command() {
    if $DRY_RUN; then
        log_info "Dry run: $*"
    else
        eval "$@"
    fi
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then 
        log_error "This script should be run as root or with sudo"
        exit 1
    fi
}

get_user_choice() {
    log_info "Please choose an option:"
    echo "1. Install App"
    echo "2. Update App"
    read -p "Enter choice [1-2]: " USER_CHOICE
    if [[ "$USER_CHOICE" != "1" && "$USER_CHOICE" != "2" ]]; then
        log_error "Invalid choice. Please enter 1 or 2."
        exit 1
    fi
}

validate_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        exit 1
    fi
}

validate_directory() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        log_error "Folder not found: $dir"
        exit 1
    fi
}

install_app() {
    local app_file=$1
    log_info "Installing app..."
    sleep 1
    log_debug "Moving app to $SPLUNK_APPS"
    run_command mv "$app_file" "$SPLUNK_APPS"
    log_debug "Extracting app..."
    run_command tar -xzf "$SPLUNK_APPS/$(basename $app_file)" -C "$SPLUNK_APPS"
    log_debug "Deleting .tgz app file..."
    run_command rm "$SPLUNK_APPS/$(basename $app_file)"
    log_debug "Setting appropriate permissions for the app files..."
    run_command chown -R splunk:splunk "$SPLUNK_APPS/$(basename $app_file .tgz)"
    run_command chmod -R 755 "$SPLUNK_APPS/$(basename $app_file .tgz)"
    log_info "Applying modifications..."
    run_command $SPLUNK_BIN apply shcluster-bundle --answer-yes -target "$SPLUNK_HOST" -auth "$SPLUNK_AUTH"
}

update_app() {
    local app_file=$1
    local current_app_folder=$2

    log_info "Moving current app folder to backup folder..."
    sleep 1
    backup_path="${SPLUNK_BACKUP_FOLDER}/$(basename $current_app_folder)_$(date +%d-%m-%Y)"
    if [ -d "$backup_path" ]; then
        log_info "Backup folder already exists. Removing the old backup..."
        run_command rm -rf "$backup_path"
    fi
    log_debug "Moving current app folder to backup location..."
    run_command mv "$current_app_folder" "$backup_path"

    install_app "$app_file"
}

main() {
    echo "Created by: Ruben Vieira"
    echo

    sleep 2
    check_root

    read -p "Enter your search head target (default: $SPLUNK_HOST): " user_splunk_host
    SPLUNK_HOST=${user_splunk_host:-$SPLUNK_HOST}
    log_info "Search head target set to: $SPLUNK_HOST"

    read -p "Enter splunk username (default: $SPLUNK_USER): " user_splunk_user
    SPLUNK_USER=${user_splunk_user:-$SPLUNK_USER}
    log_info "Splunk username set to: $SPLUNK_USER"

    read -s -p "Enter splunk password: " SPLUNK_PASS
    echo
    if [ -z "$SPLUNK_PASS" ]; then
        log_error "Password cannot be empty"
        exit 1
    fi
    SPLUNK_AUTH="${SPLUNK_USER}:${SPLUNK_PASS}"

    get_user_choice

    case $USER_CHOICE in
        1)
            log_info "Installing new app"
            sleep 1
            read -p "Enter path to .tgz app file: " app_file
            validate_file "$app_file"
            install_app "$app_file"
            ;;
        2)
            log_info "Updating existing app"
            sleep 1
            read -p "Enter path to the current app folder: " current_app_folder
            validate_directory "$current_app_folder"
            sleep 1
            read -p "Enter path to .tgz app file: " app_file
            validate_file "$app_file"
            update_app "$app_file" "$current_app_folder"
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac

    log_info "Done!"
}

main "$@"
