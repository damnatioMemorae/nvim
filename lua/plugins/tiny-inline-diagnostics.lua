return {
        "rachartier/tiny-inline-diagnostic.nvim",
        event    = "LspAttach",
        priority = 8000,
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
                options = {
                        show_source                  = true,
                        throttle                     = 0,
                        softwrap                     = 25,
                        multiple_diag_under_cursor   = true,
                        show_all_diags_on_cursorline = true,
                        enable_on_insert             = false,
                        enable_on_select             = false,
                        overwrite_events             = nil,
                        override_open_float          = true,
                        add_messages                 = { messages = true, display_count = false, show_multiple_glyphs = true },
                        multilines                   = { enabled = true, trim_whitespaces = true },
                        show_related                 = { enabled = true, max_count = 5 },
                        overflow                     = { mode = "wrap" },
                        break_line                   = { enabled = false, after = 25 },
                        virt_texts                   = { priority = 8000 },
                        experimental                 = { use_window_local_extmarks = true },
                        format                       = function(diag)
                                -- return diag.message:sub(1, -2) .. " " .. "[" .. diag.source:sub(1, -2) .. "]"
                                return diag.message .. " " .. "[" .. diag.source .. "]"
                        end,
                },
        },
        config   = function(_, opts)
                require("tiny-inline-diagnostic").setup(opts)
                vim.diagnostic.config({ virtual_text = false })

                local name = { "Error", "Warn", "Info", "Hint" }
                for _, hl in pairs(name) do
                        local tiny      = "TinyInlineDiagnosticVirtualText" .. hl
                        local diag      = "DiagnosticVirtualText" .. hl
                        local underline = "DiagnosticUnderline" .. hl
                        local bg        = vim.api.nvim_get_hl(0, { name = diag }).bg

                        vim.api.nvim_set_hl(0, tiny, { link = diag })

                        vim.api.nvim_set_hl(0, underline, { bg = bg })

                        for _, mix in pairs(name) do
                                vim.api.nvim_set_hl(0, tiny .. "Mix" .. mix, { link = diag })
                        end
                end
        end,
}
