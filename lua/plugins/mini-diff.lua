linq
"MiniDiff"
           { "SignAdd", "DiffChanged" }
           { "SignChange", "DiffChanged" }
           { "SignDelete", "DiffRemoved" }
           { "OverAdd", "DiffAdd" }
           { "OverChange", "DiffChange" }
           { "OverDelete", "DiffDelete" }
           { "OverContext", "DiffText" }
           { "OverChangeBuf", "DiffText" }
           { "OverContextBuf", "DiffText" }

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "nvim-mini/mini.diff",
        version = false,
        event   = "BufReadPost",
        init    = function() vim.o.signcolumn = "yes:1" end,
        keys    = { { "<leader>g", function() require "mini.diff".toggle_overlay() end } },
        opts    = {
                delay   = { text_change = 0 },
                view    = {
                        priority = 2000,
                        style    = "sign",
                        signs    = {
                                -- add    = "▐",
                                -- change = "🮍",
                                add    = "▌",
                                change = "🮌",
                                delete = "🭻",
                        },
                },
                options = { algorithm = "myers", indent_heuristics = true },
        },
}
