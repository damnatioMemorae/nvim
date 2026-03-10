return {
        "kosayoda/nvim-lightbulb",
        event = "LspAttach",
        opts  = {
                priority        = 2000,
                link_highlights = true,
                code_lenses     = true,
                validate_config = "always",
                sign            = {
                        enabled   = true,
                        text      = Icons.Misc.lightbulb,
                        lens_text = Icons.Diagnostics.Info,
                        hl        = "LightBulbSign",
                },
                virtual_text    = {
                        enabled   = false,
                        text      = " " .. Icons.Misc.lightbulb,
                        lens_text = Icons.Diagnostics.Info,
                        pos       = "eol",
                        hl_mode   = "combine",
                        hl        = "LightBulbSign",
                },
                status_text     = { enabled = true },
                autocmd         = { enabled = true, updatetime = 1 },
                ignore          = { clients = { "dev-tools" } },
        },
}
