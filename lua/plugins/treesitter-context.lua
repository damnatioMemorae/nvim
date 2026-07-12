return {
        "nvim-treesitter/nvim-treesitter-context",
        event        = "BufReadPre",
        dependencies = "nvim-treesitter",
        keys         = { { "<LocalLeader>c", desc = "Goto context", function() require("treesitter-context").go_to_context(vim.v.count1) end } },
        opts         = {
                enable              = true,
                multiwindow         = true,
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

                local h = require("core.utils.misc").getHl

                _G.hlDyn({
                                 { "LineNumberBottom", { underline = false } },
                                 { "LineNumber",       { fg = h("NonText").fg, bg = h("NormalFloat").bg } },
                                 { "Bottom",           { underline = false } },
                         }, "TreesitterContext")
        end,
}
