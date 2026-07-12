; extends

[
        (arguments)
        (comment)
        (do_statement)
        (elseif_statement)
        (else_statement)
        (for_statement)
        (function_declaration)
        (function_definition)
        (if_statement)
        (parameters)
        (repeat_statement)
        (table_constructor)
        (while_statement)
        (return_statement (_))
        (function_call
                name: (method_index_expression
                        table: (function_call
                                name: (dot_index_expression
                                        table: (identifier) @start
                                                (#eq? @start "vim")))))
 ] @fold
