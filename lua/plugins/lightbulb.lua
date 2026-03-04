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
                        text      = Config.Icons.diagnostics.lightbulb,
                        lens_text = Config.Icons.diagnostics.Info,
                        hl        = "LightBulbSign",
                },
                virtual_text    = {
                        enabled   = false,
                        text      = " " .. Config.Icons.diagnostics.lightbulb,
                        lens_text = Config.Icons.diagnostics.Info,
                        pos       = "eol",
                        hl_mode   = "combine",
                        hl        = "LightBulbSign",
                },
                status_text     = { enabled = true },
                autocmd         = { enabled = true, updatetime = 1 },
                ignore          = { clients = { "dev-tools" } },
        },
}
