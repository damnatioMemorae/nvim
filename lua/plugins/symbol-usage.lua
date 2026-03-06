return {
        "Wansmer/symbol-usage.nvim",
        enabled = true,
        event   = "VeryLazy",
        keys    = {
                { "<leader>os", function()
                        require("symbol-usage").toggle_globally()
                        require("symbol-usage").refresh()
                end },
        },
        config  = function()
                local bg        = {}
                -- local bg        = "LspInlayHint"
                local groupsCol = { ---@diagnostic disable-line: unused-local
                        { "Def",  "@lsp.type.parameter", "DiagnosticUnderlineError" },
                        { "Ref",  "@keyword",            "DiagnosticUnderlineWarn" },
                        { "Impl", "@class",              "DiagnosticUnderlineHint" },
                }
                local groups    = {
                        { "Def",   "@lsp.type.parameter", "LspInlayHint" },
                        { "Ref",   "@keyword",            "LspInlayHint" },
                        { "Impl",  "@class",              "LspInlayHint" },
                        { "Round", "LspInlayHint" },
                }

                local function h(name) return vim.api.nvim_get_hl(0, { name = name }) end

                local function hl(list)
                        for _, hlGroups in ipairs(list) do
                                local symbol, fgCol, bgCol = unpack(hlGroups)
                                vim.api.nvim_set_hl(0, "SymbolUsage" .. symbol,
                                                    { fg = h(fgCol).fg, bg = h(bgCol).bg, bold = false })
                        end
                end

                hl(groups)

                ---[[
                local function text_format(symbol)
                        local res    = {}
                        local empty  = ""
                        local sep    = " "
                        local border = " "

                        local stacked_functions_content = symbol.stacked_count > 0
                                   and ("+%s"):format(symbol.stacked_count) or ""

                        local function insert(icon, sym, hlStr)
                                if bg == nil then border = "" end
                                return table.insert(res, { border .. icon .. sep .. tostring(sym) .. border,
                                        "SymbolUsage" .. hlStr })
                        end

                        if symbol.definition then
                                if #res > 0 then table.insert(res, { " ", "NonText" }) end
                                insert(Icons.misc.definiton, symbol.definition, "Def")
                        end

                        if symbol.references then
                                if #res > 0 then table.insert(res, { " ", "NonText" }) end
                                insert(Icons.misc.reference, symbol.definition, "Ref")
                        end

                        if symbol.implementation then
                                if #res > 0 then table.insert(res, { " ", "NonText" }) end
                                insert(Icons.misc.implementation, symbol.implementation, "Impl")
                        end

                        if stacked_functions_content ~= "" then
                                if #res > 0 then
                                        table.insert(res, { " ", "NonText" })
                                end
                                table.insert(res, { empty, "SymbolUsageDef" })
                                table.insert(res, { " " .. tostring(stacked_functions_content), "SymbolUsageImpl" })
                                table.insert(res, { empty, "SymbolUsageDef" })
                        end

                        return res
                end
                --]]

                require("symbol-usage").setup({
                        text_format    = text_format,
                        -- text_format    = drawSymbol,
                        -- vt_position    = "textwidth",
                        vt_position    = "end_of_line",
                        -- vt_position    = "above",
                        vt_priority    = 1000,
                        references     = { enabled = true, include_declaration = false },
                        definition     = { enabled = true },
                        implementation = { enabled = true },
                })
        end,
}
