return {
        cmd          = { "lua-language-server" },
        filetypes    = { "lua" },
        root_markers = {
                ".luarc.json",
                ".luarc.jsonc",
                ".luacheckrc",
                ".stylua.toml",
                "stylua.toml",
                "selene.toml",
                "selene.yml",
                ".git",
        },
        on_init      = function(client)
                local path = vim.uv.cwd()

                if path == vim.fn.stdpath("config") then
                        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                                workspace = { library = { "$VIMRUNTIME", "${3rd}/luv/library" } },
                        })
                end
        end,
        settings     = {
                Lua = {
                        completion    = {
                                displayContext = 999,
                                callSnippet    = "Both",
                                showWord       = "Fallback",
                                workspaceWord  = true,
                                postfix        = "@",
                                autoRequire    = false,
                        },
                        runtime       = {
                                version = "LuaJIT",
                                path    = { "lua/?.lua", "lua/?/?.lua", "lua/?/init.lua" },
                        },
                        diagnostics   = { disable = { "trailing-space", "unused-function", "lowercase-global" } },
                        hover         = { enable = true, enumsLimit = 999, previewFields = 99 },
                        hint          = { enable = true, setType = true, arrayIndex = "Disable", semicolon = "Disable" },
                        semantic      = { enable = false, annotation = true, keyword = false, variable = true },
                        typeFormat    = { config = { auto_complete_end = true, auto_complete_table_sep = true, format_line = true } },
                        codeLens      = { enable = true },
                        signatureHelp = { enable = true },
                        format        = { enable = true },
                        telemetry     = { enable = false },
                },
        },
}
