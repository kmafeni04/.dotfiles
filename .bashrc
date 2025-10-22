# .bashrc

# Source global definitions

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
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

eval "$(fzf --bash)"

PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#user aliases

alias 'ls'='ls --hyperlink --color=auto'

alias 'sup'='rebos managers upgrade --sync'
alias 'sups'='rebos managers upgrade --sync && poweroff'
alias 'rconf'='hx ~/.config/rebos/gen.toml'
alias 'rclean'='rebos gen tidy-up'
alias 'rcommit'='rebos gen commit'
alias 'rswitch'='rebos gen current to-latest && rebos gen current build'
alias 'rroll'='rebos gen current rollback 1 && rebos gen current build'

# alias 'yup'='yay && flatpak update -y'
# alias 'yin'='yay -S'
# alias 'yre'='yay -Rns'
alias 'yar'='yay -Rcns $(yay -Qdtq)' # auto remove unused dependecies
alias 'yse'='yay -Ss' # package search
alias 'ysy'='yay -Syy' # update mirrors

# alias 'flu'='flatpak update -y'
# alias 'fli'='flatpak install -y'
# alias 'flr'='flatpak remove -y'
alias 'fls'='flatpak search'

# alias 'hx'='helix'
# alias 'nv'='nvim'

alias 'lps'='eval $(luarocks path --lua-version=5.1) && lapis server'
alias 'bs'='browser-sync start --config bs-config.js'

alias 'his'='cat ~/.bash_history | fzf --tac | xargs -I {} sh -c '\''source /home/kome/.bashrc; eval "{}"'\'''
alias 'tp'='trash-put'

alias 'lua'='eval $(luarocks path --lua-version=5.4) && lua5.4'
alias 'lua5.1'='eval $(luarocks path --lua-version=5.1) && lua5.1'

alias 'grep'='grep --colour'

# Prompt colors

red="\[$(tput setaf 1)\]"
green="\[$(tput setaf 2)\]"
orange="\[$(tput setaf 3)\]"
blue="\[$(tput setaf 4)\]"
magenta="\[$(tput setaf 5)\]"
cyan="\[$(tput setaf 6)\]"
grey="\[$(tput setaf 7)\]"
black="\[$(tput setaf 8)\]"
reset="\[$(tput sgr0)\]"
bright="\[\033[1m\]"

function gen_ps1() {
  PS1=""
  bg_jobs="$(jobs -l | wc -l)"
  [ "$bg_jobs" -gt 0 ] && PS1="$green$bright[$bg_jobs]$reset "

  PS1="$PS1($bright$blue\W$reset)"
  git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$git_branch" ]; then
    upstream=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$git_branch" 2>/dev/null)
    ahead_behind=" "
    ahead=$(git rev-list --count HEAD ^$upstream 2>/dev/null)
    behind=$(git rev-list --count $upstream ^HEAD 2>/dev/null)
    if [ "${ahead:-0}" -gt 0 ]; then
      ahead_behind="$ahead_behind$ahead"
    fi
    if [ "${behind:-0}" -gt 0 ]; then
      ahead_behind="$ahead_behind$behind"
    fi
    [ "$ahead_behind" == " " ] && ahead_behind=""

    git_status="$(git status -s -b --porcelain 2>/dev/null)"
    modified=""
    untracked=""
    added=""

    color="$bright"
    for line in $git_status; do
      if [ -n "$(echo "$line" | grep -P "^M" 2>/dev/null)" ]; then
        modified="M"
      fi
      if [ -n "$(echo "$line" | grep -P "^\?" 2>/dev/null)" ]; then
        untracked="?"
      fi
      if [ -n "$(echo "$line" | grep -P "^[AR]" 2>/dev/null)" ]; then
        added="A"
      fi
    done
    if [ -n "$untracked" ]; then
      color="$color$red"
    elif [ -n "$added" ]; then
      color="$color$green"
    elif [ -n "$modified" ]; then
      color="$color$orange"
    else
      color="$color$cyan"
    fi
    PS1="$PS1$color  $git_branch$ahead_behind$reset"
  fi
  PS1="$PS1 $magenta$bright>$reset "
}
PROMPT_COMMAND="gen_ps1; $PROMPT_COMMAND"

export EDITOR=helix
export TERM=wezterm

PATH="/opt/openresty/bin:$PATH"

# Luarocks
PATH="$HOME/.luarocks/bin:$PATH"
eval $(luarocks path)

# Node
PATH="$HOME/node_modules/.bin:$PATH"

eval "$(register-python-argcomplete pipx)"

hx(){
  echo -en "\033]0;helix\a"
  helix $@
}

lf() {
  echo -en "\033]0;lf\a"
  command lf "$@"
}
