return {
        "Wansmer/symbol-usage.nvim",
        event  = "LspAttach",
        keys   = { { "<leader>os", Toggle.codeLens, desc = "LSP Codelens - Toggle" } },
        config = function()
                local bg          = {}
                local _groups_col = {
                        { "Def",  "@lsp.type.parameter", "DiagnosticUnderlineError" },
                        { "Ref",  "@keyword",            "DiagnosticUnderlineWarn" },
                        { "Impl", "@class",              "DiagnosticUnderlineHint" },
                }
                local groups      = {
                        { "Def",   "@variable",   "LspInlayHint" },
                        { "Ref",   "Keyword",     "LspInlayHint" },
                        { "Impl",  "Structure",   "LspInlayHint" },
                        { "Round", "LspInlayHint" },
                }

                local h = require("core.utils").getHl

                local function hl(list)
                        for _, hl_groups in ipairs(list) do
                                local symbol, fg_col, bg_col = unpack(hl_groups)
                                vim.api.nvim_set_hl(0, "SymbolUsage" .. symbol,
                                                    { fg = h(fg_col).fg, bg = h(bg_col).bg, bold = false })
                        end
                end

                hl(groups)

                local function textFormat(symbol)
                        local b = bg and " " or ""

                        return vim.iter({
                                           { symbol.definition, Icons.Misc.definiton, "Def" },
                                           { symbol.references, Icons.Misc.reference, "Ref" },
                                           { symbol.implementation, Icons.Misc.implementation, "Impl" },
                                           { symbol.stacked_count > 0 and ("+%d"):format(symbol.stacked_count), "", "@define" },
                                   })
                                   :filter(function(i) return i[1] end)
                                   :fold({}, function(acc, i)
                                           if #acc > 0 then
                                                   acc[#acc + 1] = { " ", "NonText" }
                                           end

                                           acc[#acc + 1] = {
                                                   b .. i[2] .. " " .. i[1] .. b,
                                                   i[3]:match("^@") and i[3] or "SymbolUsage" .. i[3],
                                           }

                                           return acc
                                   end)
                end

                require("symbol-usage").setup({
                        text_format    = textFormat,
                        vt_position    = "end_of_line",
                        vt_priority    = 2000,
                        references     = { enabled = true, include_declaration = false },
                        definition     = { enabled = true },
                        implementation = { enabled = true },
                })
        end,
}
