return {
        "lukas-reineke/indent-blankline.nvim",
        event  = "VeryLazy",
        main   = "ibl",
        keys   = {
                {
                        "<leader>oi",
                        function()
                                local ibl = require("ibl")

                                Config.indent_line = not Config.indent_line
                                local str          = Icons.symbolKinds.Parameter .. " " .. "Indent Lines"

                                if Config.indent_line then
                                        ibl.update({ enabled = true })
                                        vim.notify(str .. "Enabled",   vim.log.levels.INFO)
                                else
                                        ibl.update({ enabled = false })
                                        vim.notify(str .. "Disabled",   vim.log.levels.INFO)
                                end
                        end,
                        desc = "Indent Lines - Toggle",
                },
        },
        config = function()
                require("ibl").setup({
                        indent     = { char = " ", tab_char = " ", priority = 4 },
                        whitespace = { remove_blankline_trail = true },
                        scope      = {
                                show_start = true,
                                show_end   = false,
                                char       = Icons.misc.verticalBar,
                                highlight  = { "Function" },
                        },
                })
        end,
}
