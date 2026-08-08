return {
        "echasnovski/mini.move",
        version = false,
        event   = "BufReadPre",
        opts    = {
                -- a
                mappings = {
                        left      = "<left>",
                        down      = "<down>",
                        up        = "<up>",
                        right     = "<right>",
                        line_left = "<S-Tab>",
                        line_down = "<M-j>",
                        line_up   = "<M-k>",
                        -- line_right = "<Tab>",
                },
                options  = { reindent_linewise = true },
        },
}
