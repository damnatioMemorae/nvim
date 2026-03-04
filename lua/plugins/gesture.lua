return {
        "notomo/gesture.nvim",
        lazy   = false,
        config = function()
                local gesture = require("gesture")
                -- gesture.setup({})

                vim.o.mouse          = "a"
                vim.o.mousemoveevent = true

                vim.keymap.set("n", "<LeftDrag>",    gesture.draw,   { silent = true })
                vim.keymap.set("n", "<LeftRelease>", gesture.finish, { silent = true })

                gesture.register({
                        name   = "Scroll to bottom",
                        inputs = { gesture.down() },
                        action = "normal! G",
                })
                gesture.register({
                        name   = "Scroll to top",
                        inputs = { gesture.up() },
                        action = "normal! go",
                })
                gesture.register({
                        name   = "Next buffer",
                        inputs = { gesture.right() },
                        action = "bnext",
                })
                gesture.register({
                        name   = "Prev buffer",
                        inputs = { gesture.left() },
                        action = "bprevious",
                })
        end,
}
