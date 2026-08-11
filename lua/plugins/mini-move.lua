return {
        "echasnovski/mini.move",
        version = false,
        event   = "BufReadPre",
        opts    = {
                -- a
                mappings = {
                        left       = "<left>",
                        down       = "<down>",
                        up         = "<up>",
                        right      = "<right>",
                        line_left  = "<left>",
                        line_down  = "<down>",
                        line_up    = "<up>",
                        line_right = "<right>",
                },
                options  = { reindent_linewise = true },
        },
}
