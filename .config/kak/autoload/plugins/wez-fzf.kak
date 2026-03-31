declare-option str fzf_buflist  ""

define-command _wez-fzf -hidden -params 1.. %{
  set-option global fzf_buflist ""
  eval -no-hooks -buffer * %{
    set-option -add global fzf_buflist "%val{bufname}\n"
  }
  nop %sh{
    buffer(){
      run_command="pane_id=\$(wezterm cli get-pane-direction up)"
      run_command="$run_command; [ -z \"\$pane_id\" ] && clear && read -p 'No editor pane. Press Enter to close:' && exit"
      run_command="$run_command; selection=\$(echo -e \"$kak_opt_fzf_buflist\" | fzf --preview='bat --color=always {}')"
      run_command="$run_command; [ -z \"\$selection\" ] && echo -en \"vv\" | wezterm cli send-text --no-paste --pane-id \$pane_id &&  exit"
      run_command="$run_command; echo -en \":buffer \$selection\r\" | wezterm cli send-text --no-paste --pane-id \$pane_id"
      run_command="$run_command; wezterm cli activate-pane --pane-id \$pane_id"

      echo "$run_command"
    }
    pick() {
      git_base_dir="$1"
      dir="$2"

      [ -n "$git_base_dir" ] && fzf_command="fd --type f --strip-cwd-prefix | fzf" || fzf_command="fzf"

      run_command="cd $dir"
      run_command="$run_command; pane_id=\$(wezterm cli get-pane-direction up)"
      run_command="$run_command; [ -z \"\$pane_id\" ] && clear && read -p 'No editor pane. Press Enter to close:' && exit"
      run_command="$run_command; selection=\$($fzf_command --preview='bat --color=always {}')"
      run_command="$run_command; [ -z \"\$selection\" ] && echo -en \"vv\" | wezterm cli send-text --no-paste --pane-id \$pane_id &&  exit"
      run_command="$run_command; echo -en \":e \$(realpath \$selection)\r\" | wezterm cli send-text --no-paste --pane-id \$pane_id"
      run_command="$run_command; wezterm cli activate-pane --pane-id \$pane_id"

      echo "$run_command"
    }

    global_search() {
      git_base_dir="$1"
      dir="${2:-.}"

      [ -n "$git_base_dir" ] && grep_command="git ls-files --exclude-standard | xargs grep -rnP '.+'" || grep_command="grep -rnP '.+'"

      run_command="cd $dir"
      run_command="$run_command; pane_id=\$(wezterm cli get-pane-direction up)"
      run_command="$run_command; selection=\$($grep_command | fzf -e --delimiter=':' --preview ' \
        LINE={2};                                                                                \
        if [ \$LINE -lt 16 ]; then                                                               \
          START=1;                                                                               \
        else                                                                                     \
          START=\$((LINE - 15));                                                                 \
        fi;                                                                                      \
        END=\$((LINE + 15));                                                                     \
        bat --color=always --highlight-line \$LINE --line-range \$START:\$END {1}' |             \
        awk -F: '{print \$1 \" \" \$2}                                                           \
      ')"
      run_command="$run_command; [ -z \"\$selection\" ] && echo -en \"vv\" | wezterm cli send-text --no-paste --pane-id \$pane_id && exit"
      run_command="$run_command; echo -en \":e $dir/\$selection; exec 'vv'\r\" | wezterm cli send-text --no-paste --pane-id \$pane_id"
      run_command="$run_command; wezterm cli activate-pane --pane-id \$pane_id"
    }

    main() {
      fpath="${2:-"."}"
      cwd="${3:-"."}"
      dir=$(dirname "$fpath")

      git_base_dir="$(git rev-parse --show-toplevel 2>/dev/null)"

      case "$1" in
        buffer) buffer ;;
        pick) pick "$git_base_dir" "." ;;
        pick_cwd) pick "$git_base_dir" "$cwd" ;;
        pick_cbd) pick "$git_base_dir" "$dir" ;;
        global_search) global_search "$git_base_dir" "$git_base_dir" ;;
        *) exit 1 ;;
      esac

      pane_id=$(wezterm cli get-pane-direction down)
      [ -n "$pane_id" ] && wezterm cli kill-pane --pane-id "$pane_id"
      wezterm cli split-pane --bottom --percent 80 bash -c "$run_command" >/dev/null
    }

    main "$@"
  }
}
