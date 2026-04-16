local style   = {
        local_name_style             = { "snake_case" },
        function_param_name_style    = { "camel_case", "pascal_case" },
        function_name_style          = "camel_case",
        local_function_name_style    = "camel_case",
        global_variable_name_style   = "camel_case",
        module_name_style            = "upper_snake_case",
        module_local_name_style      = { "camel_case", "snake_case" },
        require_module_name_style    = { "upper_snake_case", "snake_case" },
        class_name_style             = "upper_snake_case",
        constant_variable_name_style = "camel_case",
        table_field_name_style       = { "snake_case", "camel_case", "pascal_case" },
}
local format  = {
        indent_style = "space",
        indent_size  = "8",
        tab_width    = "4",
        quote_style  = "double",

        continuation_indent      = "11",
        max_line_length          = "120",
        end_of_line              = "unset",
        table_separator_style    = "comma",
        trailing_table_separator = "smart",
        call_arg_parentheses     = "keep",
        detect_end_of_line       = "false",
        insert_final_newline     = "true",

        ignore_spaces_inside_function_call           = "false",
        space_after_comma_in_for_statement           = "true",
        space_after_comma                            = "true",
        space_after_comment_dash                     = "false",
        space_around_assign_operator                 = "true",
        space_around_concat_operator                 = "true",
        space_around_logical_operator                = "true",
        space_around_math_operator                   = "true",
        space_around_table_append_operator           = "false",
        space_around_table_field_list                = "true",
        space_before_attribute                       = "false",
        space_before_closure_open_parenthesis        = "false",
        space_before_function_call_open_parenthesis  = "false",
        space_before_function_call_single_arg        = "none",
        space_before_function_open_parenthesis       = "false",
        space_before_inline_comment                  = "1",
        space_before_open_square_bracket             = "false",
        space_inside_function_call_parentheses       = "false",
        space_inside_function_param_list_parentheses = "false",
        space_inside_square_brackets                 = "false",

        align_call_args                    = "true",
        align_function_params              = "true",
        align_continuous_assign_statement  = "true",
        align_continuous_rect_table_field  = "true",
        align_continuous_line_space        = "1",
        align_if_branch                    = "false",
        align_array_table                  = "true",
        align_continuous_similar_call_args = "true",
        align_continuous_inline_comment    = "true",
        align_chain_expr                   = "none",

        never_indent_before_if_condition  = "false",
        never_indent_comment_on_if_branch = "false",
        keep_indents_on_empty_lines       = "false",
        allow_non_indented_comments       = "false",

        line_space_after_if_statement              = "keep",
        line_space_after_do_statement              = "keep",
        line_space_after_while_statement           = "keep",
        line_space_after_repeat_statement          = "keep",
        line_space_after_for_statement             = "keep",
        line_space_after_local_or_assign_statement = "keep",
        line_space_after_function_statement        = "fixed(2)",
        line_space_after_expression_statement      = "keep",
        line_space_after_comment                   = "keep",
        line_space_around_block                    = "fixed(1)",
        break_all_list_when_line_exceed            = "false",
        auto_collapse_lines                        = "false",
        break_before_braces                        = "false",

        ignore_space_after_colon                 = "false",
        remove_call_expression_list_finish_comma = "false",
        end_statement_with_semicolon             = "keep",
}
local builtin = {
        ["basic"]       = "enable",
        ["bit"]         = "enable",
        ["bit32"]       = "enable",
        ["builtin"]     = "enable",
        ["coroutine"]   = "enable",
        ["debug"]       = "enable",
        ["ffi"]         = "enable",
        ["io"]          = "enable",
        ["jit"]         = "enable",
        ["math"]        = "enable",
        ["os"]          = "enable",
        ["package"]     = "enable",
        ["string"]      = "enable",
        ["table"]       = "enable",
        ["table.clear"] = "enable",
        ["table.new"]   = "enable",
        ["utf8"]        = "enable",
}

local root_markers1 = {
        ".emmyrc.json",
        ".luarc.json",
        ".luarc.jsonc",
}
local root_markers2 = {
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
}

local on_init = function(client)
        local path = vim.uv.cwd()

        if path == vim.fn.stdpath("config") then
                local lazy = vim.fn.stdpath("data") .. "/lazy"
                local libs = {
                        vim.env.VIMRUNTIME,
                        "${3rd}/luv/library",
                        "${3rd}/busted/library",
                        lazy .. "/snacks.nvim/lua",
                        -- vim.api.nvim_get_runtime_file("", true),
                }

                client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                        workspace       = { library = libs, ignoreDir = "templates" },
                        diagnostics     = { globals = "Snacks" },
                        groupFileStatus = { luadoc = "Any", conventions = "Any" },
                })
        end
end

---@type vim.lsp.Config
return {
        cmd          = { "lua-language-server" },
        filetypes    = { "lua" },
        root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers1, root_markers2, { ".git" } }
                   or vim.list_extend(vim.list_extend(root_markers1, root_markers2), { ".git" }),
        settings     = {
                Lua = {
                        completion    = {
                                callSnippet    = "Both",
                                displayContext = 10000,
                                enable         = true,
                                keywordSnippet = "Both",
                                showWord       = "Enable",
                                workspaceWord  = true,
                                postfix        = "@",
                                autoRequire    = false,
                        },
                        runtime       = {
                                version = "LuaJIT",
                                path    = { "lua/?.lua", "lua/?/?.lua", "lua/?/init.lua" },
                                builtin = builtin,
                        },
                        diagnostics   = {
                                disable            = { "trailing-space", "unused-function", "lowercase-global", "spell-check" },
                                groupFileStatus    = { ["codestyle"] = "Any" },
                                unusedLocalExclude = { "_*" },
                                ignoredFiles       = "Disable",
                                workspaceEvent     = "OnChange",
                                workspaceDelay     = 10000,
                                workspaceRate      = 100,
                        },
                        nameStyle     = { config = style },
                        hover         = { enable = true, enumsLimit = 1000, previewFields = 0 },
                        hint          = { enable = true, awaitPropagate = true, setType = true, arrayIndex = "Disable", semicolon = "Disable" },
                        semantic      = { enable = false, annotation = true, keyword = false, variable = true },
                        codeLens      = { enable = true },
                        signatureHelp = { enable = true },
                        telemetry     = { enable = false },
                        format        = { enable = true, defaultConfig = format },
                        language      = { fixIndent = true, completeAnnotation = true },
                        type          = { castNumberToInteger = true, checkTableShape = true, inferParamType = true },
                        typeFormat    = { config = { auto_complete_end = "true", auto_complete_table_sep = "true", format_line = "true" } },
                        workspace     = { preloadFileSize = 10000, useGitignore = false },
                },
        },
        on_init      = on_init,
}
