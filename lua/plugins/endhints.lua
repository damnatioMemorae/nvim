local icons = Icon.Kinds

return {
        "chrisgrieser/nvim-lsp-endhints",
        enabled = false,
        event   = "LspAttach",
        keys    = { { "<leader>oh", Toggle.inlayHints, desc = "LSP Inlay Hints - Toggle" } },
        opts    = {
                icons = {
                        type      = icons.Type .. " ",
                        parameter = icons.Parameter .. " ",
                        offspec   = "o ",
                        unknown   = "?" .. " ",
                },
                label = {
                        truncateAtChars   = 40,
                        padding           = 1,
                        marginLeft        = 0,
                        sameKindSeparator = ", ",
                },
        },
}
