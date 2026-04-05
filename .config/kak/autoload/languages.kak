hook global WinSetOption filetype=sh %{
  set-option buffer formatcmd "shfmt -i 2 -ci"
  hook buffer BufWritePre .* %{
    eval %sh{
      if [[ ! "$kak_buffile" =~ .*sxhkdrc$ ]]; then
        echo format
      fi
    }
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

hook global WinSetOption filetype=(?:javascript|typescript) %{
  set-option buffer lsp_servers %{
      [typescript-language-server]
      args = ["--stdio"]
      root_globs = ["package.json", "tsconfig.json", "jsconfig.json", ".git", ".hg"]
      [emmet-language-server]
      args = ["--stdio"]
      root_globs = ["package.json", "tsconfig.json", "jsconfig.json", ".git", ".hg"]
  }

  set-option buffer formatcmd "prettier --parser 'typescript'"
  hook buffer BufWritePre .* %{
    format
  }

  hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
  hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
  hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
  hook -once -always window WinSetOption filetype=.* %{
    remove-hooks window semantic-tokens
  }
}

hook global WinSetOption filetype=html %{
  set-option buffer lsp_servers %{
      [emmet-language-server]
      args = ["--stdio"]
      root_globs = [".git"]
   }

  set-option buffer formatcmd "prettier --parser 'html'"
  hook buffer BufWritePre .* %{
    format
  }
}

hook global WinSetOption filetype=css %{
  set-option buffer lsp_servers %{
      [emmet-language-server]
      args = ["--stdio"]
      root_globs = [".git"]
   }

  set-option buffer formatcmd "prettier --parser 'css'"
  hook buffer BufWritePre .* %{
    format
  }
}
