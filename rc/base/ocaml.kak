# http://ocaml.org
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# require ocp-indent

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.mli? %{
  set buffer filetype ocaml
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter -group / regions -default code ocaml \
  string '"' (?<!\\)(\\\\)*" '' \
  comment \Q(* \Q*) '' \

add-highlighter -group /ocaml/string fill string
add-highlighter -group /ocaml/comment fill comment

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden ocaml-indent-on-char %{
  eval -no-hooks -draft -itersel %{
    exec ";i<space><esc>Gg|ocp-indent --config base=%opt{indentwidth} --indent-empty --lines %val{cursor_line}<ret>"
  }
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook -group ocaml-highlight global WinSetOption filetype=ocaml %{ add-highlighter ref ocaml }

hook global WinSetOption filetype=ocaml %{
  hook window InsertChar [|\n] -group ocaml-indent ocaml-indent-on-char
}

hook -group ocaml-highlight global WinSetOption filetype=(?!ocaml).* %{ remove-highlighter ocaml }

hook global WinSetOption filetype=(?!ocaml).* %{
  remove-hooks window ocaml-indent
}

# Macro
# ‾‾‾‾‾

%sh{
  keywords=and:as:asr:assert:begin:class:constraint:do:done:downto:else:end:exception:external:false:for:fun:function:functor:if:in:include:inherit:initializer:land:lazy:let:lor:lsl:lsr:lxor:match:method:mod:module:mutable:new:nonrec:object:of:open:or:private:rec:sig:struct:then:to:true:try:type:val:virtual:when:while:with
  echo "
    add-highlighter -group /ocaml/code regex \b($(printf $keywords | tr : '|'))\b 0:keyword
    hook global WinSetOption filetype=ocaml %{
      set window static_words $keywords
    }
    hook global WinSetOption filetype=(?!ocaml).* %{
      unset window static_words
    }
  "
}
