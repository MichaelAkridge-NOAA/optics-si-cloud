summary: Install Label Studio using an automated script on Google Cloud Workstation
id: labelstudio-script-install
categories: Label Studio, Cloud Workstation, Setup
tags: label-studio, cloud, automation, script
status: Published
authors: Optics SI Team
Feedback Link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud

# Install Label Studio via Script

## Overview
Duration: 2

This codelab walks you through installing Label Studio on a Google Cloud Workstation using an automated installation script. Label Studio is an open-source data labeling tool that supports various data types including images, audio, text, time series, and video.

### What you'll learn
- How to run the automated Label Studio installation script
- Understanding the installation process and configuration
- Accessing Label Studio after installation
- Verifying the installation

### What you'll need
- A Google Cloud Workstation or Linux machine with sudo access
- Internet connectivity
- Basic familiarity with the terminal

## Download the Installation Script
Duration: 2

The installation script is located in the `scripts` directory of the optics-si-cloud repository.

**Option 1: Download the script directly** (Recommended)

```bash
# Download the script to your current directory
wget https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud/main/scripts/install_label_studio.sh
chmod +x install_label_studio.sh
```

**Option 2: Use the cloned repository**

If you have already cloned the repository:

```bash
# Navigate to the scripts directory
cd optics-si-cloud/scripts
chmod +x install_label_studio.sh
```

<aside class="warning">
Note: You don't need to clone the repository just to run the script. The direct download method (Option 1) is simpler.
</aside>

## Run the Installation Script
Duration: 5

Execute the installation script with sudo privileges:

```bash
sudo ./install_label_studio.sh
```

The script will:
1. Detect your user and home directory automatically
2. Check and update system packages
3. Install Python 3 and pip if not already present
4. Create a virtual environment for Label Studio at `~/.label-studio`
5. Install Label Studio in the virtual environment
6. Create management commands (status, restart, stop, logs)
7. Create a startup script that launches Label Studio automatically on workstation boot
8. Start Label Studio on port 8080

<aside class="positive">
The script runs Label Studio as a background service and configures it to start automatically when your workstation boots.
</aside>

<aside class="warning">
You may see GPG key warnings for some apt repositories (like yarn). These warnings are harmless and won't affect the Label Studio installation.
</aside>

## What the Script Does
Duration: 3

The installation script performs the following operations:

### System Setup
- Installs Python 3, pip, and venv packages
- Creates a persistent directory at `/home/user/.label-studio`

### Virtual Environment
- Creates an isolated Python virtual environment
- Installs the latest version of Label Studio

### Startup Configuration
- Creates a startup script at `/etc/workstation-startup.d/50-start-label-studio`
- Configures Label Studio to:
  - Listen on all network interfaces (0.0.0.0)
  - Run on port 8080
  - Store data in `/home/user/.label-studio`
  - Log output to `label-studio.log`

### Data Persistence
The script ensures your data is preserved by:
- Storing all Label Studio data in your home directory
- Using a persistent virtual environment
- Logging all activity for troubleshooting

## Access Label Studio
Duration: 2

Once the installation completes, Label Studio should be accessible:

1. **Local Access**: Navigate to `http://localhost:8080` in your browser

2. **Remote Access**: If accessing from another machine, use your workstation's IP address or hostname:
   ```
   http://your-workstation-ip:8080
   ```

3. **First Login**: On first access, you'll be prompted to create an admin account:
   - Email: Your email address
   - Password: Choose a secure password

<aside class="positive">
Label Studio will automatically start when your workstation boots, so you don't need to manually start it each time.
</aside>

## Verify Installation
Duration: 2

To verify that Label Studio is running correctly:

### Check the Process
```bash
ps aux | grep label-studio
```

You should see the Label Studio process running.

### Check the Logs
```bash
cat /home/user/.label-studio/label-studio.log
```

Look for messages indicating successful startup.

### Test the Web Interface
Navigate to `http://localhost:8080` and verify:
- The login page loads
- You can create an account
- The dashboard is accessible

## Management Commands
Duration: 2

The installation script creates convenient commands to manage Label Studio:

### Check Status
```bash
label-studio-status
```
Shows if Label Studio is running, the process ID, URL, and log location.

### Restart Label Studio
```bash
label-studio-restart
```
Stops and restarts Label Studio. Useful after configuration changes.

### Stop Label Studio
```bash
label-studio-stop
```
Stops the Label Studio service.

### View Logs
```bash
label-studio-logs
```
Displays real-time Label Studio logs. Press `Ctrl+C` to exit.

### Manual Start (if needed)
```bash
cd ~/.label-studio
source venv/bin/activate
label-studio start --host 0.0.0.0 --port 8080 --data-dir ~/.label-studio/data
```

## Troubleshooting
Duration: 3

### GPG Key Warnings During Installation

If you see errors like:
```
W: GPG error: https://dl.yarnpkg.com/debian stable InRelease: 
   The following signatures couldn't be verified because the public key is not available: NO_PUBKEY ...
```

**Solution**: These warnings are harmless and don't affect Label Studio installation. The script will continue and install Label Studio successfully. These errors come from other apt repositories on your system (like yarn, nodejs) and can be safely ignored.

### Label Studio Won't Start

Check the logs:
```bash
label-studio-logs
# Or directly:
cat ~/.label-studio/label-studio.log
```

Check the status:
```bash
label-studio-status
```

Verify the virtual environment:
```bash
ls -la ~/.label-studio/venv
```

### Port 8080 Already in Use

Check what's using the port:
```bash
sudo lsof -i :8080
```

You can modify the port in the startup script:
```bash
sudo nano /etc/workstation-startup.d/50-start-label-studio
# Change --port 8080 to another port like --port 8081
```

Then restart:
```bash
label-studio-restart
```

### Permission Issues

Ensure proper ownership:
```bash
sudo chown -R $USER:$USER ~/.label-studio
```

### Script Fails to Install

Make sure you have sudo access:
```bash
sudo -v
```

Check internet connectivity:
```bash
ping -c 3 pypi.org
```

Verify Python is available:
```bash
python3 --version
```

## Next Steps
Duration: 1

Congratulations! You've successfully installed Label Studio using the automated script.

### What's Next?
- Import your first dataset
- Create a labeling project
- Configure labeling interfaces
- Set up ML-assisted labeling
- Explore Label Studio's integrations

### Additional Resources
- [Label Studio Documentation](https://labelstud.io/guide/)
- [Label Studio GitHub](https://github.com/heartexlabs/label-studio)
- [Optics SI Cloud Repository](https://github.com/MichaelAkridge-NOAA/optics-si-cloud)

<aside class="positive">
For Docker-based installation, see the "Install Label Studio via Docker" codelab.
</aside>
