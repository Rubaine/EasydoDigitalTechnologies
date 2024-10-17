#!/bin/bash

# Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
# Change the path to the Splunk binary depending on your installation
SPLUNK_BIN="/opt/splunkforwarder/bin/splunk"
SERVICE_NAME="SplunkForwarder"

# Functions
log_info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Check if user is root
if [ "$(id -u)" -ne 0 ]; then 
    log_error "This script should be run as root or with sudo"
    exit 1
fi

# Check if Splunk command exists
if ! command -v $SPLUNK_BIN &> /dev/null; then
    log_error "Splunk command not found. Please check your installation."
    exit 1
fi

# Check if systemctl exists
if ! command -v systemctl &> /dev/null; then
    log_error "Systemctl command not found. Please check if systemd is installed."
    exit 1
fi

main() {
    echo "Created by: Rubaine"

    # Stop the Universal Forwarder
    log_info "Stopping Splunk Universal Forwarder..."
    if ! $SPLUNK_BIN stop; then
        log_error "Failed to stop Splunk Universal Forwarder."
        exit 1
    fi

    # Disable boot start
    log_info "Disabling boot start..."
    if ! $SPLUNK_BIN disable boot-start; then
        log_error "Failed to disable boot start for Splunk Universal Forwarder."
        exit 1
    fi

    # Enabling boot start
    log_info "Enabling boot start..."
    if ! $SPLUNK_BIN enable boot-start -user root -systemd-managed 1; then
        log_error "Failed to enable boot start for Splunk Universal Forwarder."
        exit 1
    fi

    # Check if systemd service is created correctly
    if [ ! -f /etc/systemd/system/${SERVICE_NAME}.service ]; then
        log_error "Systemd service file has not been created."
        exit 1
    fi
    log_info "Systemd service file created correctly."

    # Reload daemon
    log_info "Reloading daemon..."
    if ! systemctl daemon-reload; then
        log_error "Failed to reload daemon."
        exit 1
    fi

    # Enable service
    log_info "Enabling service..."
    if ! systemctl enable $SERVICE_NAME; then
        log_error "Failed to enable SplunkForwarder service."
        exit 1
    fi

    # Restart service
    log_info "Restarting service..."
    if ! systemctl restart $SERVICE_NAME; then
        log_error "Failed to restart SplunkForwarder service."
        exit 1
    fi

    # Check if running
    log_info "Checking service status..."
    systemctl status $SERVICE_NAME

    log_info "Done!"
}

main