; extends

((identifier) @namespace.builtin
        (#any-of? @namespace.builtin "vim" "hs"))

((break_statement) @keyword.return
        (#set! priority 130))

("return" @keyword.return
        (#set! priority 130))

((identifier) @keyword.return
        (#eq? @keyword.return "assert")
        (#set! priority 130))

((goto_statement) @keyword.return
        (#set! priority 130))

((label_statement) @keyword.return
        (#set! priority 130))


; ((function_definition "function" @function) (#set! conceal " "))
; ((function_declaration "function" @function) (#set! conceal " "))
((function_definition "function" @function) (#set! conceal "λ"))
; ((function_declaration "function" @function) (#set! conceal "λ"))
; ((binary_expression "~=" @operator) (#set! conceal "≠"))
; ((binary_expression ">=" @operator) (#set! conceal "≥"))
; ((binary_expression "<=" @operator) (#set! conceal "≤"))
; ((binary_expression "==" @operator) (#set! conceal ""))
; ((binary_expression "or" @operator) (#set! conceal "∨"))
; ((binary_expression "and" @operator) (#set! conceal "∧"))
