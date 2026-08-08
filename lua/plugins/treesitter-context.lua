return {
        "nvim-treesitter/nvim-treesitter-context",
        event = "BufReadPost",
        keys  = { { "<LocalLeader>c", function() require "treesitter-context".go_to_context(vim.v.count1) end, desc = "Goto context" } },
        opts  = {
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
        -- config = function(_, opts)
        --         require("treesitter-context").setup(opts)
        --
        --         --  hlDyn({
        --         --                  { "LineNumberBottom", { underline = false } },
        --         --                  { "LineNumber",       { fg = h("NonText").fg, bg = h("NormalFloat").bg } },
        --         --                  { "Bottom",           { underline = false } },
        --         --          }, "TreesitterContext")
        -- end,
}
