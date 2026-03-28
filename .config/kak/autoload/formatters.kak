hook global WinSetOption filetype=sh %{
  set-option buffer formatcmd "shfmt -i 2 -ci"
  hook buffer BufWritePost .* %{
    format
  }
}

hook global WinSetOption filetype=nelt %{
  set-option buffer formatcmd "bash ~/.scripts/nelt-format.sh"
  hook buffer BufWritePost .* %{
    format
  }
}
