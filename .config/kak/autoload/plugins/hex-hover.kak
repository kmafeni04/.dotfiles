hook global -group hex-hover NormalIdle .* %{
  evaluate-commands -save-regs 'a' %{
    try %{
      execute-keys -draft '<a-i>w<a-;>H"ay'
      evaluate-commands %sh{
        (
          [[ ! "$kak_reg_a" =~ \#[0-9A-Fa-f]+ ]] && exit
          color=${kak_reg_a#\#}
          inverted_color=$(echo "${color}" | awk '{
            hex=$0
            result=""
            for(i=1; i<=length(hex); i+=2) {
                byte="0x"substr(hex,i,2)
                inverted=255-strtonum(byte)
                result=result sprintf("%02x",inverted)
            }
            print result
          }')
          [ -z "$inverted_color" ] && exit
          printf "%s\n" "evaluate-commands -client $kak_client %{
            try %{
              echo -markup %{ {rgb:${inverted_color},rgb:${color}+b} #${color} }
            }
          }" | kak -p $kak_session
        ) >/dev/null 2>&1 </dev/null &
      }
    }
  }
}
