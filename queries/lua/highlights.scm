; extends

((identifier) @namespace.builtin
        (#any-of? @namespace.builtin "vim" "hs"))

(break_statement) @keyword.return

; ((function_definition "function" @function) (#set! conceal " "))
; ((function_declaration "function" @function) (#set! conceal " "))
((function_definition "function" @function) (#set! conceal "λ"))
((function_declaration "function" @function) (#set! conceal "λ"))
; ((binary_expression "~=" @operator) (#set! conceal "≠"))
((binary_expression ">=" @operator) (#set! conceal "≥"))
((binary_expression "<=" @operator) (#set! conceal "≤"))
; ((binary_expression "==" @operator) (#set! conceal ""))
; ((binary_expression "or" @operator) (#set! conceal "∨"))
; ((binary_expression "and" @operator) (#set! conceal "∧"))
