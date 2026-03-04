local parsers = "$HOME/.local/share/nvim/site/parser"
local queries = "$HOME/.local/share/nvim/lazy/nvim-treesitter"
local custom  = "$HOME/.config/nvim"

return {
        cmd          = { "kakehashi" },
        root_markers = { "kakehashi.toml", ".git" },
        filetypes    = { "markdown", "lua", "cpp", "c", "bash", "go" },
        init_options = {
                -- searchPaths     = { parsers, queries, custom },
                -- searchPaths     = { parsers },
                autoInstall     = true,
                languageServers = {
                        lua_ls = {
                                cmd       = { "lua-language-server" },
                                languages = { "lua" },
                        },
                },
                languages       = {
                        lua      = { parser = "$HOME/.local/share/nvim/site/parser/lua.so" },
                        markdown = { bridge = { lua_ls = { enabled = true } } },
                        cpp      = { bridge = { lua_ls = { enabled = true } } },
                },
        },
}
