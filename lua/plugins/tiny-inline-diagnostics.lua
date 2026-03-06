return {
        "rachartier/tiny-inline-diagnostic.nvim",
        event   = "VeryLazy",
        opts    = {
                signs   = {
                        left         = "",
                        right        = "",
                        diag         = Icons.diagnostics.ERROR,
                        arrow        = "",
                        up_arrow     = " ",
                        vertical     = " │",
                        vertical_end = " └",
                },
                blend   = { factor = 0.25 },
                hi      = {
                        error = "DiagnosticError",
                        warn  = "DiagnosticWarn",
                        info  = "DiagnosticInfo",
                        hint  = "DiagnosticHint",
                },
                options = {
                        show_source                  = true,
                        throttle                     = 0,
                        softwrap                     = 30,
                        multiple_diag_under_cursor   = true,
                        show_all_diags_on_cursorline = true,
                        enable_on_insert             = false,
                        enable_on_select             = false,
                        overwrite_events             = nil,
                        override_open_float          = true,
                        add_messages                 = { messages = true, display_count = true, show_multiple_glyphs = true },
                        multilines                   = { enabled = true, trim_whitespaces = false },
                        show_related                 = { enabled = true, max_count = 3 },
                        overflow                     = { mode = "wrap" },
                        break_line                   = { enabled = false, after = 30 },
                        virt_texts                   = { priority = 2000 },
                        experimental                 = { use_window_local_extmarks = true },
                        format                       = function(diagnostic)
                                return diagnostic.message .. " [" .. diagnostic.source .. "]"
                        end,
                },
        },
        config  = function(_, opts)
                require("tiny-inline-diagnostic").setup(opts)
                vim.diagnostic.config({ virtual_text = false })
        end,
}
