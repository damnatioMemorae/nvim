return {
        "chrisgrieser/nvim-lsp-endhints",
        event = "LspAttach",
        keys  = { { "<leader>oh", function() require("lsp-endhints").toggle() end, desc = "LSP Inlay Hints - Toggle" } },
        opts  = {
                icons = {
                        type      = Icons.symbolKindsAlt.Type .. " ",
                        parameter = Icons.symbolKinds.Parameter .. " ",
                        offspec   = Icons.misc.offSpec .. " ",
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
