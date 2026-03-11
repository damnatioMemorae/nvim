return {
        "igorlfs/nvim-dap-view",
        lazy = false,
        opts = {
                winbar  = {
                        show_keymap_hints = false,
                        sections          = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "disassembly" },
                },
                windows = { size = 0.3, position = "right" },
                help    = { border = Border.borderStyle },
                icons   = {
                        collapsed  = "󰅂 ",
                        disabled   = "",
                        disconnect = "",
                        enabled    = "",
                        expanded   = "󰅀 ",
                        filter     = "󰈲",
                        negate     = " ",
                        pause      = "",
                        play       = "",
                        run_last   = "",
                        step_back  = "",
                        step_into  = "",
                        step_out   = "",
                        step_over  = "",
                        terminate  = "",
                },
        },
}
