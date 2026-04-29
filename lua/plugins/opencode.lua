local keymap = require("core.utils").uniqueKeymap

return {
        "nickjvandyke/opencode.nvim",
        event = "VeryLazy",
        version      = "*",
        dependencies = {
                {
                        "folke/snacks.nvim",
                        optional = true,
                        opts     = {
                                input  = {},
                                picker = {
                                        actions = {
                                                opencode_send = function(...)
                                                        return require("opencode").snacks_picker_send(...)
                                                end,
                                        },
                                        win     = {
                                                input = {
                                                        keys = {
                                                                ["<A-a>"] = { "opencode_send", mode = { "n", "i" } },
                                                        },
                                                },
                                        },
                                },
                        },
                },
        },
        config       = function()
                vim.g.opencode_opts = {
                        -- Your configuration, if any; goto definition on the type or field for details
                }

                vim.o.autoread = true

                local opencode = require("opencode")
                keymap({ "n", "x" }, "<leader>a", function() opencode.ask("@this: ", { submit = true }) end,
                       { desc = "Ask opencode…" })
                keymap({ "n", "x" }, "<leader>x", function() opencode.select() end, { desc = "Execute opencode action…" })
                keymap({ "n", "t" }, "<C-.>", function() opencode.toggle() end, { desc = "Toggle opencode" })

                keymap({ "n", "x" }, "go", function() return opencode.operator("@this ") end,
                       { desc = "Add range to opencode", expr = true })
                keymap("n", "goo", function() return opencode.operator("@this ") .. "_" end,
                       { desc = "Add line to opencode", expr = true })

                keymap("n", "<S-C-u>", function() opencode.command("session.half.page.up") end,
                       { desc = "Scroll opencode up" })
                keymap("n", "<S-C-d>", function() opencode.command("session.half.page.down") end,
                       { desc = "Scroll opencode down" })

                -- keymap("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
                -- keymap("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
        end,
}
