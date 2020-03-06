#!/bin/bash

declare -r work_time="1500"
break_time="1800"
breaks="4"
break_counter="0"
wait_minute=true

command_notify_send="/usr/bin/notify-send"


usage() {
  printf "  This program helps managing time using the Pomodoro technique\n"
  printf "    -b, --breaks\t\tSets the amount of short breaks before a long break\n"
  printf "    -t, --break-time\t\tSets the time for the long breaks\n"
}


desktop_notification() {
  local icon="$1"
  local message="$2"

  $command_notify_send \
    --urgency="critical" \
    --app-name="Pomodoro" \
    --icon="/usr/share/icons/gnome/48x48/emotes/$icon.png" \
    --category="presence" \
    "$message"
}


pomodoro_timer() {
  local timer=$(( $1 / 60 ))
  wait_minute=true

  for (( minutes=0; minutes <= timer; minutes++ )); do
    local work_left=$(( timer - minutes ))

    if (( work_left == 0 )); then
      (( break_counter++ ))
      local breaks_taken=$(( breaks - break_counter ))

      if (( breaks_taken < 0 )); then
        printf "Time to have a long break of %s minutes\n" "$(( break_time / 60 ))"
        desktop_notification "face-cool" "Time to have a long break of $(( break_time / 60 )) minutes"
        sleep "$break_time"
        break_counter=0
        wait_minute=false

      elif (( breaks_taken >= 0 )); then
        printf "Time to have a short break of 5 minutes %s\n" "($break_counter/$breaks)"
        desktop_notification "face-tired" "Time to have a short break of 5 minutes ($break_counter/$breaks)"
        sleep 300
        wait_minute=false
      fi

      desktop_notification "face-glasses" "Time to work for $timer minutes"

    elif (( work_left > 0 && (minutes % 10) == 0 )); then
      printf "Work for %s minutes\n" "$work_left"
    fi

    if "$wait_minute"; then
      sleep 60
    fi
    done
}


while (( $# > 0 )); do
  case "$1" in
    -b | --breaks)
      shift
      breaks="$1"
      ;;
    -t | --break-time)
      shift
      break_time=$(( $1 * 60 ))
      if (( break_time < 600 )); then
        printf "Long breaks cannot be shorter than 10 minutes\n"
        exit 1
      fi
      ;;
    *)
      usage
      exit 0
      ;;
  esac
  shift
done


printf "Pomodoro timer started\n"
while true; do
  pomodoro_timer "$work_time"
done
