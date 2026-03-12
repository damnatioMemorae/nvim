; extends

((placeholder_type_specifier) @type.builtin.cpp
        (#eq? @keyword.return "auto")
        (#set! priority 130))

; ((field_expression "->" @operator) (#set! conceal ""))
; ((lambda_expression "[]" @function) (#set! conceal "λ"))
; ((lambda_declarator "()" @function) (#set! conceal "λ"))
; ((lambda_capture_specifier "[]" @function) (#set! conceal "λ"))
