local o   = vim.o
local fn  = vim.fn

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "romus204/tree-sitter-manager.nvim",
        event  = "BufReadPost",
        init   = function()
                o.foldmethod = "expr"
                o.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
        end,
        keys   = {
                {
                        "m",
                        function()
                                if vim.treesitter.get_parser(nil, nil, { error = false }) then
                                        require "vim.treesitter._select".select_parent(vim.v.count1)
                                else
                                        vim.lsp.buf.selection_range(vim.v.count1)
                                end
                        end,
                        mode = { "v", "x" },
                },
                {
                        "M",
                        function()
                                if vim.treesitter.get_parser(nil, nil, { error = false }) then
                                        require "vim.treesitter._select".select_child(vim.v.count1)
                                else
                                        vim.lsp.buf.selection_range(-vim.v.count1)
                                end
                        end,
                        mode = { "v", "x" },
                },
        },
        opts   = {

                parser_dir       = fn.stdpath("data") .. "/site/parser",
                query_dir        = fn.stdpath("data") .. "/site/queries",
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
                require("tree-sitter-manager").setup(opts)
        end,
}
