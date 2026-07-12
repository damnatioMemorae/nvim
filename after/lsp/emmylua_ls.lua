local style = {
        local_name_style             = { "snake_case" },
        function_param_name_style    = { "camel_case" },
        function_name_style          = { "camel_case" },
        local_function_name_style    = { "camel_case" },
        global_variable_name_style   = { "pascal_case" },
        module_name_style            = { "upper_snake_case" },
        module_local_name_style      = { "camel_case", "snake_case" },
        require_module_name_style    = { "upper_snake_case", "snake_case" },
        class_name_style             = { "upper_snake_case" },
        constant_variable_name_style = { "camel_case", "pascal_case" },
        table_field_name_style       = { "snake_case", "camel_case", "pascal_case" },
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

local mason = vim.fn.stdpath("data") .. "/mason/bin"
local _lazy = vim.fn.stdpath("data") .. "/lazy"
local _libs = {
        vim.env.VIMRUNTIME,
        "${3rd}/luv/library",
        "${3rd}/busted/library",
}

---@type vim.lsp.Config
return {
        cmd          = { "emmylua_ls" },
        filetypes    = { "lua" },
        root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers1, root_markers2, { ".git" } }
                   or vim.list_extend(vim.list_extend(root_markers1, root_markers2), { ".git" }),
        settings     = {
                emmylua = {
                        completion     = {
                                -- autoRequireFunction         = "safeRequire",
                                autoRequireFunction         = "require",
                                autoRequireNamingConvention = "snake-case",
                                callSnippet                 = true,
                                baseFunctionIncludesName    = true,
                        },
                        doc            = {
                                syntax = "md",
                        },
                        runtime        = {
                                version = "LuaJIT",
                                requireLikeFunctions = { "safeRequire", "_G.safeRequire" },
                        },
                        workspace      = {
                                -- library = vim.api.nvim_get_runtime_file("", true),
                                library = _libs,
                        },
                        strict         = {
                                requirePath = false,
                                typeCall    = false,
                        },
                        semanticTokens = { enable = false },
                        hint           = {
                                enable        = true,
                                paramHint     = true,
                                indexHint     = true,
                                localHint     = true,
                                overrideHint  = true,
                                metaCallHint  = true,
                                enumParamHint = true,
                        },
                        references     = {
                                enable            = true,
                                fuzzySearch       = true,
                                shortStringSearch = true,
                        },
                        hover          = {
                                enable       = true,
                                customDetail = 255,
                        },
                        format         = {
                                externalTool = {
                                        program = mason .. "/emmylua-codeformat",
                                        args    = {
                                                "-",
                                                "-i",
                                                "-d",
                                                "-f",
                                                "${file}",
                                                "-ow",
                                                -- "-o",
                                                -- "${file}",
                                                -- "-c " .. vim.fn.stdpath("config") .. "/.editorconfig",
                                        },
                                },
                        },
                },
        },
}
