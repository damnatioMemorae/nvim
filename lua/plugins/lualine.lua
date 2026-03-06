local colors = Colors.Darkppuccin

return {
        "nvim-lualine/lualine.nvim",
        lazy         = false,
        dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
        config       = function()
                local theme = {
                        normal   = {
                                a = { fg = colors.text, bg = colors.base, bold = true },
                                b = { fg = colors.text, bg = colors.crust },
                                c = { fg = colors.surface1, bg = colors.crust },
                                x = { fg = colors.text, bg = colors.crust },
                                y = { fg = colors.text, bg = colors.crust },
                                z = { fg = colors.text, bg = colors.crust },
                        },
                        insert   = { a = { fg = colors.teal, bg = colors.base, bold = true } },
                        visual   = { a = { fg = colors.yellow, bg = colors.base, bold = true } },
                        replace  = { a = { fg = colors.red, bg = colors.base, bold = true } },
                        inactive = {
                                a = { fg = colors.surface1, bg = colors.crust },
                                b = { fg = colors.text, bg = colors.crust },
                                c = { fg = colors.text, bg = colors.crust },
                                x = { fg = colors.text, bg = colors.crust },
                                y = { fg = colors.text, bg = colors.crust },
                                z = { fg = colors.text, bg = colors.crust },
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
                                        { "branch", icon = "", color = { fg = Colors.teal } },
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
