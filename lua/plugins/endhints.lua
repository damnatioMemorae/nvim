return {
        "chrisgrieser/nvim-lsp-endhints",
        event = "LspAttach",
        keys  = { {
                "<leader>oh",
                function()
                        local endhints = require("lsp-endhints")

                        Config.inlay_hints = not Config.inlay_hints
                        local str         = Icons.symbolKinds.Parameter .. " " .. "Inlay Hints - "

                        if Config.inlay_hints then
                                endhints.enable()
                                vim.lsp.inlay_hint.enable(Config.inlay_hints)
                                vim.notify(str .. "Enabled", vim.log.levels.INFO)
                        else
                                endhints.disable()
                                vim.lsp.inlay_hint.enable(Config.inlay_hints)
                                vim.notify(str .. "Disabled", vim.log.levels.INFO)
                        end
                end,
                desc = "LSP Inlay Hints - Toggle",
        } },
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
