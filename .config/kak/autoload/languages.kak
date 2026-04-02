hook global WinSetOption filetype=sh %{
  set-option buffer formatcmd "shfmt -i 2 -ci"
  hook buffer BufWritePre .* %{
    format
  }
}

hook global WinSetOption filetype=nelt %{
  set-option buffer formatcmd 'djlint - --reformat --indent 2 --max-blank-lines 1 --custom-blocks "local\sfunction,global\sfunction" --format-css --indent-css 2 --format-js --indent-js 2 --close-void-tag'
  hook buffer BufWritePre .* %{
    format
  }
  set-option buffer lsp_servers %{
      [emmet-ls]
      args = ["--stdio"]
      root_globs = [".git"]
      [vscode-html-language-server]
      args = ["--stdio"]
      root_globs = [".git"]
  }
}

hook global WinSetOption filetype=json %{
  set-option buffer formatcmd "jq -M"
  hook buffer BufWritePre .* %{
    format
  }
}

hook global WinSetOption filetype=nelua %{
  set-option buffer lintcmd %{ run(){ if [ -z "$1" ]; then printf "error: no argument passed to $0" >&2 exit 70; fi; nelua --lint "$1" 2>&1 | grep "error"; } && run }
}
