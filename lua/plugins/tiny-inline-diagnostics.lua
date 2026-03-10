local hl = "DiagnosticVirtualText"

return {
        "rachartier/tiny-inline-diagnostic.nvim",
        event    = "VeryLazy",
        priority = 2001,
        keys     = { { "<leader>od", Toggle.diagnostics, desc = "LSP Diagnostics - Toggle" } },
        opts     = {
                signs   = {
                        left         = "",
                        right        = "",
                        diag         = Icons.Diagnostics.ERROR,
                        arrow        = "",
                        up_arrow     = " ",
                        vertical     = " │",
                        vertical_end = " └",
                },
                blend   = { factor = 0.25 },
                hi      = {
                        error = hl .. "Error",
                        warn  = hl .. "Warn",
                        info  = hl .. "Info",
                        hint  = hl .. "Hint",
                        -- background   = "NormalFloat",
                        -- mixing_color = "NormalFloat",
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
                        add_messages                 = { messages = false, display_count = true, show_multiple_glyphs = true },
                        multilines                   = { enabled = true, trim_whitespaces = true },
                        show_related                 = { enabled = true, max_count = 5 },
                        overflow                     = { mode = "wrap" },
                        break_line                   = { enabled = false, after = 40 },
                        virt_texts                   = { priority = 2001 },
                        experimental                 = { use_window_local_extmarks = true },
                        format                       = function(diag)
                                return diag.message:sub(1, -2)
                        end,
                },
        },
        config   = function(_, opts)
                require("tiny-inline-diagnostic").setup(opts)
                vim.diagnostic.config({ virtual_text = false })
        end,
}
