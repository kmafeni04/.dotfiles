hook global WinSetOption filetype=sh %{
  set-option buffer formatcmd "shfmt -i 2 -ci"
  hook buffer BufWritePost .* %{
    format
  }
}
