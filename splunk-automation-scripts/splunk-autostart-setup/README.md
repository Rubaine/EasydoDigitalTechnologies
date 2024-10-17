# Splunk Auto-Start Configuration Script

## Description
This script is designed to configure Splunk to automatically start at system boot using `systemd`. It ensures that the service is properly configured to start after each reboot and verifies that it is running.

## Features
- Stops the Splunk service if it is running.
- Disables and then re-enables boot start using `systemd`.
- Verifies the creation of the systemd service file.
- Reloads the daemon, enables the service, and restarts Splunk.

## Prerequisites
- **Splunk** must be installed in your environment.
- **Systemd** must be present on your system (verified by the script).
- The script must be run as root or with `sudo`.

## Usage
To run the script:

```bash
sudo ./splunk_autostart_script.sh
```

## Customizable Variables
- **SPLUNK_BIN**: Modify this variable to specify the path to the Splunk executable if needed (default is `/opt/splunk/bin/splunk`).
- **SERVICE_NAME**: The name of the Splunk service (`Splunkd` by default).

## Notes
- Make sure to verify the correct path to your Splunk installation if it differs from the default.
- This script is intended for Linux environments using `systemd`.

## Disclaimer
This script is provided "as is". Use it at your own risk.

