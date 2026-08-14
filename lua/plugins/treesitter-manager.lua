local o   = vim.o
local v   = vim.v
local fn  = vim.fn
local ts  = vim.treesitter
local lsp = vim.lsp

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function prevNode()
        if ts.get_parser(nil, nil, { error = false }) then
                require "vim.treesitter._select".select_parent(v.count1)
        else
                lsp.buf.selection_range(v.count1)
        end
end
local function nextNode()
        if ts.get_parser(nil, nil, { error = false }) then
                require "vim.treesitter._select".select_child(v.count1)
        else
                lsp.buf.selection_range(-v.count1)
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "romus204/tree-sitter-manager.nvim",
        event  = "BufReadPost",
        init   = function()
                o.foldmethod = "expr"
                o.foldexpr   = "v:lua.ts.foldexpr()"
        end,
        keys   = { { "m", prevNode, mode = { "v", "x" } }, { "M", nextNode, mode = { "v", "x" } } },
        opts   = {

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
        config = function(_, opts)
                require "tree-sitter-manager".setup(opts)
        end,
}
