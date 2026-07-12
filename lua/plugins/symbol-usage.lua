local icons = Icon.Misc

return {
        "Wansmer/symbol-usage.nvim",
        event  = "LspAttach",
        keys   = { { "<leader>os", Toggle.codeLens, desc = "LSP Codelens - Toggle" } },
        config = function()
                local function textFormat(symbol)
                        local b = {} and " " or ""

                        local def  = symbol.definition
                        local ref  = symbol.references
                        local impl = symbol.implementation
                        local cnt  = symbol.stacked_count

                        return vim
                                   .iter({
                                           { def, icons.definiton, "Def" },
                                           { ref, icons.reference, "Ref" },
                                           { impl, icons.implementation, "Impl" },
                                           { cnt > 0 and ("+%d"):format(cnt), "", "@define" },
                                   })
                                   :filter(function(i)
                                           return i[1]
                                   end)
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

                _G.hlLink({
                                  { "Def",  "DiagnosticVirtualTextError" },
                                  { "Ref",  "DiagnosticVirtualTextWarn" },
                                  { "Impl", "DiagnosticVirtualTextHint" },
                          }, "SymbolUsage")
        end,
}
