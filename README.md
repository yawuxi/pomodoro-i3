# Pomodoro Block
A lightweight Pomodoro timer **block for i3blocks** with simple mouse-based controls and configuration.

## Features
- Simple to use.
- Desktop notifications.
- Easily configurable (Each variable can be changed).
- Installation script for easy setup.

## Purpose
This project is designed for users who want a simple, fast, and distraction-free Pomodoro tool without a complex interface or unnecessary features.

## Installation
Download and run the provided installation script from the repository with the path to your i3blocks configuration file. The script will automatically place all required files in the correct locations.

### Automatic installation example
Replace the path after -c with your actual i3blocks configuration file path before running the command.

```bash
curl -o pomodoro-i3-install.sh https://raw.githubusercontent.com/yawuxi/pomodoro-i3/refs/heads/main/install.sh && \
./pomodoro-i3-install.sh -c "/home/USER/.config/i3/i3blocks.conf"
```

## Usage
- Click **left mouse button** to begin your Pomodoro session.
- Click **right mouse button** if you need to completely reset the timer and start fresh with default settings.


## Dependencies
- `i3blocks` — this script works only with i3blocks for i3bar.
- `libnotify` — used for desktop notifications. If you use the installation script, no additional action is needed. If you install manually, run:

```bash
sudo pacman -S libnotify
```

## Contacts
Email: yawuxi@proton.me
Telegram: @yawuxi

