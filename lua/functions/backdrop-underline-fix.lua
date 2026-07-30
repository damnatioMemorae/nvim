local function toggleUnderlines()
        local change = vim.bo.buftype == "" and "underline" or "none"

        vim.cmd.highlight("@markup.link.url gui=" .. change)
        vim.cmd.highlight("@markup.link.url.markdown_inline gui=" .. change)
        vim.cmd.highlight("@string.special.url.comment gui=" .. change)
        vim.cmd.highlight("@string.special.url.html gui=" .. change)
        vim.cmd.highlight("Underlined gui=" .. change)

        -- vim.api.nvim_set_hl(0, "LspReferenceWrite", { underdashed = vim.bo.buftype == "" })
        -- vim.api.nvim_set_hl(0, "LspReferenceRead", { underdotted = vim.bo.buftype == "" })
end

vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
        desc = "User: FIX underlines for backdrop",
        callback = function(ctx)
                local ft = ctx.match
                if ctx.event == "WinEnter" or ft == "snacks_input" or ft == "DressingInput" then
                        vim.defer_fn(toggleUnderlines, 1)
                end
        end,
})
