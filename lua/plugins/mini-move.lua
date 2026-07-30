return {
        "echasnovski/mini.move",
        version = false,
        event   = "BufReadPre",
        opts    = {
                mappings = {

                        left  = "<S-Tab>",
                        down  = "<M-j>",
                        up    = "<M-k>",
                        right = "<Tab>",

                        line_left  = "<S-Tab>",
                        line_down  = "<M-j>",
                        line_up    = "<M-k>",
                        -- line_right = "<Tab>",
                },
                options  = { reindent_linewise = true },
        },
}
