local colors = Colors.Darkppuccin

local customCol = function(C)
        return {

                ----TREESITTER------------------------------------------------------------------------------------------

                SymbolUsage       = { link = "LspInlayHint" },
                LightBulbSign     = { link = "DiagnosticSignHint" },
                TreesitterContext = { bg = colors.mantle, bold = false },
        }
end

return {
        "catppuccin/nvim",
        lazy     = false,
        name     = "catppuccin",
        priority = 2000,
        config   = function()
                require("catppuccin").setup({
                        compile_path           = vim.fn.stdpath"cache" .. "/catppuccin",
                        flavour                = "mocha",
                        transparent_background = false,
                        show_end_of_buffer     = true,
                        term_colors            = true,
                        background             = { light = "latte", dark = "mocha" },
                        dim_inactive           = { enabled = false, shade = "dark", percentage = 0.15 },
                        no_italic              = true,
                        no_bold                = false,
                        no_underline           = true,
                        styles                 = { conditionals = { "italic" }, loops = { "italic" }, misc = {} },
                        color_overrides        = { mocha = { mantle = colors.mantle, crust = colors.crust } },
                        -- custom_highlights      = customCol,
                        default_integrations   = true,
                        auto_integrations      = false,
                        integrations           = {
                                blink_cmp        = true,
                                cmp              = true,
                                dap              = true,
                                dap_ui           = true,
                                dashboard        = true,
                                mason            = true,
                                markdown         = true,
                                render_markdown  = true,
                                mini             = true,
                                notify           = true,
                                neotree          = true,
                                semantic_tokens  = true,
                                treesitter       = true,
                                ufo              = true,
                                dropbar          = { enabled = true, color_mode = false },
                                indent_blankline = { enabled = true, scope_color = "text" },
                                native_lsp       = {
                                        enabled    = true,
                                        underlines = {
                                                errors      = { "nocombine" },
                                                hints       = { "nocombine" },
                                                warnings    = { "nocombine" },
                                                information = { "nocombine" },
                                                ok          = { "nocombine" },
                                        },
                                },
                        },
                })
        end,
}
