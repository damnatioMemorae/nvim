return {
        "nvim-treesitter/nvim-treesitter-context",
        event = "BufReadPost",
        keys  = { { "<LocalLeader>c", function() require "treesitter-context".go_to_context(vim.v.count1) end, desc = "Goto context" } },
        init  = function()
                local function h(name) return vim.api.nvim_get_hl(0, { name = name }) end
                vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = h "Comment".fg, bg = h "NormalFloat".bg })
        end,
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
}
