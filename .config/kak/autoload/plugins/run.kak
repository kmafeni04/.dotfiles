define-command _run -hidden -params 2.. %{
  eval %sh{
    filename="$1"
    shift
    in_fzf="$1"
    shift
    run_command="$@"

    if [ -z "$run_command" ]; then
      base_dir="$(realpath "$(dirname "$filename")")"
      base_name="$(basename "$filename")"
      base_name_without_extension="${base_name%.*}"
      extension="${base_name##*.}"

      case "$extension" in
        "c")
          run_command="tcc $filename -o $base_dir/$base_name_without_extension && $base_dir/$base_name_without_extension"
          ;;
        "nelua")
          run_command="nlpm script dev || nlpm run nelua --cc=tcc $filename"
          ;;
        "lua")
          run_command="lua5.4 $filename || nlpm run nelua --script $filename"
          ;;
        "ts" | "js")
          run_command="node $filename"
          ;;
        "py")
          run_command="python $filename"
          ;;
        "go")
          run_command="go run $filename"
          ;;
        "sh")
          run_command="bash $filename"
          ;;
        "um")
          run_command="umka $filename"
          ;;
        "html")
          run_command="python -m http.server 8080 --directory $base_dir"
          ;;
        *)
          run_command="No defined case for extension: $extension"
          ;;
      esac
    fi

    [ -z "$run_command" ] && echo "echo 'No commnand provided'" && exit
    [ "$run_command" = "No defined case for extension: $extension" ] && echo "echo '$run_command'" && exit

    if [ "$in_fzf" = true ]; then
      run_command="$run_command; pane_id=\$(wezterm cli get-pane-direction up)"
      run_command="$run_command; [ -z \"\$pane_id\" ] && clear && read -p 'No editor pane. Press Enter to close:' && exit"
      run_command="$run_command; choice=\$(wezterm cli get-text | fzf)"
      run_command="$run_command; [ -z \"\$choice\" ] && exit"
      run_command="$run_command; selection=\$(echo \"\$choice\" | grep -P '^\\s*.*?:[0-9]+:?[0-9]*' -o)"
      run_command="$run_command; [ -z \"\$selection\" ] && clear && read -p 'Invalid path. Press Enter to close:' && exit"
      run_command="$run_command; echo -e \":e \$selection\r\" | wezterm cli send-text --no-paste --pane-id \$pane_id"
      run_command="$run_command; wezterm cli activate-pane --pane-id \$pane_id"
    else
      run_command="$run_command; read -p 'Press Enter to close:'"
    fi

    pane_id=$(wezterm cli get-pane-direction down)
    [ -n "$pane_id" ] && wezterm cli kill-pane --pane-id "$pane_id"
    wezterm cli split-pane --bottom --percent 30 bash -c "$run_command" >/dev/null
  }
}

define-command -docstring "Run <command>" \
  run -params 1.. %{
  _run "nil" false "%arg{@}"
}

define-command -docstring "Run <command> and pass output to fzf error picker" \
  run-fzf -params 1.. %{
  _run "nil" true "%arg{@}"
}

define-command _term -params 2.. %{
  nop %sh{
    declare -A directions
    directions["up"]="top"
    directions["down"]="bottom"
    directions["left"]="left"
    directions["right"]="right"

    readonly DIRECTION=$1
    shift
    readonly SIZE=$1
    shift

    pane_id=$(wezterm cli get-pane-direction $DIRECTION)
    [ -n "$pane_id" ] && wezterm cli kill-pane --pane-id "$pane_id" || wezterm cli split-pane --percent $SIZE --${directions[$DIRECTION]} $@ > /dev/null
  }
}
