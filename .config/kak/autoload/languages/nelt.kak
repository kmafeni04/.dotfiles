hook global BufCreate '.*\.nelt' %{
  set-option buffer filetype nelt
}

provide-module nelt %{
  require-module nelua
  require-module html
  add-highlighter shared/nelt regions
  add-highlighter shared/nelt/html default-region ref html
  add-highlighter shared/nelt/comment region '\{#' '#\}' fill comment
  add-highlighter shared/nelt/expression region '\{%' '%\}' ref nelua
  add-highlighter shared/nelt/unescpaed region '\{\{-' '\}\}' ref nelua
  add-highlighter shared/nelt/escpaed region '\{\{' '\}\}' ref nelua
}

hook global WinSetOption filetype=nelt %{
  require-module nelt
  add-highlighter window/nelt ref nelt
  hook -group nelt-indent window InsertChar '\n' html-indent-on-new-line
  hook -always -once window WinSetOption filetype=.* %{
    remove-highlighter window/nelt
    remove-hooks window nelt-.+
  }
}
