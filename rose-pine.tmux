#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
  local theme
  theme="$(get_tmux_option "@rose_pine_variant" "dawn")"

  # Aggregate all commands in one array
  local tmux_commands=()

  # NOTE: Pulling in the selected theme by the theme that's being set as local
  # variables.
  # shellcheck source=rose-pine-frappe.tmuxtheme
  source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${PLUGIN_DIR}/rose-pine-${theme}.tmuxtheme")"

  # status
  set status "on"
  # set status-bg "${thm_bg}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${thm_foam},bg=${thm_bg},align=centre"
  set message-command-style "fg=${thm_foam},bg=${thm_bg},align=centre"

  # panes
  set pane-border-style "fg=${thm_bg}"
  set pane-active-border-style "fg=${thm_pine}"

  # windows
  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  # --------=== Statusline

  # NOTE: Checking for the value of @rose_pine_window_tabs_enabled
  local wt_enabled
  wt_enabled="$(get_tmux_option "@rose_pine_window_tabs_enabled" "off")"
  readonly wt_enabled

  local right_separator
  right_separator="$(get_tmux_option "@rose_pine_right_separator" "")"
  readonly right_separator

  local left_separator
  left_separator="$(get_tmux_option "@rose_pine_left_separator" "")"
  readonly left_separator

  local user
  user="$(get_tmux_option "@rose_pine_user" "off")"
  readonly user

  local host
  host="$(get_tmux_option "@rose_pine_host" "off")"
  readonly host

  local date_time
  date_time="$(get_tmux_option "@rose_pine_date_time" "off")"
  readonly date_time

  local cpu_usage
  cpu_usage="$(get_tmux_option "@rose_pine_cpu_usage" "off")"
  readonly cpu_usage

  # These variables are the defaults so that the setw and set calls are easier to parse.
  local show_directory
  readonly show_directory="#[fg=$thm_love,bg=$thm_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$thm_bg,bg=$thm_love,nobold,nounderscore,noitalics]  #[fg=$thm_fg,bg=$thm_bg] #{b:pane_current_path} #{?client_prefix,#[fg=$thm_love]"

  local show_window
  readonly show_window="#[fg=$thm_gold,bg=$thm_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$thm_bg,bg=$thm_gold,nobold,nounderscore,noitalics] #[fg=$thm_fg,bg=$thm_bg] #W #{?client_prefix,#[fg=$thm_love]"

  local show_session
  readonly show_session="#[fg=$thm_iris]}#[bg=$thm_bg]$right_separator#{?client_prefix,#[bg=$thm_love],#[bg=$thm_iris]}#[fg=$thm_bg] #[fg=$thm_fg,bg=$thm_bg] #S "

  local show_directory_in_window_status
  #readonly show_directory_in_window_status="#[fg=$thm_bg,bg=$thm_pine] #I #[fg=$thm_fg,bg=$thm_bg] #{b:pane_current_path} "
  readonly show_directory_in_window_status="#[fg=$thm_bg,bg=$thm_pine] #I #[fg=$thm_subtle,bg=$thm_bg] #W "

  local show_directory_in_window_status_current
  #readonly show_directory_in_window_status_current="#[fg=$thm_bg,bg=$thm_rose] #I #[fg=$thm_fg,bg=$thm_bg] #{b:pane_current_path} "
  readonly show_directory_in_window_status_current="#[fg=$thm_bg,bg=$thm_rose] #I #[fg=$thm_fg,bg=$thm_overlay] #(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev) "

  local show_window_in_window_status
  readonly show_window_in_window_status="#[fg=$thm_fg,bg=$thm_bg] #W #[fg=$thm_bg,bg=$thm_love] #I#[fg=$thm_love,bg=$thm_bg]$left_separator#[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] "

  local show_window_in_window_status_current
  readonly show_window_in_window_status_current="#[fg=$thm_fg,bg=$thm_bg] #W #[fg=$thm_bg,bg=$thm_rose] #I#[fg=$thm_rose,bg=$thm_bg]$left_separator#[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] "
 #setw -g window-status-current-format "#[fg=colour232,bg=$thm_rose] #I #[fg=colour255,bg=colour237] #(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev) "


  local show_user
  readonly show_user="#[fg=$thm_pine,bg=$thm_bg]$right_separator#[fg=$thm_bg,bg=$thm_pine] #[fg=$thm_fg,bg=$thm_bg] #(whoami) "

  local show_cpu_usage
  readonly show_cpu_usage="#[fg=$thm_gold,bg=$thm_bg]$right_separator#[fg=$thm_bg,bg=$thm_gold] #[fg=$thm_fg,bg=$thm_bg] #({cpu_percentage}) "

  local show_host
  readonly show_host="#[fg=$thm_pine,bg=$thm_bg]$right_separator#[fg=$thm_bg,bg=$thm_pine] 󰒋 #[fg=$thm_fg,bg=$thm_bg] #H "

  local show_date_time
  readonly show_date_time="#[fg=$thm_foam,bg=$thm_bg]$right_separator#[fg=$thm_bg,bg=$thm_foam]󱑂 #[fg=$thm_fg,bg=$thm_bg] $date_time "

  # Right column 1 by default shows the Window name.
  local right_column1=$show_window

  # Right column 2 by default shows the current Session name.
  local right_column2=$show_session

  # Window status by default shows the current directory basename.
  local window_status_format=$show_directory_in_window_status
  local window_status_current_format=$show_directory_in_window_status_current

  # NOTE: With the @rose_pine_window_tabs_enabled set to on, we're going to
  # update the right_column1 and the window_status_* variables.
  if [[ "${wt_enabled}" == "on" ]]; then
    right_column1=$show_directory
    window_status_format=$show_window_in_window_status
    window_status_current_format=$show_window_in_window_status_current
  fi

  if [[ "${user}" == "on" ]]; then
    right_column2=$right_column2$show_user
  fi

  if [[ "${host}" == "on" ]]; then
    right_column2=$right_column2$show_host
  fi

  if [[ "${cpu_usage}" == "on" ]]; then
    right_column2=$right_column2$show_cpu_usage
  fi

  if [[ "${date_time}" != "off" ]]; then
    right_column2=$right_column2$show_date_time
  fi

  set status-left ""

  set status-right "${right_column1},${right_column2}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"

  # --------=== Modes
  #
  setw clock-mode-colour "${thm_rose}"
  setw mode-style "fg=${thm_pink} bg=${thm_bg} bold"

  tmux "${tmux_commands[@]}"
}

main "$@"
