# Splunk App Management Script

## Description

This script is designed to help manage Splunk apps in a Search Head Cluster environment. It provides functionality to either install a new app or update an existing app by automating the necessary steps, such as moving files, extracting them, setting permissions, and applying changes to the cluster.

## Features

- **Install a New App**: Moves the app package to the Splunk apps directory, extracts it, and applies necessary configurations.
- **Update an Existing App**: Backs up the current version of the app, then installs the new version and applies changes to the cluster.
- **Dry Run Mode**: Allows testing the script without making any changes by using the `--dry-run` option.
- **Debug Mode**: Provides detailed output of script actions by using the `--debug` option.

## Prerequisites

- **Splunk** must be installed in your environment and properly configured.
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
chmod +x shcluster-app-management.sh
sudo ./shcluster-app-management.sh
```

## Usage

To run the script:

```bash
sudo ./shcluster-app-management.sh
```

You can also use the `--dry-run` option to test the script without executing any commands:

```bash
sudo ./shcluster-app-management.sh --dry-run
```

If you want detailed output for debugging purposes, use the `--debug` option:

```bash
sudo ./shcluster-app-management.sh --debug
```

Both `--dry-run` and `--debug` options can be used together:

```bash
sudo ./shcluster-app-management.sh --dry-run --debug
```

## Customizable Variables

- **SPLUNK_HOME**: The path to the Splunk installation directory (default is `/opt/splunk`).
- **SPLUNK_APPS**: The directory where Splunk apps are stored (default is `$SPLUNK_HOME/etc/shcluster/apps`).
- **SPLUNK_BACKUP_FOLDER**: The directory where backups of existing apps will be stored (default is `/home/backup`).
- **SPLUNK_BIN**: The path to the Splunk executable (default is `$SPLUNK_HOME/bin/splunk`).
- **SPLUNK_HOST**: The URL of the search head (default is `https://xxx.xx:8089`).
- **SPLUNK_USER**: The Splunk user for authentication (default is `spladmin`).

## Notes

- Make sure to verify the correct path to your Splunk installation if it differs from the default.
- This script is intended for Linux environments using `systemd`.
- Use the `--dry-run` option if you want to test the behavior without making any actual changes.
- The `--debug` option provides additional insight into the internal operations of the script.

## Disclaimer

This script is provided "as is". Use it at your own risk. Always test in a non-production environment before using it in a production setting.

