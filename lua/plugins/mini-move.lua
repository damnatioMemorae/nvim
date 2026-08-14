return {
        "nvim-mini/mini.move",
        version = false,
        event   = "BufReadPre",
        opts    = {
                mappings = {
                        left       = "<M-left>",
                        down       = "<M-down>",
                        up         = "<M-up>",
                        right      = "<M-right>",
                        line_left  = "<M-left>",
                        line_down  = "<M-down>",
                        line_up    = "<M-up>",
                        line_right = "<M-right>",
                },
                options  = { reindent_linewise = true },
        },
}
