#!/bin/bash

declare -r work_time="1500"
break_counter="0"
break_time="1800"
breaks="4"
prompt=false
wait_minute=true
command_notify_send="/usr/bin/notify-send"


usage() {
  printf "  This program helps managing time using the Pomodoro technique\n"
  printf "    -b, --breaks      Sets the amount of short breaks before a long break\n"
  printf "    -p, --prompt      Enables keyboard interaction to initiate each break\n"
  printf "    -t, --break-time  Sets the time for the long breaks\n"
}


desktop_notification() {
  local icon="$1"
  local message="$2"

  if "$prompt"; then
    message+=" (check prompt)"
  fi

  if [[ -x "$command_notify_send" && "$DESKTOP_SESSION" == "gnome" ]]; then
    "$command_notify_send" \
      --urgency="critical" \
      --app-name="Pomodoro" \
      --icon="/usr/share/icons/gnome/48x48/emotes/$icon.png" \
      --category="presence" \
      "$message"
  fi
}


break_prompt() {
  if "$prompt"; then
    read -p "--:-- Press enter to start break"
    printf "%s Break started\n" "$(date +%H:%M)"
  fi
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
        printf "%s Time to have a long break of %s minutes\n" "$(date +%H:%M)" "$(( break_time / 60 ))"
        desktop_notification "face-cool" "Time to have a long break of $(( break_time / 60 )) minutes"
        break_prompt
        sleep "$break_time"
        break_counter=0
        wait_minute=false

      elif (( breaks_taken >= 0 )); then
        printf "%s Time to have a short break of 5 minutes %s\n" "$(date +%H:%M)" "($break_counter/$breaks)"
        desktop_notification "face-tired" "Time to have a short break of 5 minutes ($break_counter/$breaks)"
        break_prompt
        sleep 300
        wait_minute=false
      fi

      desktop_notification "face-glasses" "Time to work for $timer minutes"

    elif (( work_left > 0 && (minutes % 10) == 0 )); then
      printf "%s Work for %s minutes\n" "$(date +%H:%M)" "$work_left"
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
    -p | --prompt)
      shift
      prompt=true
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
