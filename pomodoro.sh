#!/bin/bash

declare -r work_time="1500"
break_counter="0"
break_time="1800"
breaks="4"
command_notify_send="/usr/bin/notify-send"
icon_break_over="face-glasses"
icon_long_break="face-cool"
icon_short_break="face-tired"
interactive=false
wait_minute=true


usage() {
  printf "This program helps managing time using the Pomodoro technique\n"
  printf "  -b, --breaks      Sets the amount of short breaks before a long break\n"
  printf "  -i, --interactive Enables interactive options before each break\n"
  printf "  -t, --break-time  Sets the time in minutes for the long breaks\n"
}


desktop_notification() {
  local icon="$1"
  local message="$2"

  if [[ "$interactive" == true && "$icon" != "$icon_break_over" ]]; then
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


interactive_prompt() {
  local long_break="$1"
  local option

  if "$interactive"; then
    printf -- "--:-- Press enter to start break
--:-- Press l|L followed by enter to start long break
--:-- Press i|I followed by enter to stop interactive mode\n"

    while (( "${#option[@]}" != 1 || "${#option}" != 1 )); do
      read -rp "--:-- Choose one option: " option
      if [[ "$option" == "" ]]; then
        break
      fi
    done

    case "$option" in
      i | I)
        interactive=false
        printf "%s Break started, interactive mode disabled\n" "$(date +%H:%M)"
        ;;
      l | L)
        if [[ "$long_break" != true ]]; then
          break_counter=0
          printf "%s Starting forced long break of %s minutes\n" "$(date +%H:%M)" "$(( break_time / 60 ))"
          return 3
        fi
        printf "%s Starting long break of %s minutes (already scheduled)\n" "$(date +%H:%M)" "$(( break_time / 60 ))"
        ;;
      * )
        printf "%s Starting break\n" "$(date +%H:%M)"
        ;;
    esac
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
        wait_minute=false
        break_counter=0
        printf "%s Time to have a long break of %s minutes\n" "$(date +%H:%M)" "$(( break_time / 60 ))"
        desktop_notification "$icon_long_break" "Time to have a long break of $(( break_time / 60 )) minutes"
        interactive_prompt true
        sleep "$break_time"

      elif (( breaks_taken >= 0 )); then
        wait_minute=false
        printf "%s Time to have a short break of 5 minutes %s\n" "$(date +%H:%M)" "($break_counter/$breaks)"
        desktop_notification "$icon_short_break" "Time to have a short break of 5 minutes ($break_counter/$breaks)"
        interactive_prompt
        if (( $? == 3 )); then
          sleep "$break_time"
          continue
        fi
        sleep 300
      fi

      desktop_notification "$icon_break_over" "Time to work for $timer minutes"

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
      if (( breaks < 1 )); then
        printf "Error: The amount of short breaks cannot be less than 1\n\n"
        usage
        exit 1
      fi
      ;;
    -i | --interactive)
      shift
      interactive=true
      ;;
    -t | --break-time)
      shift
      break_time=$(( $1 * 60 ))
      if (( break_time < 600 )); then
        printf "Error: Long breaks cannot be shorter than 10 minutes\n\n"
        usage
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


printf -- "--:-- Pomodoro timer started\n"
while true; do
  pomodoro_timer "$work_time"
done
