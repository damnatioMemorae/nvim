return {
        "chrisgrieser/nvim-lsp-endhints",
        event = "LspAttach",
        keys  = { { "<leader>oh", function() require("lsp-endhints").toggle() end, desc = "LSP Inlay Hints - Toggle" } },
        opts  = {
                icons = {
                        type      = Config.Icons.symbolKindsAlt.Type .. " ",
                        parameter = Config.Icons.symbolKinds.Parameter .. " ",
                        offspec   = Config.Icons.misc.offSpec .. " ",
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
