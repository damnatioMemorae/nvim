local icons = Icon.Misc

local function smol(symbol)
        local ref = symbol.references
        local cnt = symbol.stacked_count

        return vim
            .iter {
                    { "", icons.definiton, "Def" },
                    { ref, "r", "Ref" },
                    { cnt > 0 and ("+%d"):format(cnt), "", "@define" },
            }
            :filter(function(i) return i[1] end)
            :fold({}, function(acc, i)
                    if #acc > 0 then acc[#acc + 1] = { "", "NonText" } end
                    acc[#acc + 1] = { " " .. i[2] .. i[1], i[3]:match "^@" and i[3] or "Symbol" .. i[3] }
                    return acc
            end)
end

return {
        "Wansmer/symbol-usage.nvim",
        event = "LspAttach",
        keys  = { { "<leader>os", Toggle.codeLens, desc = "LSP Codelens - Toggle" } },
        opts  = {
                text_format    = smol,
                vt_position    = "end_of_line",
                -- vt_position    = "textwidth",
                -- vt_position    = "above",
                vt_priority    = 2000,
                references     = { enabled = true, include_declaration = false },
                definition     = { enabled = true },
                implementation = { enabled = true },
        },
}
