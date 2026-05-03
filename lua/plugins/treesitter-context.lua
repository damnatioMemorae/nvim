return {
        "nvim-treesitter/nvim-treesitter-context",
        -- event        = "BufReadPre",
        event        = "VeryLazy",
        dependencies = "nvim-treesitter",
        keys         = { { "<LocalLeader>c", function() require("treesitter-context").go_to_context(vim.v.count1) end } },
        opts         = {
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
        },
        config       = function(_, opts)
                require("treesitter-context").setup(opts)

                local h = require("core.utils").getHl

                vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = false })
                vim.api.nvim_set_hl(0, "TreesitterContextLineNumber",       { fg = h("NonText").fg, bg = h("Folded").bg })
                vim.api.nvim_set_hl(0, "TreesitterContextBottom",           { underline = false })
        end,
}
