local colors = Colors.Darkppuccin

local theme = {
        normal   = {
                a = { fg = colors.text, bg = colors.crust, bold = true },
                b = { fg = colors.text, bg = colors.crust },
                c = { fg = colors.surface1, bg = colors.crust },
                x = { fg = colors.text, bg = colors.crust },
                y = { fg = colors.text, bg = colors.crust },
                z = { fg = colors.text, bg = colors.crust },
        },
        insert   = { a = { fg = colors.teal, bg = colors.crust, bold = true } },
        visual   = { a = { fg = colors.yellow, bg = colors.crust, bold = true } },
        replace  = { a = { fg = colors.red, bg = colors.crust, bold = true } },
        inactive = {
                a = { fg = colors.surface1, bg = colors.crust },
                b = { fg = colors.text, bg = colors.crust },
                c = { fg = colors.text, bg = colors.crust },
                x = { fg = colors.text, bg = colors.crust },
                y = { fg = colors.text, bg = colors.crust },
                z = { fg = colors.text, bg = colors.crust },
        },
}

---@param which_bar "tabline"|"winbar"|"inactive_winbar"|"sections"
---@param which_section "lualine_a"|"lualine_b"|"lualine_c"|"lualine_x"|"lualine_y"|"lualine_z"
---@param component function|table the component forming the lualine
---@param where "after"|"before"? defaults to "after"
_G.lualineAdd = function(which_bar, which_section, component, where)
        vim.defer_fn(
                function()
                        local ok, lualine = pcall(require, "lualine")
                        if not (ok and lualine) then return end
                        local component_obj = type(component) == "table" and component or { component }
                        local section_config = lualine.get_config()[which_bar][which_section] or {}
                        local pos = where == "before" and 1 or #section_config + 1
                        table.insert(section_config, pos, component_obj)
                        lualine.setup{ [which_bar] = { [which_section] = section_config } }
                end, 1000)
end

return {
        "nvim-lualine/lualine.nvim",
        lazy         = false,
        dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
        opts         = {
                disabled_filetypes = { "neo-tree" },
                options            = { theme = theme, section_separators = "", component_separators = "" },
                sections           = {
                        lualine_a = { { "mode", fmt = function(str) return str:sub(1, 1) end } },
                        lualine_b = {
                                { "branch", icon = "", color = { fg = colors.teal } },
                                {
                                        "diff",
                                        colored    = true,
                                        diff_color = { added = "String", modified = "GitSignsAdd", removed = "GitSignsDelete" },
                                        symbols    = { added = "+", modified = "~", removed = "-" },
                                        source     = nil,
                                },
                        },
                        lualine_c = {
                                { "filename", file_status = false },
                                { -- SAVED
                                        function()
                                                local saved = vim.bo.modified and "*" or ""
                                                return saved
                                        end,
                                        color = { fg = colors.text },
                                },
                        },
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = {
                                { -- LSP STATUS
                                        "lsp_status",
                                        icon      = "",
                                        color     = { fg = colors.spark, bg = colors.crust },
                                        symbols   = {
                                                spinner = Spinner.dots,
                                                done    = "🬁",
                                        },
                                        show_name = false,
                                },
                                { -- DIAGNOSTICS
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
        },
        config       = function(_, opts)
                require("lualine").setup(opts)
        end,
}
