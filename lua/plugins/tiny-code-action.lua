return {
        "rachartier/tiny-code-action.nvim",
        enabled = false,
        event        = "LspAttach",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts         = {
                -- backend        = "delta",
                picker         = {
                        "snacks",
                        opts = {
                                auto_preview = true,
                                hotkeys      = true,
                                hotkeys_mode = "text_based",
                        },
                },
                backend_opts   = {
                        delta = {
                                header_lines_to_remove = 4,
                                line_numbers           = true,
                                layout_strategy        = "vertical"
                        },
                },
                telescope_opts = {
                        layout_strategy = "vertical",
                        layout_config   = {
                                vertical = {
                                        preview_cutoff = 1,
                                        preview_height = function(_, _, max_lines)
                                                local h = math.floor(max_lines * 0.6)
                                                return math.max(h, 10)
                                        end,
                                },
                        },
                },
                signs          = {
                        quickfix                   = { "󰁨", { link = "DiagnosticInfo" } },
                        others                     = { "?", { link = "DiagnosticWarning" } },
                        refactor                   = { "", { link = "DiagnosticWarning" } },
                        ["refactor.move"]          = { "", { link = "DiagnosticInfo" } },
                        ["refactor.extract"]       = { "", { link = "DiagnosticError" } },
                        ["source.organizeImports"] = { "", { link = "TelescopeResultVariable" } },
                        ["source.fixAll"]          = { "", { link = "TelescopeResultVariable" } },
                        ["source"]                 = { "", { link = "DiagnosticError" } },
                        ["rename"]                 = { "", { link = "DiagnosticWarning" } },
                        ["codeAction"]             = { "", { link = "DiagnosticError" } },
                },
                -- filters        = { kind = "refactor", str = "Wrap" },
        }
}
