; extends

; hyprland
((function_call
        name: (dot_index_expression
                field: (identifier) @method)
        (#eq? @method "exec_cmd")
        arguments: (arguments
                (string
                content: (string_content) @injection.content)))
        (#set! injection.language "bash"))

; injected language
((comment) @injection.language
        (string
                content: (string_content) @injection.content
                (#set! injection.combined))
        (#gsub! @injection.language ".*%[%[%s*([%w_]+)%s*%]%].*"  "%1"))

((comment) @injection.language
                arguments: (arguments
                        (string
                        content: (string_content) @injection.content
                        (#set! injection.combined)))
        (#gsub! @injection.language ".*%[%[%s*([%w_]+)%s*%]%].*"  "%1"))

((comment) @injection.language
        (field
                value: (string
                        content: (string_content) @injection.content
                        (#set! injection.combined)))
        (#gsub! @injection.language ".*%[%[%s*([%w_]+)%s*%]%].*" "%1"))

((comment) @injection.language
        (expression_list
                value: (string
                        content: (string_content) @injection.content
                        (#set! injection.combined)))
        (#gsub! @injection.language ".*%[%[%s*([%w_]+)%s*%]%].*" "%1"))
