_G.Toggle = {}

function Toggle.codeLens()
        local loaded, symbol = pcall(require, "symbol-usage")

        Config.codeLens = not Config.codeLens
        local msg       = Icons.Misc.reference .. " " .. "CodeLens - "

        if loaded and Config.codeLens then
                symbol.toggle_globally()
                symbol.refresh()
                vim.notify(msg .. "Enabled", vim.log.levels.WARN)
        else
                symbol.toggle_globally()
                symbol.refresh()
                vim.notify(msg .. "Disabled", vim.log.levels.ERROR)
        end
end

function Toggle.inlayHints()
        local loaded, endhints = pcall(require, "lsp-endhints")

        Config.inlayHints = not Config.inlayHints
        local msg         = Icons.Kinds.Parameter .. " " .. "Inlay Hints - "

        if loaded and Config.inlayHints then
                endhints.enable()
                vim.lsp.inlay_hint.enable(Config.inlayHints)
                vim.notify(msg .. "Enabled", vim.log.levels.WARN)
        else
                endhints.disable()
                vim.lsp.inlay_hint.enable(Config.inlayHints)
                vim.notify(msg .. "Disabled", vim.log.levels.ERROR)
        end
end

function Toggle.indentLine()
        local loaded, ibl = pcall(require, "ibl")

        Config.indentLine = not Config.indentLine
        local msg         = Icons.Misc.verticalBar .. " " .. "Indent Lines - "

        if loaded and Config.indentLine then
                ibl.update({ enabled = Config.indentLine })
                vim.notify(msg .. "Enabled",                vim.log.levels.WARN)
        else
                ibl.update({ enabled = Config.indentLine })
                vim.notify(msg .. "Disabled",               vim.log.levels.ERROR)
        end
end

function Toggle.diagnostics()
        local loaded, diagnostics = pcall(require, "tiny-inline-diagnostic")

        Config.conceal = not Config.conceal
        local msg      = Icons.Diagnostics.ERROR .. " " .. "Diagnostics - "

        if loaded and Config.conceal then
                diagnostics.enable()
                vim.diagnostic.enable(Config.conceal)
                vim.notify(msg .. "Enabled", vim.log.levels.WARN)
        else
                diagnostics.disable()
                vim.diagnostic.enable(Config.conceal)
                vim.notify(msg .. "Disabled", vim.log.levels.ERROR)
        end
end

function Toggle.concealLvl()
        local msg = Icons.Diagnostics.ERROR .. " " .. "Conceal Level - "

        vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
        vim.notify(msg .. vim.wo.conceallevel, vim.log.levels.WARN)
end

function Toggle.all()
        vim.schedule(function()
                Toggle.codeLens()
                Toggle.inlayHints()
                Toggle.indentLine()
                Toggle.diagnostics()
        end)
end
