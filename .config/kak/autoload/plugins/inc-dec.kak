define-command \
    -params 2 \
    -docstring "
        inc-dec-modify-numbers OP NUM

        Apply the given operator (usually + or -) and NUM to each selected
        number. For example, 'inc-dec-modify-numbers + 3' adds 3 to all selected
        numbers. If NUM is 0, it is replaced with 1 since adding or subtracting
        0 is not useful.
        " \
    inc-dec-modify-numbers \
%{
    evaluate-commands -save-regs 'c' %{
        # "c" stores the count we want to use (in decimal)
        set-register c %sh{ echo $(( $2 == 0 ? 1 : $2 )) }

        try %{
            # Search for tokens that look like hex numbers.
            execute-keys s (\A|\+|-|(?<=[^0-9]))0[Xx][0-9A-Fa-f]+ <ret>
            # Apply our operator with shell arithmetic.
            execute-keys | "read val; printf '0x%%0*X\n' $((${#val} - 2)) $(($val %arg{1} %reg{c}))" <ret>

        } catch %{
            # Search for C/C++ escaped hex literals
            # C++ supports
            # \uhhhh,  \Uhhhhhhhh exactly 4, 8 hex digits
            # \x..., \x{...} \u{...}      arbitrary number of hex digits
            # C supports
            # \x...,  \uhhhh,  \Uhhhhhhhh
            execute-keys s (?<=\\)(u[\dA-Fa-f]{4}|U[\dA-Fa-f]{8}|x[\dA-Fa-f]+|[ux]\{[\dA-Fa-f]+\}) <ret>
            # Apply operator with shell arithmetic (no 0x prefix here)
            execute-keys | "read val; pfx=""${val%%%%[0-9A-Fa-f]*}""; sfx=""${val##*[0-9A-Fa-f]}""; val=""${val#$pfx}""; val=""${val%%$sfx}""; printf '%%s%%0*X%%s\n' ""$pfx"" ${#val} $((0x$val %arg{1} %reg{c})) ""$sfx"" " <ret>
            # Extend selection to include backslash at front
            execute-keys <a-semicolon> H <a-semicolon>
        } catch %{
            # Search for tokens that look like like new-style octal numbers.
            execute-keys s (\A|\+|-|(?<=[^0-9]))0[Oo][0-7]+ <ret>
            # Convert them to old-style octal numbers, because that's all the
            # shell understands.
            execute-keys | "tr -d Oo" <ret>
            # Apply our operator with shell arithmetic.
            execute-keys | "read val; printf '0o%%0*o\n' $((${#val} - 1)) $(($val %arg{1} %reg{c}))" <ret>

        } catch %{
            # Search for tokens that look like zero-padded decimal numbers.
            execute-keys s (\A|\+|-|(?<=[^0-9]))0[0-9]* <ret>
            # Apply our operator with shell arithmetic.
            execute-keys | "read val; printf '%%0*d\n' ${#val} $(($(echo ""$val"" | sed -E 's/^([-+])?0+/\1/') %arg{1} %reg{c}))" <ret>

        } catch %{
            # Search for tokens that look like unpadded decimal numbers.
            execute-keys s (\A|\+|-|(?<=[^0-9]))[1-9][0-9]* <ret>
            # Apply our operator with shell arithmetic.
            execute-keys | "read val; printf '%%d\n' $(($val %arg{1} %reg{c}))" <ret>
        } catch %{
            fail "No numbers found in selection"
        }
    }
}
