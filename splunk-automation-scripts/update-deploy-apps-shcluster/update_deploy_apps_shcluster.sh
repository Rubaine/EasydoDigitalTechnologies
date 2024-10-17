#!/bin/bash

# Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SPLUNK_HOME="/opt/splunk"
SPLUNK_APPS="${SPLUNK_HOME}/etc/shcluster/apps"
SPLUNK_BACKUP_FOLDER="/home/splunkkit/backup"
SPLUNK_BIN="${SPLUNK_HOME}/bin/splunk"
SPLUNK_HOST="https://sh1.easydo.co:8089"
SPLUNK_USER="spladmin"
SPLUNK_PASS=""
USER_CHOICE=""

# Enable strict error handling
set -e

# Functions
log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

log_debug() {
    echo -e "${ORANGE}[DEBUG] $1${NC}"
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then 
        log_error "This script should be run as root or with sudo"
        exit 1
    fi
}

get_user_choice() {
    log_debug "Please choose an option:"
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
    log_info "Moving app to $SPLUNK_APPS"
    sleep 1
    mv $app_file $SPLUNK_APPS
    if [ $? -ne 0 ]; then
        log_error "Failed to move app file"
        exit 1
    fi
    log_info "Extracting app..."
    sleep 1
    tar -xzf "$SPLUNK_APPS/$(basename $app_file)" -C $SPLUNK_APPS
    if [ $? -ne 0 ]; then
        log_error "Failed to extract app file"
        exit 1
    fi
    log_info "Deleting .tgz app file..."
    sleep 1
    rm "$SPLUNK_APPS/$(basename $app_file)"
    log_info "Applying modifications..."
    sleep 1
    $SPLUNK_BIN apply shcluster-bundle --answer-yes -target $SPLUNK_HOST -auth $SPLUNK_AUTH
}

update_app() {
    local app_file=$1
    local current_app_folder=$2

    log_info "Moving current app folder to backup folder..."
    sleep 1
    backup_path="${SPLUNK_BACKUP_FOLDER}/$(basename $current_app_folder)_$(date +%d-%m-%Y)"
    if [ -d "$backup_path" ]; then
        log_info "Backup folder already exists. Removing the old backup..."
        rm -rf "$backup_path"
        if [ $? -ne 0 ]; then
            log_error "Failed to remove old backup folder"
            exit 1
        fi
    fi
    mv "$current_app_folder" "$backup_path"
    if [ $? -ne 0 ]; then
        log_error "Failed to move current app folder"
        exit 1
    fi

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
            log_debug "Installing new app"
            sleep 1
            read -p "Enter path to .tgz app file: " app_file
            validate_file "$app_file"
            install_app "$app_file"
            ;;
        2)
            log_debug "Updating existing app"
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

main
