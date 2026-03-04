---[[
vim.api.nvim_set_hl(0, "varGlobScope", { fg = "#fab387" })
vim.api.nvim_set_hl(0, "varFuncScope", { fg = "#f38ba8" })
vim.api.nvim_set_hl(0, "varClassScope", { fg = "#74c7ec" })
--]]

---[[ GLOBAL SCOPE
vim.api.nvim_create_autocmd("LspTokenUpdate", {
        callback = function(args)
                local token = args.data.token
                if
                           token.type == "variable"
                           and token.modifiers.globalScope
                           and not token.modifiers.readonly
                           and not token.modifiers.defaultLibrary
                then
                        vim.lsp.semantic_tokens.highlight_token(
                                token, args.buf, args.data.client_id, "varGlobScope")
                end
        end,
})
--]]

---[[ FUNCTION SCOPE
vim.api.nvim_create_autocmd("LspTokenUpdate", {
        callback = function(args)
                local token = args.data.token
                if
                           token.type == "variable"
                           and token.modifiers.functionScope
                           and not token.modifiers.readonly
                then
                        vim.lsp.semantic_tokens.highlight_token(
                                token, args.buf, args.data.client_id, "varFuncScope")
                end
        end,
})
--]]

---[[ CLASS SCOPE
vim.api.nvim_create_autocmd("LspTokenUpdate", {
        callback = function(args)
                local token = args.data.token
                if
                           token.type == "constructor"
                           and token.modifiers.identifier
                           and not token.modifiers.readonly
                then
                        vim.lsp.semantic_tokens.highlight_token(
                                token, args.buf, args.data.client_id, "varClassScope")
                end
        end,
})
--]]

---[[
vim.api.nvim_create_autocmd("LspTokenUpdate", {
        callback = function(args)
                local token = args.data.token
                if
                           token.type == "cppType"
                           and token.modifiers.identifier
                           and not token.modifiers.readonly
                then
                        vim.lsp.semantic_tokens.highlight_token(
                                token, args.buf, args.data.client_id, "LspInlayHint")
                end
        end,
})
--]]
