local C = require("core.colors").catppuccin

return {
        "nvim-lualine/lualine.nvim",
        lazy         = false,
        dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
        config       = function()
                local theme = {
                        normal   = {
                                a = { fg = C.text, bg = C.base, bold = true },
                                b = { fg = C.text, bg = C.crust },
                                c = { fg = C.surface1, bg = C.crust },
                                x = { fg = C.text, bg = C.crust },
                                y = { fg = C.text, bg = C.crust },
                                z = { fg = C.text, bg = C.crust },
                        },
                        insert   = { a = { fg = C.teal, bg = C.base, bold = true } },
                        visual   = { a = { fg = C.yellow, bg = C.base, bold = true } },
                        replace  = { a = { fg = C.red, bg = C.base, bold = true } },
                        inactive = {
                                a = { fg = C.surface1, bg = C.crust },
                                b = { fg = C.text, bg = C.crust },
                                c = { fg = C.text, bg = C.crust },
                                x = { fg = C.text, bg = C.crust },
                                y = { fg = C.text, bg = C.crust },
                                z = { fg = C.text, bg = C.crust },
                        },
                }
                require("lualine").setup({
                        disabled_filetypes = { "neo-tree" },
                        options            = {
                                theme                = theme,
                                section_separators   = "",
                                component_separators = "",
                        },
                        sections           = {
                                lualine_a = { { "mode", fmt = function(str) return str:sub(1, 1) end } },
                                lualine_b = {
                                        { "branch", icon = "", color = { fg = C.teal } },
                                        {
                                                "diff",
                                                colored    = true,
                                                diff_color = { added = "String", modified = "GitSignsAdd", removed = "GitSignsDelete" },
                                                symbols    = { added = "+", modified = "~", removed = "-" },
                                                source     = nil,
                                        },
                                },
                                lualine_c = { { "filename", file_status = false } },
                                lualine_x = {},
                                lualine_y = {
                                        {
                                                function()
                                                        local saved = vim.bo.modified and "*" or ""
                                                        return saved
                                                end,
                                        },
                                },
                                lualine_z = {
                                        {
                                                "diagnostics",
                                                sources           = { "nvim_diagnostic", "coc" },
                                                sections          = { "error", "warn", "info" },
                                                diagnostics_color = {
                                                        error = "DiagnosticError",
                                                        warn  = "DiagnosticWarn",
                                                        info  = "DiagnosticInfo",
                                                        hint  = "DiagnosticHint",
                                                },
                                                symbols           = { error = "", warn = " ", info = " ", hint = " " },
                                                colored           = true,
                                                update_in_insert  = true,
                                                always_visible    = true,
                                        },
                                },
                        },
                        inactive_sections  = {
                                lualine_a = { { "filename", file_status = true } },
                                lualine_b = {},
                                lualine_c = {},
                                lualine_x = {},
                                lualine_y = {},
                                lualine_z = {},
                        },
                        extensions         = { "neo-tree" },
                })
        end,
}
