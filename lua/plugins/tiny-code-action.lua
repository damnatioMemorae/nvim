return {
        "rachartier/tiny-code-action.nvim",
        enabled = false,
        event        = "LspAttach",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts         = {
                backend        = "vim",
                picker         = {
                        "buffer",
                        opts = {
                                winborder    = Config.borderStyle,
                                auto_preview = true,
                                hotkeys      = true,
                                hotkeys_mode = "text_based",
                                auto_accept  = true,
                        },
                },
                signs          = {
                        quickfix                   = { Icons.misc.quickfix, { link = "DiagnosticInfo" } },
                        others                     = { Icons.misc.offSpec, { link = "DiagnosticWarning" } },
                        refactor                   = { "", { link = "DiagnosticWarning" } },
                        ["refactor.move"]          = { "", { link = "DiagnosticInfo" } },
                        ["refactor.extract"]       = { "", { link = "DiagnosticError" } },
                        ["source.organizeImports"] = { "", { link = "TelescopeResultVariable" } },
                        ["source.fixAll"]          = { "", { link = "TelescopeResultVariable" } },
                        ["source"]                 = { "", { link = "DiagnosticError" } },
                        ["rename"]                 = { "", { link = "DiagnosticWarning" } },
                        ["codeAction"]             = { Icons.misc.lightbulb, { link = "DiagnosticError" } },
                },
        },
}
