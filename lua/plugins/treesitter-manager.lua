local o  = vim.o
local v  = vim.v
local fn = vim.fn
local ts = vim.treesitter

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function node(nd)
        return function()
                if ts.get_parser(nil, nil, { error = false }) then
                        require "vim.treesitter._select"["select_" .. nd](v.count1)
                end
        end
end

return {
        "romus204/tree-sitter-manager.nvim",
        event = "BufReadPost",
        init  = function()
                o.foldmethod = "expr"
                o.foldexpr   = vim.treesitter.foldexpr
        end,
        keys  = {
                { "m", node "parent", mode = { "v" } },
                { "M", node "child",  mode = { "v" } },
        },
        opts  = {

                parser_dir       = fn.stdpath "data" .. "/site/parser",
                query_dir        = fn.stdpath "data" .. "/site/queries",
                assume_installed = {},
                ensure_installed = {},
                auto_install     = true,
                noauto_install   = {},
                highlight        = true,
                nohighlight      = {},
                languages        = {
                        lua_patterns = {
                                install_info = {
                                        url = "https://github.com/OXY2DEV/tree-sitter-lua_patterns",
                                },
                        },
                },
                nerdfont         = false,
                border           = Border.Default.None,
                min_width        = 60,
                min_height       = 40,
        },
}
