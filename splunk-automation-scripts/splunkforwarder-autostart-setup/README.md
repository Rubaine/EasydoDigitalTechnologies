# Splunk Universal Forwarder Auto-Start Configuration Script

## Description

This script is designed to configure the Splunk Universal Forwarder to automatically start at system boot using `systemd`. It ensures that the service is properly configured to start after each reboot and verifies that it is running.

## Features

- Stops the Splunk Universal Forwarder service if it is running.
- Disables and then re-enables boot start using `systemd`.
- Verifies the creation of the systemd service file.
- Reloads the daemon, enables the service, and restarts the Splunk Universal Forwarder.

## Prerequisites

- **Splunk Universal Forwarder** must be installed in your environment.
- **Systemd** must be present on your system (verified by the script).
- The script must be run as root or with `sudo`.

## Installation

To download and use this script, you have two options:

1. **Clone the Entire Repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

   This will allow you to access all the scripts available in the repository.

2. **Download the Script Directly**:

   If you only need this specific script, you can download it directly from GitHub:

   - Navigate to the script file in the repository on GitHub.
   - Click the **Raw** button.
   - Right-click and choose **Save As** to download the script.

   Alternatively, you can use the following command to download the script directly:

   ```bash
   wget <raw-script-url>
   ```

After downloading the script, make it executable and run it:

```bash
chmod +x splunkforwarder-autostart-setup.sh
sudo ./splunkforwarder-autostart-setup.sh
```

## Usage

To run the script:

```bash
sudo ./splunkforwarder-autostart-setup.sh
```

## Customizable Variables

- **SPLUNK_BIN**: Modify this variable to specify the path to the Splunk Universal Forwarder executable if needed (default is `/opt/splunkforwarder/bin/splunk`).
- **SERVICE_NAME**: The name of the Splunk Universal Forwarder service (`SplunkForwarder` by default).

## Notes

- Make sure to verify the correct path to your Splunk Universal Forwarder installation if it differs from the default.
- This script is intended for Linux environments using `systemd`.

## Disclaimer

This script is provided "as is". Use it at your own risk.

