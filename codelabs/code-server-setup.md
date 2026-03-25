# VS Code Server (code-server) Setup for Cloud Workstations

## Overview

Duration: 3 minutes

This guide installs **code-server**, which runs VS Code in your browser. It's an alternative/supplement to the built-in Cloud Workstation IDE.

### Why use code-server?

- **Lighter:** Less resource usage than the full Workstation IDE
- **Faster:** Quicker startup time
- **Portable:** Access from any device with a browser
- **Alternative:** Useful when the Workstation IDE is unresponsive

### What you'll get

- code-server on **port 8443**
- Pre-installed extensions (Python, Prettier, ESLint, GitLens)
- Management commands: `code-server-start`, `code-server-stop`, etc.

### Prerequisites

- A Google Cloud Workstation
- Terminal access

## Run the Setup Script

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_code_server.sh | bash
```

The script downloads the latest code-server, configures it, and starts it automatically.

## Access code-server

code-server runs on **port 8443**.

### Via Cloud Workstation Port Forwarding

1. Go to the Cloud Workstations console
2. Find your workstation
3. Look for port 8443 in the port forwarding section
4. Click the forwarding URL

Or construct the URL:

```
https://8443-YOUR-WORKSTATION-NAME.CLUSTER.cloudworkstations.dev
```

> **No password required** — Cloud Workstation IAM handles authentication.

## Management Commands

First, reload your shell:

```bash
source ~/.bashrc
```

Then use these commands:

| Command | Description |
|---------|-------------|
| `code-server-start` | Start code-server |
| `code-server-stop` | Stop code-server |
| `code-server-status` | Check if running |
| `code-server-logs` | View logs (tail -f) |

## Installing Extensions

### From command line

```bash
code-server --install-extension ms-python.python
code-server --install-extension esbenp.prettier-vscode
```

### From the UI

1. Open code-server in your browser
2. Click the Extensions icon in the sidebar (or Ctrl+Shift+X)
3. Search and install

> **Note:** code-server uses the [Open VSX Registry](https://open-vsx.org/), not the VS Code Marketplace. Most popular extensions are available.

## Pre-installed Extensions

The setup script installs:

| Extension | Purpose |
|-----------|---------|
| Python | Python language support |
| Prettier | Code formatter |
| ESLint | JavaScript linter |
| GitLens | Git supercharged |

## Configuration

code-server config is at:

```
~/.config/code-server/config.yaml
```

Default settings:

```yaml
bind-addr: 0.0.0.0:8443
auth: none
cert: false
disable-telemetry: true
```

To change settings:

```bash
nano ~/.config/code-server/config.yaml
code-server-stop
code-server-start
```

## Open a Folder

### From the UI

1. File → Open Folder
2. Navigate to your project
3. Click Open

### From command line

```bash
code-server ~/my-project
```

## Persistence

Everything persists across Cloud Workstation restarts:

- **code-server:** `~/.code-server`
- **Extensions:** `~/.code-server/extensions`
- **User data:** `~/.code-server/data`
- **Config:** `~/.config/code-server`

## Cloud Workstation IDE vs code-server

| Feature | Workstation IDE | code-server |
|---------|-----------------|-------------|
| Setup | Pre-installed | Manual |
| Extensions | VS Code Marketplace | Open VSX Registry |
| Performance | Heavier | Lighter |
| Port | 80/443 (default) | 8443 |
| Remote Development | Full support | Basic |

### When to use which?

**Use Workstation IDE for:**
- Remote development features
- Extensions only on VS Code Marketplace
- Full VS Code experience

**Use code-server for:**
- Quick edits
- Lower resource usage
- When Workstation IDE is slow/unresponsive
- Accessing from mobile devices

## Running Multiple Services

code-server can run alongside other services:

| Service | Port |
|---------|------|
| Cloud Workstation IDE | 80/443 |
| Label Studio | 8080 |
| JupyterLab | 8888 |
| code-server | 8443 |

All can run simultaneously with separate port forwarding URLs.

## Troubleshooting

### code-server won't start

Check the logs:

```bash
code-server-logs
```

Or:

```bash
cat ~/.code-server/code-server.log
```

### Port 8443 already in use

Stop any existing code-server:

```bash
code-server-stop
pkill -f code-server
```

Then start again:

```bash
code-server-start
```

### Extensions not working

Some VS Code Marketplace extensions aren't available on Open VSX. Check [open-vsx.org](https://open-vsx.org/) for alternatives.

### Can't save files

Check file permissions:

```bash
ls -la /path/to/your/file
```

code-server runs as your user, so it needs write permissions.

### High memory usage

code-server typically uses 300-500MB RAM. If running low on memory:

1. Close unused tabs
2. Disable unused extensions
3. Consider using the terminal for simple edits

## Updating code-server

Re-run the setup script to get the latest version:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_code_server.sh | bash
```

Or manually:

```bash
code-server-stop
# Download new version
LATEST=$(curl -sL https://api.github.com/repos/coder/code-server/releases/latest | grep tag_name | cut -d'"' -f4 | tr -d 'v')
curl -sL "https://github.com/coder/code-server/releases/download/v${LATEST}/code-server-${LATEST}-linux-amd64.tar.gz" | tar -xz -C ~/.code-server --strip-components=1
code-server-start
```
