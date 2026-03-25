define-command -hidden _surround-info -params 1 %{
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

define-command _surround-add -hidden -params 1 %{
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

define-command _surround-add-tag -hidden %{
  prompt "Tag: " %{
    eval %sh{
      echo "exec i<lt>$kak_text<gt><esc>a<lt>/$kak_text<gt><esc>i<left><right><esc>"
    }
  }
}

define-command surround-add %{
  _surround-info "Surround add"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _surround-add-tag ;;
        *) echo "_surround-add "$kak_key"" ;;
      esac
    }
  }
}

define-command _surround-delete -hidden -params 1 %{
  eval %sh{
  case "$1" in
    "("|")"|"{"|"}"|"["|"]"|"<lt>"|"<gt>") echo "exec <a-i>${1}i<backspace><esc>a<del><esc>" ;;
    *) echo "exec <a-i>c${1},${1}<ret>i<backspace><esc>a<del><esc>" ;;
  esac
  }
}

define-command _surround-delete-tag -hidden %{
  eval %sh{
    echo surround-select-around-tag
    echo "exec <a-d>"
  }
}

define-command surround-delete %{
  _surround-info "Surround delete"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _surround-delete-tag ;;
        *) echo "_surround-delete "$kak_key"" ;;
      esac
    }
  }
}

define-command _surround-replace -hidden -params 1 %{
  eval %sh{
  case "$1" in
    "("|")"|"{"|"}"|"["|"]"|"<lt>"|"<gt>") echo "exec <a-a>${1}<ret><a-S>r" ;;
    *) echo "exec <a-a>c${1},${1}<ret><a-S>r" ;;
  esac
  }
}

define-command _surround-replace-tag -hidden %{
  prompt "Tag: " %{
    eval %sh{
      echo _surround-select-around-tag
      echo "exec <a-i>c<lt>/?,<gt><ret><a-c>$kak_text<esc>"
      echo _surround-select-around-tag
      echo "exec i<esc>e<a-c>$kak_text<esc>"
    }
  }
}

define-command surround-replace %{
  _surround-info "Surround replace"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _surround-replace-tag ;;
        *) echo "_surround-replace "$kak_key"" ;;
      esac
    }
  }
}

define-command _surround-select-inside -hidden -params 1 %{
  eval %sh{
  case "$1" in
    "("|")"|"{"|"}"|"["|"]"|"<lt>"|"<gt>") echo "exec <a-i>${1}<ret>" ;;
    *) echo "exec <a-i>c${1},${1}<ret>" ;;
  esac
  }
}

define-command _surround-select-inside-tag -hidden %{
  eval %sh{
    echo "exec <a-i>c<lt>[^<gt>]+<gt>,<lt>/[^<gt>]*<gt><ret>"
  }
}

define-command surround-select-inside %{
  _surround-info "Surround select inside"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _surround-select-inside-tag ;;
        *) echo "_surround-select-inside "$kak_key"" ;;
      esac
    }
  }
}

define-command _surround-select-around -hidden -params 1 %{
  eval %sh{
  case "$1" in
    "("|")"|"{"|"}"|"["|"]"|"<lt>"|"<gt>") echo "exec <a-a>${1}<ret>" ;;
    *) echo "exec <a-a>c${1},${1}<ret>" ;;
  esac
  }
}

define-command _surround-select-around-tag -hidden %{
  eval %sh{
    echo "exec <a-a>c<lt>[^<gt>]+<gt>,<lt>/[^<gt>]*<gt><ret>"
  }
}

define-command surround-select-around %{
  _surround-info "Surround select inside"
  on-key %{
    eval %sh{
      case "$kak_key" in
        "<esc>"|"<left>"|"<right>"|"<up>"|"<down>"|"<backspace>"|"<del>"|"<ret>"|"<home>"|"<end>") echo "exec :nop<ret>" ;;
        "t") echo _surround-select-around-tag ;;
        *) echo "_surround-select-around "$kak_key"" ;;
      esac
    }
  }
