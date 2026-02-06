#! /usr/bin/bash

pomodoro_data_persistant_directory_path="$HOME/.local/share/pomodoro-i3";
pomodoro_data_tmp_directory_path="/tmp/pomodoro-i3";
pomodoro_config_directory_path="$HOME/.config/pomodoro-i3";

# Retreiving i3blocks config path
i3blocks_config_file_path=;

while getopts c: arg
do
  case $arg in
    c) i3blocks_config_file_path=$OPTARG;;
    ?) printf "Usage: %s [-c absolute or relative config file path]\n" $0; exit 2;;
  esac
done

if [[ -z "$i3blocks_config_file_path" ]]; then
  echo 'Please specify i3blocks config file path';
  printf "Usage: %s [-c absolute or relative config file path]\n" $0; exit 2;
fi

echo "Starting uninstallation of pomodoro-i3..."

# Remove configuration directory
if [[ -d "$pomodoro_config_directory_path" ]]; then
  echo "Removing configuration directory: $pomodoro_config_directory_path"
  rm -rf "$pomodoro_config_directory_path"
fi

# Remove data directory
if [[ -d "$pomodoro_data_persistant_directory_path" ]]; then
  echo "Removing data directory: $pomodoro_data_persistant_directory_path"
  rm -rf "$pomodoro_data_persistant_directory_path"
fi

# Remove temporary directory
if [[ -d "$pomodoro_data_tmp_directory_path" ]]; then
  echo "Removing temporary directory: $pomodoro_data_tmp_directory_path"
  rm -rf "$pomodoro_data_tmp_directory_path"
fi

# Remove pomodoro block from i3blocks config
if [[ -f "$i3blocks_config_file_path" ]]; then
  if grep -q 'pomodoro' "$i3blocks_config_file_path"; then
    echo "Removing pomodoro block from i3blocks config: $i3blocks_config_file_path"
    # Create a backup
    cp "$i3blocks_config_file_path" "$i3blocks_config_file_path.backup"
    echo "Backup created: $i3blocks_config_file_path.backup"

    # Remove the pomodoro block (from [pomodoro] to the next empty line or end of file)
    sed -i '/^\[pomodoro\]/,/^$/d' "$i3blocks_config_file_path"

    echo "Restarting i3..."
    i3-msg -q restart
  else
    echo "No pomodoro block found in i3blocks config"
  fi
fi

echo "Uninstallation completed successfully!"
echo ""
echo "Note: libnotify package was not removed as it may be used by other applications."
echo "If you want to remove it manually, run: sudo pacman -R libnotify"
