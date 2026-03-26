return {
        "rachartier/tiny-code-action.nvim",
        event        = "LspAttach",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts         = {
                backend = "vim",
                picker  = {
                        "buffer",
                        opts = {
                                winborder    = Border.borderStyle,
                                auto_preview = false,
                                auto_accept  = true,
                                hotkeys      = true,
                                hotkeys_mode = "text_based",
                        },
                },
                notify  = { enabled = false },
                signs   = {
                        ["codeAction"]             = { Icons.Misc.lightbulb, { link = "DiagnosticError" } },
                        ["quickfix"]               = { Icons.Misc.quickfix, { link = "DiagnosticInfo" } },
                        ["others"]                 = { Icons.Misc.offSpec, { link = "DiagnosticWarning" } },
                        ["refactor"]               = { "", { link = "DiagnosticWarning" } },
                        ["refactor.move"]          = { "", { link = "DiagnosticInfo" } },
                        ["refactor.extract"]       = { "", { link = "DiagnosticError" } },
                        ["source.organizeImports"] = { "", { link = "TelescopeResultVariable" } },
                        ["source.fixAll"]          = { "", { link = "TelescopeResultVariable" } },
                        ["source"]                 = { "", { link = "DiagnosticError" } },
                        ["rename"]                 = { "", { link = "DiagnosticWarning" } },
                },
        },
}
