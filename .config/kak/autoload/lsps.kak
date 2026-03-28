hook -group lsp-filetype-nelt global BufSetOption filetype=nelt %{
    set-option buffer lsp_servers %{
        [emmet-ls]
        args = ["--stdio"]
        root_globs = [".git"]
        [vscode-html-language-server]
        args = ["--stdio"]
        root_globs = [".git"]
    }
}
