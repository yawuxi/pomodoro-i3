#! /usr/bin/bash

pomodoro_data_persistant_directory_path="$HOME/.local/share/pomodoro-i3";
pomodoro_data_persistant_file_path="$pomodoro_data_persistant_directory_path/pomodoro-data";
pomodoro_data_tmp_directory_path="/tmp/pomodoro-i3";
pomodoro_data_tmp_file_path="$pomodoro_data_tmp_directory_path/pomodoro-data";

pomodoro_config_directory_path="$HOME/.config/pomodoro-i3";
pomodoro_config_file_path="$pomodoro_config_directory_path/config";

if ! [[ -f "$pomodoro_data_tmp_file_path" ]]; then
  mkdir -p "$pomodoro_data_tmp_directory_path";
  cat "$pomodoro_data_persistant_file_path" > "$pomodoro_data_tmp_file_path";
fi

. "$pomodoro_config_file_path";

color=$work_color;
work_time_seconds=$(( $work_time ));
short_brake_seconds=$(( $short_brake ));
long_brake_seconds=$(( $long_brake ));

# Retrieve current timestamp
function get_current_time() {
  date +%s;
}

#Is pomodoro timer started
function is_started() {
  echo $(( $(awk -F = 'NR==1 {print $2}' "$pomodoro_data_tmp_file_path") && 1));
}

# Retrieve cycle start timestamp
function get_current_cycle_start_time() {
  awk -F = 'NR==2 {print $2}' "$pomodoro_data_tmp_file_path";
}

# Retrieve cycle end timestamp
function get_current_cycle_end_time() {
  awk -F = 'NR==3 {print $2}' "$pomodoro_data_tmp_file_path";
}

#Is pomodoro timer paused
function is_paused() {
  echo $(( $(awk -F = 'NR==4 {print $2}' "$pomodoro_data_tmp_file_path") && 1));
}

#Retrieve pause timestamp
function get_pause_time() {
  awk -F = 'NR==5 {print $2}' "$pomodoro_data_tmp_file_path";
}

#Is pomodoro timer started
function is_short_brake() {
  awk -F = 'NR==6 {print $2}' "$pomodoro_data_tmp_file_path";
}

# Retrieve cycle short brake end timestamp
function get_current_cycle_short_brake_end_time() {
  echo $(( $(get_current_cycle_end_time) + "$short_brake_seconds" ));
}

#Is pomodoro timer long brake activated
function is_long_brake() {
  awk -F = 'NR==7 {print $2}' "$pomodoro_data_tmp_file_path";
}

# Retrieve cycle long brake end timestamp
function get_current_cycle_long_brake_end_time() {
  echo $(( $(get_current_cycle_end_time) + "$long_brake_seconds" ));
}

# Retrieve total cycle counts
function get_cycle_counts() {
  awk -F = 'NR==8 {print $2}' "$pomodoro_data_tmp_file_path";
}

#Listening to mouse events
case "${BLOCK_BUTTON:-0}" in
  # Starting timer
  1) {
    if [[ $(get_current_cycle_start_time) -eq 0 && $(get_current_cycle_end_time) -eq 0 && $(get_cycle_counts) -eq 0 && $(is_paused) -eq 0 ]]; then
      sed -i "s/is_started=[0-9]\+/is_started=1/" "$pomodoro_data_tmp_file_path";
      sed -i "s/start_time=[0-9]\+/start_time=$(get_current_time)/" "$pomodoro_data_tmp_file_path";
      sed -i "s/end_time=[0-9]\+/end_time=$(( $(get_current_time) + $work_time_seconds ))/" "$pomodoro_data_tmp_file_path";
    fi

    if [[ $(is_paused) -eq 1 ]]; then
      pause_duration=$(( $(get_current_time) - $(get_pause_time) ));
      sed -i "s/is_paused=[0-9]\+/is_paused=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/pause_time=[0-9]\+/pause_time=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/is_started=[0-9]\+/is_started=1/" "$pomodoro_data_tmp_file_path";
      sed -i "s/end_time=[0-9]\+/end_time=$(( $(get_current_cycle_end_time) + $pause_duration ))/" "$pomodoro_data_tmp_file_path";
    fi
  };;
  # Pausing/Unpausing timer
  2) {
    if [[ $(is_paused) -eq 0 ]]; then
      sed -i "s/is_paused=[0-9]\+/is_paused=1/" "$pomodoro_data_tmp_file_path";
      sed -i "s/pause_time=[0-9]\+/pause_time=$(get_current_time)/" "$pomodoro_data_tmp_file_path";
      sed -i "s/is_started=[0-9]\+/is_started=0/" "$pomodoro_data_tmp_file_path";
    fi
  };;
  # Stopping timer
  3) {
      sed -i "s/is_started=[0-9]\+/is_started=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/start_time=[0-9]\+/start_time=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/end_time=[0-9]\+/end_time=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/is_paused=[0-9]\+/is_paused=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/pause_time=[0-9]\+/pause_time=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/cycle_count=[0-9]\+/cycle_count=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/is_short_brake=[0-9]\+/is_short_brake=0/" "$pomodoro_data_tmp_file_path";
      sed -i "s/is_long_brake=[0-9]\+/is_long_brake=0/" "$pomodoro_data_tmp_file_path";
  };;
esac

# Cycle end check
if [[ $(get_current_time) -eq $(get_current_cycle_end_time) && $(is_paused) -eq 0 ]]; then
  sed -i "s/cycle_count=[0-9]\+/cycle_count=$(( $(get_cycle_counts) + 1 ))/" "$pomodoro_data_tmp_file_path";
  sed -i "s/start_time=[0-9]\+/start_time=0/" "$pomodoro_data_tmp_file_path";

  if [[ $(( $(get_cycle_counts) % "$cycle_counts" )) -gt 0 ]]; then
    sed -i "s/is_short_brake=0\+/is_short_brake=1/" "$pomodoro_data_tmp_file_path";
    notify-send "$short_brake_start_message";
  fi

  if [[ $(( $(get_cycle_counts) % "$cycle_counts" )) -eq 0 ]]; then
    sed -i "s/is_long_brake=0\+/is_long_brake=1/" "$pomodoro_data_tmp_file_path";
    notify-send "$long_brake_start_message";
  fi
fi

#End of short brake, and starting new cycle
if [[ ( $(( $(get_current_cycle_short_brake_end_time) - $(get_current_time) )) -eq 0 ) && ( $(is_short_brake) -eq 1 ) && ( $(is_paused) -eq 0 ) ]]; then
  sed -i "s/is_short_brake=1\+/is_short_brake=0/" "$pomodoro_data_tmp_file_path";
  sed -i "s/start_time=[0-9]\+/start_time=$(get_current_time)/" "$pomodoro_data_tmp_file_path";
  sed -i "s/end_time=[0-9]\+/end_time=$(( $(get_current_time) + $work_time_seconds ))/" "$pomodoro_data_tmp_file_path";
  notify-send "$short_brake_end_message";
fi

#End of long brake, and starting new cycle
if [[ ( $(( $(get_current_cycle_long_brake_end_time) - $(get_current_time) )) -eq 0 ) && ( $(is_long_brake) -eq 1 ) && ( $(is_paused) -eq 0 ) ]]; then
  sed -i "s/is_long_brake=1\+/is_long_brake=0/" "$pomodoro_data_tmp_file_path";
  sed -i "s/start_time=[0-9]\+/start_time=$(get_current_time)/" "$pomodoro_data_tmp_file_path";
  sed -i "s/end_time=[0-9]\+/end_time=$(( $(get_current_time) + $work_time_seconds ))/" "$pomodoro_data_tmp_file_path";
  notify-send "$long_brake_end_message";
fi

#Rendering different output
if [[ $(is_started) -eq 1 ]]; then
  seconds=$(( $(get_current_cycle_end_time) - $(get_current_time) ));
  remaining_hours=$(( "$seconds" / 60 / 60));
  remaining_minutes=$(( ( "$seconds" % 3600 ) / 60 ));
  remaining_seconds=$(( "$seconds" % 60 ));

  output=$(printf "$work_label %02d:%02d:%02d" \
  "${remaining_hours%.*}" \
  "${remaining_minutes%.*}" \
  "${remaining_seconds%.*}")
else
  output="$start_label";
fi

if [[ $(is_short_brake) -eq 1 ]]; then
  seconds=$(( $(get_current_cycle_short_brake_end_time) - $(get_current_time) ));
  remaining_hours=$(( "$seconds" / 60 / 60));
  remaining_minutes=$(( ( "$seconds" % 3600 ) / 60 ));
  remaining_seconds=$(( "$seconds" % 60 ));

  color="$short_brake_color";
  output=$(printf "$short_brake_label %02d:%02d:%02d" \
  "${remaining_hours%.*}" \
  "${remaining_minutes%.*}" \
  "${remaining_seconds%.*}")
fi

if [[ $(is_long_brake) -eq 1 ]]; then
  seconds=$(( $(get_current_cycle_long_brake_end_time) - $(get_current_time) ));
  remaining_hours=$(( "$seconds" / 60 / 60));
  remaining_minutes=$(( ( "$seconds" % 3600 ) / 60 ));
  remaining_seconds=$(( "$seconds" % 60 ));

  color="$long_brake_color";
  output=$(printf "$long_brake_label %02d:%02d:%02d" \
  "${remaining_hours%.*}" \
  "${remaining_minutes%.*}" \
  "${remaining_seconds%.*}")
fi

if [[ $(is_paused) -eq 1 ]]; then
  seconds=$(( $(get_current_cycle_end_time) - $(get_pause_time) ));

  if [[ $(is_short_brake) -eq 1 ]]; then
    seconds=$(( $(get_current_cycle_short_brake_end_time) - $(get_pause_time) ));
  fi

  if [[ $(is_long_brake) -eq 1 ]]; then
    seconds=$(( $(get_current_cycle_long_brake_end_time) - $(get_pause_time) ));
  fi

  remaining_hours=$(( "$seconds" / 60 / 60));
  remaining_minutes=$(( ( "$seconds" % 3600 ) / 60 ));
  remaining_seconds=$(( "$seconds" % 60 ));

  output=$(printf "$pause_label %02d:%02d:%02d" \
  "${remaining_hours%.*}" \
  "${remaining_minutes%.*}" \
  "${remaining_seconds%.*}")
fi

echo "$output";
echo "$output";
echo "$color";
