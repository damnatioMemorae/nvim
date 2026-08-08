linq
"Glance"
           { "FoldIcon", "Comment" }
           { "ListNormal", "Normal" }
           { "ListFilename", "Directory" }
           { "ListFilepath", "Comment" }
           { "ListMatch", "Search" }
           { "ListCursorLine", "PmenuSel" }
           { "ListEndOfBuffer", "Normal" }
           { "ListBorderBottom", "Normal" }
           { "ListCount", "DiagnosticVirtualTextWarn" }
           { "PreviewNormal", "Normal" }
           { "PreviewMatch", "IncSearch" }
           { "PreviewCursorLine", "CursorLine" }
           { "PreviewEndOfBuffer", "Normal" }
           { "PreviewLineNr", "LineNr" }
           { "PreviewBorderBottom", "Normal" }
           { "WinBarFilename", "LspKindFile" }
           { "WinBarFilepath", "LspKindFile" }
           { "WinBarTitle", "Title" }

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function goto(tgt)
        return {
                "<LocalLeader>" .. tgt:sub(1, 1),
                function() require "glance".open(tgt) end,
                desc   = "LSP Goto " .. tgt,
                unique = false,
        }
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "dnlhc/glance.nvim",
        enabled = false,
        event   = "LspAttach",
        keys    = { goto "references", goto "definitions", goto "implementations", goto "type_definitions" },
        opts    = {
                height               = 25,
                preserve_win_context = true,
                preview_win_opts     = { cursorline = false, number = false, wrap = false },
                border               = { enable = false, top_char = " ", bottom_char = " " },
                list                 = { width = 0.35 },
                indent_lines         = { enable = true, icon = " " },
                winbar               = { enable = false },
                mappings             = {
                        preview = {
                                ["Q"]       = function() require "glance".actions.close() end,
                                ["<Tab>"]   = function() require "glance".actions.next_location() end,
                                ["<S-Tab>"] = function() require "glance".actions.previous_location() end,
                                ["K"]       = function() require "glance".actions.enter_win "list" end,
                        },
                        list    = {
                                ["j"]       = function() require "glance".actions.next() end,
                                ["k"]       = function() require "glance".actions.previous() end,
                                ["<Down>"]  = function() require "glance".actions.next() end,
                                ["<Up>"]    = function() require "glance".actions.previous() end,
                                ["<Tab>"]   = function() require "glance".actions.next_location() end,
                                ["<S-Tab>"] = function() require "glance".actions.previous_location() end,
                                ["<C-u>"]   = function() require "glance".actions.preview_scroll_win(5) end,
                                ["<C-d>"]   = function() require "glance".actions.preview_scroll_win(-5) end,
                                ["v"]       = function() require "glance".actions.jump_vsplit() end,
                                ["s"]       = function() require "glance".actions.jump_split() end,
                                ["t"]       = function() require "glance".actions.jump_tab() end,
                                ["<CR>"]    = function() require "glance".actions.jump() end,
                                ["o"]       = function() require "glance".actions.jump() end,
                                ["l"]       = function() require "glance".actions.open_fold() end,
                                ["h"]       = function() require "glance".actions.close_fold() end,
                                ["K"]       = function() require "glance".actions.enter_win "preview" end,
                                ["q"]       = function() require "glance".actions.close() end,
                                ["Q"]       = function() require "glance".actions.close() end,
                                ["<Esc>"]   = function() require "glance".actions.close() end,
                                ["<C-q>"]   = function() require "glance".actions.quickfix() end,
                        },
                },
                hooks                = {
                        before_open = function(results, open, jump, _)
                                when(#results == 1)(function()
                                        jump(results[1])
                                end)(function() open(results) end)
                        end,
                },
        },
}
