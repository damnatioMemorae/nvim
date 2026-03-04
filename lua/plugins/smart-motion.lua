return {
        "FluxxField/smart-motion.nvim",
        enabled = false,
        event   = "VeryLazy",
        opts    = {
                flow_state_timeout_ms     = 1000,
                use_background_highlights = false,
                presets                   = {
                        words       = false,
                        lines       = false,
                        search      = true,
                        delete      = true,
                        yank        = true,
                        change      = true,
                        paste       = true,
                        treesitter  = true,
                        diagnostics = true,
                        git         = true,
                        quickfix    = true,
                        marks       = true,
                        misc        = true,
                },
        },
}
