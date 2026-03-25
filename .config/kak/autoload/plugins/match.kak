define-command -hidden _match-info -params 1 %{
  info -title "%arg{1}" "(,):  parentheses block
{,}:    braces block
[,]:    bracket block
<,>:    angle block
"":     double quote string
':      single quote string
`:      grave quote string
t:      markup tag<tag>
others: pressed character"
}

define-command _match-surround-add -hidden -params 1 %{
  eval %sh{
    case "$1" in
      "("|")") echo "exec i(<esc>a)<esc>" ;;
      "{"|"}") echo "exec i{<esc>a}<esc>" ;;
      "["|"]") echo "exec i[<esc>a]<esc>" ;;
      "<lt>"|"<gt>") echo "exec i<lt><esc>a<gt><esc>" ;;
      *) echo "exec i$1<esc>a$1<esc>" ;;
    esac
  }
}

define-command _match-surround-add-tag -hidden %{
  prompt "Tag: " %{
    eval %sh{
      echo "exec i<lt>$kak_text<gt><esc>a<lt>/$kak_text<gt><esc>i<left><right><esc>"
    }
  }
}

define-command match-surround-add %{
  _match-info "Surround add"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _match-surround-add-tag ;;
        *) echo "_match-surround-add "$kak_key"" ;;
      esac
    }
  }
}

define-command _match-surround-delete -hidden -params 1 %{
  eval %sh{
  case "$1" in
    "("|")"|"{"|"}"|"["|"]"|"<lt>"|"<gt>") echo "exec <a-i>${1}i<backspace><esc>a<del><esc>" ;;
    *) echo "exec <a-i>c${1},${1}<ret>i<backspace><esc>a<del><esc>" ;;
  esac
  }
}

define-command _match-surround-delete-tag -hidden %{
  eval %sh{
    echo match-around-tag
    echo "exec <a-d>"
  }
}

define-command match-surround-delete %{
  _match-info "Surround delete"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _match-surround-delete-tag ;;
        *) echo "_match-surround-delete "$kak_key"" ;;
      esac
    }
  }
}

define-command _match-surround-replace -hidden -params 1 %{
  eval %sh{
  case "$1" in
    "("|")"|"{"|"}"|"["|"]"|"<lt>"|"<gt>") echo "exec <a-a>${1}<ret><a-S>r" ;;
    *) echo "exec <a-a>c${1},${1}<ret><a-S>r" ;;
  esac
  }
}

define-command _match-surround-replace-tag -hidden %{
  prompt "Tag: " %{
    eval %sh{
      echo _match-around-tag
      echo "exec <a-i>c<lt>/?,<gt><ret><a-c>$kak_text<esc>"
      echo _match-around-tag
      echo "exec i<esc>e<a-c>$kak_text<esc>"
    }
  }
}

define-command match-surround-replace %{
  _match-info "Surround replace"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _match-surround-replace-tag ;;
        *) echo "_match-surround-replace "$kak_key"" ;;
      esac
    }
  }
}

define-command _match-inside -hidden -params 1 %{
  eval %sh{
  case "$1" in
    "("|")"|"{"|"}"|"["|"]"|"<lt>"|"<gt>") echo "exec <a-i>${1}<ret>" ;;
    *) echo "exec <a-i>c${1},${1}<ret>" ;;
  esac
  }
}

define-command _match-inside-tag -hidden %{
  eval %sh{
    echo "exec <a-i>c<lt>[^<gt>]+<gt>,<lt>/[^<gt>]*<gt><ret>"
  }
}

define-command match-inside %{
  _match-info "Surround select inside"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _match-select-inside-tag ;;
        *) echo "_match-inside "$kak_key"" ;;
      esac
    }
  }
}

define-command _match-around -hidden -params 1 %{
  eval %sh{
  case "$1" in
    "("|")"|"{"|"}"|"["|"]"|"<lt>"|"<gt>") echo "exec <a-a>${1}<ret>" ;;
    *) echo "exec <a-a>c${1},${1}<ret>" ;;
  esac
  }
}

define-command _match-around-tag -hidden %{
  eval %sh{
    echo "exec <a-a>c<lt>[^<gt>]+<gt>,<lt>/[^<gt>]*<gt><ret>"
  }
}

define-command match-around %{
  _match-info "Surround select inside"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _match-around-tag ;;
        *) echo "_match-around "$kak_key"" ;;
      esac
    }
  }
}
