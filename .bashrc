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

#user aliases

alias 'sup'='rebos managers upgrade --sync'
alias 'sups'='rebos managers upgrade --sync && poweroff'
alias 'rconf'='helix ~/.config/rebos/gen.toml'
alias 'rclean'='rebos gen tidy-up'
alias 'rcommit'='rebos gen commit'
alias 'rswitch'='rebos gen current to-latest && rebos gen current build'
alias 'rroll'='rebos gen current rollback 1 && rebos gen current build'

# alias 'yup'='yay && flatpak update -y'
# alias 'yin'='yay -S'
# alias 'yre'='yay -Rns'
alias 'yar'='yay -Rcns $(yay -Qdtq)'
alias 'yse'='yay -Ss'
alias 'ysy'='yay -Syy' # update mirrors

# alias 'flu'='flatpak update -y'
# alias 'fli'='flatpak install -y'
# alias 'flr'='flatpak remove -y'
alias 'fls'='flatpak search'

# alias 'pa'='cat ~/Desktop/Packages.txt'
# alias 'pq'='cat ~/Desktop/Packages.txt | grep -i'

alias 'hx'='helix'
alias 'nv'='nvim'

alias 'lps'='eval $(luarocks path --lua-version=5.1) && lapis server'
alias 'bs'='browser-sync start --config bs-config.js'

alias 'his'='cat ~/.bash_history | fzf --tac | xargs -I {} sh -c '\''source /home/kome/.bashrc; eval "{}"'\'''
alias 'tp'='trash-put'

alias 'lua'='eval $(luarocks path --lua-version=5.4) && lua5.4'
alias 'lua5.1'='eval $(luarocks path --lua-version=5.1) && lua5.1'

# Prompt colors

red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
reset=$(tput sgr0)
PS1='\[$red\]\u\[$reset\]@\[$green\]\h\[$reset\]:\[$blue\]\w\[$reset\]\$ '


export EDITOR=helix

PATH="/opt/openresty/bin:$PATH"

# Luarocks
PATH="$HOME/.luarocks/bin:$PATH"
eval $(luarocks path)

# Node
PATH="$HOME/node_modules/.bin:$PATH"

# pip bash completion start
_pip_completion()
{
COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
             COMP_CWORD=$COMP_CWORD \
             PIP_AUTO_COMPLETE=1 $1 2>/dev/null ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end
