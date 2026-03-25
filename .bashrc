# .bashrc

# Source global definitions

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ $PATH =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi

unset rc

set -o vi
bind 'set show-mode-in-prompt on'
bind 'set vi-cmd-mode-string "\1\e[2 q\2"'
bind 'set vi-ins-mode-string "\1\e[6 q\2"'

PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#user aliases

alias 'ls'='ls -a -p --group-directories-first --hyperlink --color=auto'

alias 'sup'='rebos managers upgrade --sync'
alias 'sups'='rebos managers upgrade --sync && poweroff'
alias 'rconf'='hx ~/.config/rebos/gen.toml'
alias 'rclean'='rebos gen tidy-up'
alias 'rcommit'='rebos gen commit'
alias 'rswitch'='rebos gen current to-latest && rebos gen current build'
alias 'rroll'='rebos gen current rollback 1 && rebos gen current build'

alias 'yre'='yay -Rns'
alias 'yar'='yay -Rcns $(yay -Qdtq)' # auto remove unused dependecies
alias 'yse'='yay -Ss'                # package search
alias 'ysm'='yay -Syy'               # sync mirrors

alias 'flu'='flatpak update -y'
alias 'fls'='flatpak search'

alias 'lps'='eval $(luarocks path --lua-version=5.1) && lapis server'
alias 'bs'='browser-sync start --config bs-config.js'

alias 'his'='cat ~/.bash_history | fzf --tac | xargs -I {} sh -c '\''source /home/kome/.bashrc; eval "{}"'\'''
alias 'tp'='trash-put'

alias 'lua'='eval $(luarocks path --lua-version=5.4) && lua5.4'
alias 'lua5.1'='eval $(luarocks path --lua-version=5.1) && lua5.1'

alias 'grep'='grep --colour'

# Prompt colors
gen_ps1() {
  local red="\[$(tput setaf 1)\]"
  local green="\[$(tput setaf 2)\]"
  local orange="\[$(tput setaf 3)\]"
  local blue="\[$(tput setaf 4)\]"
  local magenta="\[$(tput setaf 5)\]"
  local cyan="\[$(tput setaf 6)\]"
  local grey="\[$(tput setaf 7)\]"
  local black="\[$(tput setaf 8)\]"
  local reset="\[$(tput sgr0)\]"
  local bold="\[$(tput bold)\]"

  PS1=""
  local bg_jobs="$(jobs -l | wc -l)"
  [ "$bg_jobs" -gt 0 ] && PS1="$green$bold[$bg_jobs]$reset "

  PS1="$PS1($bold$blue\W$reset)"

  local git_branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
  if [ -n "$git_branch" ]; then
    PS1="$PS1$cyan$bold  $git_branch"

    local upstream="$(git for-each-ref --format='%(upstream:short)' "refs/heads/$git_branch" 2> /dev/null)"

    if [ -n "$upstream" ]; then
      local ahead_behind=" "
      local ahead=$(git rev-list --count HEAD ^"$upstream" 2> /dev/null)
      local behind=$(git rev-list --count "$upstream" ^HEAD 2> /dev/null)

      [ "${ahead:-0}" -gt 0 ] && ahead_behind="$ahead_behind$ahead"
      [ "${behind:-0}" -gt 0 ] && ahead_behind="$ahead_behind$behind"
      [ "$ahead_behind" = " " ] && ahead_behind=""

      PS1="$PS1$ahead_behind"
    fi

    PS1="$PS1$reset"

    local modified=0
    local untracked=0
    local added=0
    local renamed=0
    local deleted=0

    local git_status="$(git status -s --porcelain 2> /dev/null)"
    if [ -n "$git_status" ]; then
      modified="$(echo "$git_status" | grep -Po "^[\s]*M " | wc -l)"
      untracked="$(echo "$git_status" | grep -Po "^[\s]*\?\? " | wc -l)"
      added="$(echo "$git_status" | grep -Po "^[\s]*A " | wc -l)"
      renamed="$(echo "$git_status" | grep -Po "^[\s]*R " | wc -l)"
      deleted="$(echo "$git_status" | grep -Po "^[\s]*D " | wc -l)"
    fi

    [ "${modified:-0}" -gt 0 ] && PS1="$PS1$orange !$modified$reset"
    [ "${added:-0}" -gt 0 ] && PS1="$PS1$green +$added$reset"
    [ "${deleted:-0}" -gt 0 ] && PS1="$PS1$red -$deleted$reset"
    [ "${renamed:-0}" -gt 0 ] && PS1="$PS1$cyan $renamed$reset"
    [ "${untracked:-0}" -gt 0 ] && PS1="$PS1$red ?$untracked$reset"

    PS1="$PS1$reset"
  fi
  PS1="$PS1 $magenta$bold>$reset "
}
PROMPT_COMMAND="gen_ps1; $PROMPT_COMMAND"

PATH="/opt/openresty/bin:$PATH"

# Luarocks
PATH="$XDG_CONFIG_HOME/luarocks/bin:$PATH"
eval $(luarocks path)

# Node
PATH="$HOME/node_modules/.bin:$PATH"

# Python
eval "$(register-python-argcomplete pipx)"

eval "$(eww shell-completions --shell bash)"

eval "$(fzf --bash)"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=border:#27a1b9 \
  --color=fg+:#9abdf5 \
  --color=fg:#9abdf5 \
  --color=bg+:#313349 \
  --color=gutter:#16161e \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#9abdf5 \
  --color=prompt:#2ac3de \
  --color=query:#9abdf5:regular \
  --color=scrollbar:#27a1b9 \
  --color=separator:#9abdf5 \
  --color=spinner:#9abdf5 \
"

lf() {
  echo -en "\033]0;lf\a"
  command lf "$@"
}

wget() { command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" "$@"; }
