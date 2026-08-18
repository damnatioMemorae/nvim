local o  = vim.o
local v  = vim.v
local fn = vim.fn
local ts = vim.treesitter

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function node(nd)
        if ts.get_parser(nil, nil, { error = false }) then
                require "vim.treesitter._select"["select_" .. nd](v.count1)
        end
end
local parent = function() node "parent" end
local child  = function() node "child" end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "romus204/tree-sitter-manager.nvim",
        event = "BufReadPost",
        init  = function()
                o.foldmethod = "expr"
                o.foldexpr   = [[v:lua.vim.treesitter.foldexpr()]]
        end,
        keys  = { { "m", parent, mode = { "v" } }, { "M", child, mode = { "v" } } },
        opts  = {

                parser_dir       = fn.stdpath "data" .. "/site/parser",
                query_dir        = fn.stdpath "data" .. "/site/queries",
                assume_installed = {},
                ensure_installed = {},
                auto_install     = true,
                noauto_install   = {},
                highlight        = true,
                nohighlight      = {},
                languages        = {},
                nerdfont         = false,
                border           = Border.Default.None,
                min_width        = 60,
                min_height       = 40,
        },
}
