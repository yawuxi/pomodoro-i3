#! /usr/bin/bash

pomodoro_data_persistant_directory_path="/usr/share/pomodoro-i3";
pomodoro_data_persistant_file_path="$pomodoro_data_persistant_directory_path/pomodoro-data";
pomodoro_data_tmp_directory_path="/tmp/.pomodoro";
pomodoro_data_tmp_file_path="$pomodoro_data_tmp_directory_path/pomodoro";
pomodoro_data_tmp_link="https://raw.githubusercontent.com/yawuxi/pomodoro-i3/refs/heads/main/pomodoro-data";
pomodoro_data_i3block_script_file_path="$pomodoro_data_persistant_directory_path/pomodoro-i3.sh";
pomodoro_data_i3block_script_link="https://raw.githubusercontent.com/yawuxi/pomodoro-i3/refs/heads/main/pomodoro-i3.sh";

pomodoro_config_directory_path="$HOME/.config/pomodoro-i3";
pomodoro_config_file_path="$pomodoro_config_directory_path/config";
pomodoro_config_link="https://raw.githubusercontent.com/yawuxi/pomodoro-i3/refs/heads/main/pomodoro.conf";

pomodoro_i3block_structure_link="https://raw.githubusercontent.com/yawuxi/pomodoro-i3/refs/heads/main/i3block-structure";

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

# Installing dependencies
sudo pacman -S libnotify

# Initializing configuration and data files
# Creating and fetching user configuration directory and file
mkdir -p "$pomodoro_config_directory_path";
$(curl "$pomodoro_config_link")  > "$pomodoro_config_file_path";

# Creating and fetching creating variable storage in tmp
mkdir -p "$pomodoro_data_tmp_directory_path";
mkdir -p "$pomodoro_data_persistant_directory_path";
$(curl "$pomodoro_data_tmp_link") > "$pomodoro_data_persistant_file_path";
cp "$pomodoro_data_persistant_file_path" "$pomodoro_data_tmp_file_path";

# Creating and fetching i3block script
$(curl "$pomodoro_data_i3block_script_link") > "$pomodoro_data_i3block_script_file_path";
chmod +x "$pomodoro_data_i3block_script_file_path";

if [[ -z $(grep 'pomodoro' "$i3blocks_config_file_path") ]]; then
  $(curl "$pomodoro_i3block_structure_link") >> "$i3blocks_config_file_path";
  sed -i "s|POMODORO_COMMAND|$pomodoro_data_i3block_script_file_path|g" "$i3blocks_config_file_path";
  i3-msg -q restart;
fi
