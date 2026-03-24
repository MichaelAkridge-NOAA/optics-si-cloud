summary: Install Label Studio using an automated script on Google Cloud Workstation
id: labelstudio-script-install
categories: Label Studio, Cloud Workstation, Setup
tags: label-studio, cloud, automation, script
status: Published
authors: Optics SI Team
Feedback Link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools

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

The installation script is located in the `scripts` directory of the optics-si-cloud-tools repository.

**Option 1: Download the script directly** (Recommended)

```bash
# Download the script to your current directory
wget https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/install_label_studio.sh
chmod +x install_label_studio.sh
```

**Option 2: Clone the repository first**

If you prefer to clone the entire repository:

```bash
# Clone the repository
git clone https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools.git

# Navigate to the scripts directory
cd optics-si-cloud-tools/scripts
chmod +x install_label_studio.sh
```

<aside class="warning">
Note: You don't need to clone the repository just to run the script. The direct download method (Option 1) is simpler and faster.
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
- Creates a persistent directory at `~/.label-studio`

### Virtual Environment
- Creates an isolated Python virtual environment
- Installs the latest version of Label Studio

### Startup Configuration
- Creates a startup script at `~/.label-studio/startup.sh` (persists across restarts)
- Adds auto-start fallback to `~/.bashrc`
- Configures Label Studio to:
  - Listen on all network interfaces (0.0.0.0)
  - Run on port 8080
  - Store data in `~/.label-studio/data`
  - Log output to `~/.label-studio/label-studio.log`

### Data Persistence
Cloud Workstations only persist your home directory (`~/`). The script stores everything there:
- All Label Studio data and config: `~/.label-studio/`
- Management commands: `~/.local/bin/` (added to PATH)
- Virtual environment: `~/.label-studio/venv/`
- Activity logs: `~/.label-studio/label-studio.log`

This means your installation, data, and commands survive workstation restarts.

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
Label Studio will automatically start when your workstation boots. Commands like `label-studio-status` persist across restarts.
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

### Set External URL (for CSRF fix)
```bash
label-studio-set-url https://8080-YOUR-HOST.YOUR-CLUSTER.cloudworkstations.dev
```
Sets the Cloud Workstation external URL for CSRF/proxy compatibility. Saves to `~/.label-studio/.env.custom` and restarts automatically.

### Run Diagnostics
```bash
label-studio-diagnostics
```
Shows the auto-detected URL, active config files, hostname, DNS info, and recent log lines. Use this first when troubleshooting CSRF or connectivity issues.

### Update Label Studio
```bash
label-studio-update
```
Updates Label Studio to the latest version.

### Manual Start (if needed)
```bash
cd ~/.label-studio
source venv/bin/activate
label-studio start --host 0.0.0.0 --port 8080 --data-dir ~/.label-studio/data
```

## Troubleshooting
Duration: 3

### Cloud Workstation Port Forwarding Issues

**Problem**: "Unable to forward your request to a backend" or "Couldn't connect to a server on port 8080"

This is the most common issue with Cloud Workstations. Try these steps in order:

**Step 1: Check if Label Studio is actually running**
```bash
label-studio-status
```

**Step 2: Check the logs for errors**
```bash
label-studio-logs
# Press Ctrl+C to exit
# Or view the entire log:
cat ~/.label-studio/label-studio.log
```

**Step 3: Verify Label Studio is listening on the correct interface**
```bash
sudo netstat -tlnp | grep 8080
# If netstat is not available, try:
ps aux | grep label-studio
```

You should see `0.0.0.0:8080` (listening on all interfaces), NOT `127.0.0.1:8080`.

**Step 4: Check if the log file exists and what it says**
```bash
# Find where Label Studio is actually logging
ls -la ~/.label-studio/
# Check if log file exists
if [ -f ~/.label-studio/label-studio.log ]; then
  tail -100 ~/.label-studio/label-studio.log
else
  echo "Log file does not exist - Label Studio may not be starting properly"
fi
```

**Step 5: Manually verify Label Studio can start**
```bash
# Stop any existing processes
pkill -f label-studio
sleep 2

# Try starting Label Studio manually and watch for errors
cd ~/.label-studio
source venv/bin/activate
label-studio start --host 0.0.0.0 --port 8080 --data-dir ~/.label-studio/data
```

This will run in foreground so you can see any errors. If it starts successfully, press `Ctrl+C` and restart with the background command.

**Step 6: Start in background with proper logging**
```bash
cd ~/.label-studio
source venv/bin/activate
nohup label-studio start --host 0.0.0.0 --port 8080 --data-dir ~/.label-studio/data > ~/label-studio.log 2>&1 &

# Wait and check the log
sleep 10
tail -50 ~/label-studio.log

# Test locally
curl -I http://localhost:8080
```

<aside class="positive">
Cloud Workstation port forwarding should work automatically without manual configuration if Label Studio is listening on 0.0.0.0:8080 and responding to HTTP requests.
</aside>

<aside class="positive">
After restarting, wait at least 30 seconds before trying to access through the Cloud Workstation port forwarding URL. Label Studio can take time to fully initialize.
</aside>

### CSRF / 403 Forbidden Error on Login

**Problem**: The login page loads but clicking "Sign In" returns a `403 CSRF verification failed` error.

This happens because Django's CSRF middleware doesn't recognize requests forwarded through the Cloud Workstation proxy.

**Solution 1 — Run diagnostics** to see what URL was auto-detected:
```bash
label-studio-diagnostics
```

This shows:
- Whether Label Studio is running
- What URL the startup script detected
- What's in each config file
- The DNS-detected Cloud Workstation domain

**Solution 2 — Manually set your workstation URL** (most reliable fix):
```bash
# Find your URL: open port 8080 in Cloud Workstations and copy the URL from the browser.
# It looks like: https://8080-w-username-abc123.cluster-xyz456.cloudworkstations.dev

label-studio-set-url https://8080-YOUR-HOSTNAME.YOUR-CLUSTER.cloudworkstations.dev
```

This saves the URL to `~/.label-studio/.env.custom` and restarts Label Studio automatically.

**Solution 3 — Quick manual restart** (to re-run URL auto-detection):
```bash
label-studio-restart
```

The startup script re-detects your workstation URL on every boot via `/etc/resolv.conf` DNS search domains.

<aside class="negative">
The URL changes when a workstation is recreated. If you get 403 errors after recreating your workstation, run `label-studio-set-url` again with the new URL.
</aside>

**How CSRF protection works here:**
The install script sets `USE_ENFORCE_CSRF_CHECKS=0` in `~/.label-studio/.env`. This disables Django's CSRF enforcement using Label Studio's built-in `DisableCSRF` middleware — the same mechanism Label Studio uses for API access. This is safe because Cloud Workstations already enforces access via Google IAM.

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

Common issues in logs:
- **Database locked**: Kill existing processes and restart
- **Permission denied**: Run `sudo chown -R $USER:$USER ~/.label-studio`
- **Module not found**: Reinstall with `source ~/.label-studio/venv/bin/activate && pip install --upgrade label-studio`

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
- [Optics SI Cloud Tools Repository](https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools)

<aside class="positive">
For Docker-based installation, see the "Install Label Studio via Docker" codelab.
</aside>
