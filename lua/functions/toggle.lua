local g          = vim.g
local wo         = vim.wo
local lsp        = vim.lsp
local log        = vim.log
local diagnostic = vim.diagnostic

local levels = log.levels

local misc  = Icon.Misc
local diag  = Icon.Diagnostics
local kinds = Icon.Kinds

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
_G.Toggle = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function notify(msg, state)
        if state == "Enabled" then
                vim.notify(msg .. "Enabled", levels.WARN)
        elseif state == "Disabled" then
                vim.notify(msg .. "Disabled", levels.ERROR)
        end
end

local function toggleCodeLens()
        local loaded, symbol = pcall(require, "symbol-usage")

        g.codeLens = not g.codeLens
        local msg  = misc.reference .. " " .. "CodeLens - "
        if not loaded then
                return
        elseif g.codeLens then
                symbol.toggle_globally()
                symbol.refresh()
                notify(msg, "Enabled")
        else
                symbol.toggle_globally()
                symbol.refresh()
                notify(msg, "Disabled")
        end
end

local function toggleInlayHints()
        local loaded, endhints = pcall(require, "lsp-endhints")

        g.inlayHints = not g.inlayHints
        local msg    = kinds.Parameter .. " " .. "Inlay Hints - "
        if not loaded then
                return
        elseif g.inlayHints then
                endhints.enable()
                lsp.inlay_hint.enable(g.inlayHints)
                notify(msg, "Enabled")
        else
                endhints.disable()
                lsp.inlay_hint.enable(g.inlayHints)
                notify(msg, "Disabled")
        end
end

local function toggleIndentLines()
        local loaded, ibl = pcall(require, "ibl")

        g.indentLines = not g.indentLines
        local msg     = misc.verticalBar .. " " .. "Indent Lines - "
        if not loaded then
                return
        elseif g.indentLines then
                ibl.update { enabled = g.indentLines }
                notify(msg, "Enabled")
        else
                ibl.update { enabled = g.indentLines }
                notify(msg, "Disabled")
        end
end

local function toggleDiagnostics()
        local loaded, diagnostics = pcall(require, "tiny-inline-diagnostic")

        g.conceal = not g.conceal
        local msg = diag.ERROR .. " " .. "Diagnostics - "
        if not loaded then
                return
        elseif g.conceal then
                diagnostics.enable()
                diagnostic.enable(g.conceal)
                notify(msg, "Enabled")
        else
                diagnostics.disable()
                diagnostic.enable(g.conceal)
                notify(msg, "Disabled")
        end
end

local function toggleConcealLvl()
        local msg = diag.ERROR .. " " .. "Conceal Level - "

        wo.conceallevel = wo.conceallevel == 0 and 2 or 0
        vim.notify(msg .. wo.conceallevel, levels.WARN)
end

local function toggleListMode(mode)
        mode = mode or g.qf_mode
        match(mode) {
                { "quickfix", "c" }, function()
                g.qf_mode = "l"
                vim.notify("list: loclist", levels.WARN)
        end,
                { "loclist",  "l" }, function()
                g.qf_mode = "c"
                vim.notify("list: quickfix", levels.WARN)
        end,
        }
end

local function toggleAll()
        vim.schedule(function()
                Toggle.codeLens()
                Toggle.inlayHints()
                Toggle.indentLines()
                Toggle.diagnostics()
        end)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Toggle = {
        codeLens    = toggleCodeLens,
        inlayHints  = toggleInlayHints,
        indentLines = toggleIndentLines,
        diagnostics = toggleDiagnostics,
        concealLvl  = toggleConcealLvl,
        qfMode      = toggleListMode,
        all         = toggleAll,
}
