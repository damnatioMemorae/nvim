return {
        "luiscassih/AniMotion.nvim",
        enabled = false,
        event   = "BufReadPost",
        opts    = {
                mode       = "helix",
                edit_keys  = { "c", "d", "s", "r", "y" },
                clear_keys = { "<Esc>" },
                map_visual = false,
                color      = { link = "LspReferenceWrite" },
        },
}
