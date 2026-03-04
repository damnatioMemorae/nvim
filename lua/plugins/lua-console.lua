return {
        "yarospace/lua-console.nvim",
        event = "VeryLazy",
        keys  = {
                { "`",         desc = "Lua Console - Toggle" },
                { "<leader>`", desc = "Lua Console - Attach to buffer" },
        },
        opts  = {
                buffer   = {
                        autosave         = false,
                        load_on_start    = false,
                        strip_local      = false,
                        preserve_context = false,
                },
                window = {
                        border = Config.borderStyle,
                        height = 0.4,
                },
                mappings = {
                        quit = "<Esc>",
                        -- quit = "q",
                        open = ",f",
                },
        },
}
