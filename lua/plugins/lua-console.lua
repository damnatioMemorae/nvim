return {
        "yarospace/lua-console.nvim",
        ft   = { "lua" },
        keys = {
                { "`",         desc = "Lua Console - Toggle" },
                { "<leader>`", desc = "Lua Console - Attach to buffer" },
        },
        opts = {
                buffer   = {
                        result_prefix    = ">>> ",
                        autosave         = false,
                        load_on_start    = false,
                        strip_local      = false,
                        preserve_context = false,
                },
                window   = {
                        title = "",
                        border = Border.borderStyle,
                        height = 0.4,
                },
                mappings = {
                        quit = "<Esc>",
                        open = "<LocalLeader>f",
                },
        },
}
