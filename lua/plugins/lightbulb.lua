local icon = Icons.Misc.lightbulb
local hl   = "LspCodeAction"

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
                        text      = icon,
                        lens_text = Icons.Diagnostics.Info,
                        hl        = hl,
                },
                virtual_text    = {
                        enabled   = false,
                        text      = " " .. icon,
                        lens_text = Icons.Diagnostics.Info,
                        pos       = "eol",
                        hl_mode   = "combine",
                        hl        = hl,
                },
                status_text     = { enabled = true },
                autocmd         = { enabled = true, updatetime = 1 },
                ignore          = { clients = { "dev-tools" } },
        },
}
