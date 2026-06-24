return {
        "dnlhc/glance.nvim",
        cmd    = "Glance",
        keys   = {
                { "<LocalLeader>r", "<cmd>Glance references<CR>" },
                { "<LocalLeader>d", "<cmd>Glance definitions<CR>" },
                { "<LocalLeader>i", "<cmd>Glance implementations<CR>" },
                { "<LocalLeader>D", "<cmd>Glance type_definitions<CR>" },
        },
        opts   = {
                height               = 20,
                preserve_win_context = true,
                preview_win_opts     = { cursorline = false, number = false, wrap = false },
                border               = { enable = false, top_char = " ", bottom_char = " " },
                list                 = { width = 0.30 },
                indent_lines         = { enable = false },
                winbar               = { enable = true },
                mappings             = {
                        list = {
                                ["j"]       = function() require("glance").actions.next() end,
                                ["k"]       = function() require("glance").actions.previous() end,
                                ["<Down>"]  = function() require("glance").actions.next() end,
                                ["<Up>"]    = function() require("glance").actions.previous() end,
                                ["<Tab>"]   = function() require("glance").actions.next_location() end,
                                ["<S-Tab>"] = function() require("glance").actions.previous_location() end,
                                ["<C-u>"]   = function() require("glance").actions.preview_scroll_win(5) end,
                                ["<C-d>"]   = function() require("glance").actions.preview_scroll_win(-5) end,
                                ["v"]       = function() require("glance").actions.jump_vsplit() end,
                                ["s"]       = function() require("glance").actions.jump_split() end,
                                ["t"]       = function() require("glance").actions.jump_tab() end,
                                ["<CR>"]    = function() require("glance").actions.jump() end,
                                ["o"]       = function() require("glance").actions.jump() end,
                                ["l"]       = function() require("glance").actions.open_fold() end,
                                ["h"]       = function() require("glance").actions.close_fold() end,
                                ["K"]       = function() require("glance").actions.enter_win("preview") end,
                                ["q"]       = function() require("glance").actions.close() end,
                                ["Q"]       = function() require("glance").actions.close() end,
                                ["<Esc>"]   = function() require("glance").actions.close() end,
                                ["<C-q>"]   = function() require("glance").actions.quickfix() end,
                        },
                        preview = {
                                ["Q"]       = function() require("glance").actions.close() end,
                                ["<Tab>"]   = function() require("glance").actions.next_location() end,
                                ["<S-Tab>"] = function() require("glance").actions.previous_location() end,
                                ["K"]       = function() require("glance").actions.enter_win("list") end,
                        },
                },
        },
        config = function(_, opts)
                require("glance").setup(opts)

                local groups = {
                        { "PreviewNormal",       "Normal" },
                        { "PreviewMatch",        "LspReferenceWrite" },
                        { "PreviewCursorLine",   "CursorLine" },
                        -- { "PreviewSignColumn"   , "" },
                        { "PreviewEndOfBuffer",  "Normal" },
                        { "PreviewLineNr",       "LineNr" },
                        { "PreviewBorderBottom", "Normal" },
                        { "WinBarFilename",      "LspKindFile" },
                        { "WinBarFilepath",      "LspKindFile" },
                        { "WinBarTitle",         "Title" },
                        { "ListNormal",          "NormalFloat" },
                        { "ListFilename",        "LspKindFile" },
                        { "ListFilepath",        "LspKindFile" },
                        { "ListCount",           "LspReferenceWrite" },
                        { "ListMatch",           "LspReferenceWrite" },
                        { "ListCursorLine",      "Visual" },
                        { "ListEndOfBuffer",     "NormalFloat" },
                        { "ListBorderBottom",    "NormalFloat" },
                        -- { "FoldIcon"            , "" },
                        -- { "Indent"              , "" },
                        -- { "BorderTop",            "PmenuDoc" },
                }
                vim.iter(groups):each(function(group)
                        vim.api.nvim_set_hl(0, "Glance" .. group[1], { link = group[2] })
                end)
        end,
}
