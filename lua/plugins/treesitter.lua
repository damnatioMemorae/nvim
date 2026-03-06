local parsers       = "all"
local ignoreParsers = { "toml", "ipkg" }

return {
        ---[[
        { -- TREESITTER MASTER BRANCH
                "nvim-treesitter/nvim-treesitter",
                branch = "master",
                event  = "BufReadPre",
                build  = ":TSUpdate",
                opts   = {
                        parser_install_dir    = "~/.local/share/nvim/site",
                        auto_install          = true,
                        ensure_installed      = parsers,
                        ignore_install        = ignoreParsers,
                        highlight             = {
                                enable                            = true,
                                additional_vim_regex_highlighting = false,
                        },
                        indent                = { enable = true, disable = { "markdown" } },
                        textobjects           = {
                                lsp_interop = { enable = true, border = Config.borderStyle },
                                select      = { lookahead = true, include_surrounding_whitespace = false },
                        },
                        incremental_selection = {
                                enable  = true,
                                keymaps = {
                                        init_selection    = ",v",
                                        node_incremental  = "<CR>",
                                        scope_incremental = ",v",
                                        node_decremental  = "<Backspace>",
                                },
                        },
                },
                config = function(_, opts)
                        require("nvim-treesitter.configs").setup(opts)
                end,
        },
        --]]
        { -- NODE ACTIONS
                "ckolkey/ts-node-action",
                enabled = false,
                dependencies = { "nvim-treesitter/nvim-treesitter" },
                event        = "VeryLazy",
                config       = function()
                        require("ts-node-action").setup({})
                        local tsn     = require("ts-node-action.actions")
                        local map     = vim.keymap.set
                        local formats = { "snake_case", "pascal_case", "screaming_snake_case", "camel_case" }
                        -- local formats = { "snake_case", "Pascal_case", "SCREAMING_SNAKE_CASE", "camelCase" }
                        map("n", ">", function() tsn.cycle_case(formats) end)
                end,
        },
        { -- CONTEXT
                "nvim-treesitter/nvim-treesitter-context",
                dependencies = { "nvim-treesitter/nvim-treesitter" },
                event        = "VeryLazy",
                config       = function()
                        require("treesitter-context").setup{
                                enable              = true,
                                multiwindow         = false,
                                max_lines           = 2,
                                min_window_height   = 1,
                                line_numbers        = true,
                                multiline_threshold = 20,
                                trim_scope          = "outer",
                                mode                = "cursor",
                                separator           = nil,
                                zindex              = 20,
                                on_attach           = nil,
                        }

                        vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = false })
                        vim.api.nvim_set_hl(0, "TreesitterContextBottom",           { underline = false })

                        vim.keymap.set("n", ",t", function()
                                               require("treesitter-context").go_to_context(vim.v.count1)
                                       end, { silent = true })
                end,
        },
        { -- TREEWALKER
                "aaronik/treewalker.nvim",
                enabled = false,
                event   = "VeryLazy",
                keys    = {
                        { "<A-H>", "<cmd>Treewalker Left<CR>",      mode = { "n", "v", "x", "o" } },
                        { "<A-J>", "<cmd>Treewalker Down<CR>",      mode = { "n", "v", "x", "o" } },
                        { "<A-K>", "<cmd>Treewalker Up<CR>",        mode = { "n", "v", "x", "o" } },
                        { "<A-L>", "<cmd>Treewalker Right<CR>",     mode = { "n", "v", "x", "o" } },

                        { "<A-A>", "<cmd>Treewalker SwapLeft<CR>",  mode = { "n", "v", "x", "o" } },
                        { "<A-S>", "<cmd>Treewalker SwapUp<CR>",    mode = { "n", "v", "x", "o" } },
                        { "<A-D>", "<cmd>Treewalker SwapDown<CR>",  mode = { "n", "v", "x", "o" } },
                        { "<A-F>", "<cmd>Treewalker SwapRight<CR>", mode = { "n", "v", "x", "o" } },
                },
                opts    = {
                        highlight_duration = 400,
                        highlight_group    = "Visual",
                },
        },
        { -- HYPR
                "theRealCarneiro/hyprland-vim-syntax",
                dependencies = { "nvim-treesitter/nvim-treesitter" },
                event        = "VeryLazy",
                ft           = "hypr",
        },
}
