return {
        "L3MON4D3/LuaSnip",
        event  = "InsertEnter",
        opts   = {},
        config = function(_, opts)
                require("luasnip").setup(opts)

                vim.keymap.set({ "i", "s", "n" }, "<Esc>", function()
                                       if require("luasnip").expand_or_jumpable() then
                                               require("luasnip").unlink_current()
                                       end
                                       vim.cmd("noh")
                                       return "<Esc>"
                               end, { desc = "Escape, clear hlsearch, and stop snippet session", expr = true })
        end,
}
