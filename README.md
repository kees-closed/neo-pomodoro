# Pomodoro in Bash
## Usage
This program helps managing time using the [Pomodoro technique](https://en.wikipedia.org/wiki/Pomodoro_Technique). Press Ctrl-C to open an option menu during runtime. If you want to override the default runtime variables, place the option variables that are at the top of the script in `~/.config/neo-pomodoro/neo-pomodoro.conf` and modify them.

Usage: `neo-pomodoro [OPTIONS]`

Options:
*  `-b`, `--breaks`      Sets the amount of short breaks before a long break
*  `-i`, `--interactive` Enables interactive options before each break
*  `-t`, `--break-time`  Sets the time in minutes for the long breaks
*  `-c`, `--config`      Specifies an alternative configuration file
*  `-h`, `--help`        Display this help and exit

Pro-tip: Use Android's [Focus Mode](https://www.blog.google/products/android/android-focus-mode/) to snooze distracting apps during the Pomodoros.


## Known issues
When opening the quit menu by pressing Ctrl-C, any running `sleep` command in the `pomodoro_timer` function are interrupted. During a Pomodoro, this cancels 1 minute from the timer. But in case of a standard long break, it would cancel a 30 minute `sleep`. This bug will not be fixed. In order for the quit menu to appear, any `sleep` or running activity needs to be interrupted. Creating shorter `sleep` intervals would minimize this timer drift, but as a consequence would create more CPU interrupts. Which as a trade-off has performance and energy consumption implications. This bug could be regarded as a "feature", since it allows a user to cancel a running break.
