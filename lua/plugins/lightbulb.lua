local bulb = Icon.Misc.lightbulb
local info = Icon.Diagnostics.Info
local hl   = "DiagnosticHint"

return {
        "kosayoda/nvim-lightbulb",
        event = "LspAttach",
        init  = function() vim.o.signcolumn = "yes:1" end,
        opts  = {
                priority        = 4000,
                link_highlights = true,
                code_lenses     = true,
                validate_config = "always",
                sign            = {
                        enabled   = true,
                        text      = bulb,
                        lens_text = info,
                        hl        = hl,
                },
                virtual_text    = {
                        enabled   = false,
                        text      = " " .. bulb,
                        lens_text = info,
                        pos       = "eol",
                        hl_mode   = "combine",
                        hl        = hl,
                },
                status_text     = { enabled = true },
                autocmd         = { enabled = true, updatetime = 1 },
                ignore          = { clients = { "dev-tools" } },
        },
}
