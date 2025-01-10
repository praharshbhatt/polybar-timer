#!/bin/bash

# Timer storage
TIMER_FILE="$HOME/.config/polybar/scripts/timers.json"
mkdir -p "$(dirname "$TIMER_FILE")"
touch "$TIMER_FILE"

# Default format for timers
if [ ! -s "$TIMER_FILE" ]; then
  echo '{}' > "$TIMER_FILE"
fi

# Notify function
notify() {
  notify-send "Timer" "$1"
}

# Show menu to manage timers
show_menu() {
  local choices=("Create Timer" "View Timers" "Delete Timer" "Quit")
  local choice=$(printf '%s\n' "${choices[@]}" | rofi -dmenu -p "Timer Options")

  case "$choice" in
    "Create Timer") create_timer ;;
    "View Timers") view_timers ;;
    "Delete Timer") delete_timer ;;
    "Quit") exit 0 ;;
  esac
}

# Create a timer
create_timer() {
  local name=$(rofi -dmenu -p "Timer Name")
  [ -z "$name" ] && exit 0

  local duration=$(rofi -dmenu -p "Duration (minutes)")
  [ -z "$duration" ] && exit 0

  if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
    notify "Invalid duration. Please enter a number."
    return
  fi

  local end_time=$(( $(date +%s) + duration * 60 ))
  jq --arg name "$name" --argjson end_time "$end_time" '. + {($name): $end_time}' "$TIMER_FILE" > "${TIMER_FILE}.tmp" && mv "${TIMER_FILE}.tmp" "$TIMER_FILE"
  notify "Timer '$name' set for $duration minutes."
}

# View active timers
view_timers() {
  local now=$(date +%s)
  local timers=$(jq -r 'to_entries[] | "\(.key): \((.value - '"$now"') / 60 | floor) minutes left"' "$TIMER_FILE")
  [ -z "$timers" ] && timers="No active timers."
  echo "$timers" | rofi -dmenu -p "Active Timers"
}

# Delete a timer
delete_timer() {
  local timer_list=$(jq -r 'keys[]' "$TIMER_FILE")
  [ -z "$timer_list" ] && notify "No timers to delete." && return

  local timer=$(echo "$timer_list" | rofi -dmenu -p "Delete Timer")
  [ -z "$timer" ] && exit 0

  jq "del(.\"$timer\")" "$TIMER_FILE" > "${TIMER_FILE}.tmp" && mv "${TIMER_FILE}.tmp" "$TIMER_FILE"
  notify "Timer '$timer' deleted."
}

# Check for expired timers
check_expired_timers() {
  local now=$(date +%s)
  local expired=$(jq -r 'to_entries[] | select(.value <= '"$now"') | .key' "$TIMER_FILE")

  for timer in $expired; do
    notify "Timer '$timer' has ended."
    jq "del(.\"$timer\")" "$TIMER_FILE" > "${TIMER_FILE}.tmp" && mv "${TIMER_FILE}.tmp" "$TIMER_FILE"
  done
}

# Main function
main() {
  check_expired_timers

  case "$1" in
    --menu) show_menu ;;
    --status)
      local now=$(date +%s)
      local timer_count=$(jq -r 'keys | length' "$TIMER_FILE")
      
      if [ "$timer_count" -eq 0 ]; then
        echo "No timers"
      else
        local next_timer=$(jq -r 'to_entries | sort_by(.value) | .[0] | "\(.key): \((.value - '"$now"') / 60 | floor) minutes"' "$TIMER_FILE")
        echo "$next_timer"
      fi
      ;;
    *) echo "Usage: $0 [--menu|--status]" ;;
  esac
}

main "$@"

