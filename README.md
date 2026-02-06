# Pomodoro Block
A lightweight Pomodoro timer **block for i3blocks** with simple mouse-based controls and configuration.

## Features
- Simple to use.
- Desktop notifications.
- Easily configurable (Each variable can be changed).
- Installation script for easy setup.

## Purpose
This project is designed for users who want a simple, fast, and distraction-free Pomodoro tool without a complex interface or unnecessary features.

<video src="https://github.com/yawuxi/pomodoro-i3/raw/refs/heads/main/pomodoro-i3-preview.mp4" controls width="100%">
    Your browser does not support the video tag.
</video>

## Installation
Download and run the provided installation script from the repository with the path to your i3blocks configuration file. The script will automatically:
- Check and install dependencies (libnotify) if needed
- Place all required files in user directories (`~/.local/share` and `~/.config`)
- Configure your i3blocks

**No sudo required to run the script!** If dependencies need to be installed, the script will request sudo only for that step.

### Automatic installation example
Replace the path after `-c` with your actual i3blocks configuration file path before running the command.

```bash
curl -o pomodoro-i3-install.sh https://raw.githubusercontent.com/yawuxi/pomodoro-i3/refs/heads/main/install.sh && \
chmod +x ./pomodoro-i3-install.sh && \
./pomodoro-i3-install.sh -c "$HOME/.config/i3/i3blocks.conf"
```

## Usage
- Click **left mouse button** to begin your Pomodoro session.
- Click **right mouse button** if you need to completely reset the timer and start fresh with default settings.


## Dependencies
- `i3blocks` — this script works only with i3blocks for i3bar.
- `libnotify` — used for desktop notifications. The installation script will automatically check and install it if needed.

## Uninstallation
To completely remove pomodoro-i3 and all related files, download and run the uninstall script. It will:
- Remove all configuration files from `~/.config/pomodoro-i3`
- Remove data files from `~/.local/share/pomodoro-i3`
- Remove temporary files from `/tmp/.pomodoro`
- Remove the pomodoro block from your i3blocks config (creates a backup first)
- Restart i3

**Note:** The `libnotify` package will not be removed as it may be used by other applications.

```bash
curl -o pomodoro-i3-uninstall.sh https://raw.githubusercontent.com/yawuxi/pomodoro-i3/refs/heads/main/uninstall.sh && \
chmod +x ./pomodoro-i3-uninstall.sh && \
./pomodoro-i3-uninstall.sh -c "$HOME/.config/i3/i3blocks.conf"
```

## Contacts
Email: yawuxi@proton.me
Telegram: @yawuxi

