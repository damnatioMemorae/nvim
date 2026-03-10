return {
        "chrisgrieser/nvim-lsp-endhints",
        event = "LspAttach",
        keys  = { { "<leader>oh", Toggle.inlayHints, desc = "LSP Inlay Hints - Toggle" } },
        opts  = {
                icons = {
                        type      = Icons.KindsAlt.Type .. " ",
                        parameter = Icons.Kinds.Parameter .. " ",
                        offspec   = Icons.Misc.offSpec .. " ",
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
