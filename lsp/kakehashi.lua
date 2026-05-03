---@type vim.lsp.Config
return {
        cmd          = { "kakehashi" },
        filetypes    = { "lua", "cpp", "c" },
        root_markers = { "kakehashi.toml", ".git" },
        init_options = {
                autoInstall     = true,
                languageServers = {
                        ["lua_ls"] = {
                                cmd       = { "lua-languge-server" },
                                languages = { "lua" },
                        },
                },
                languages       = {
                        markdown = {
                                bridge = { lua_ls = { enabled = true } },
                        },
                },
        },
}
