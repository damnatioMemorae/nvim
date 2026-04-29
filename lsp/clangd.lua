local function switchSourceHeader(bufnr)
        local method_name = "textDocument/switchSourceHeader"
        local client      = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
        if not client then
                return vim.notify(("method %s is not supported by any servers active on the current buffer"):format(
                        method_name))
        end
        local params = vim.lsp.util.make_text_document_params(bufnr)
        ---@diagnostic disable-next-line: unknown-diag-code
        ---@diagnostic disable-next-line: param-type-not-match, param-type-mismatch
        client.request(method_name, params, function(err, result)
                               if err then
                                       error(tostring(err))
                               end
                               if not result then
                                       vim.notify("corresponding file cannot be determined")
                                       return
                               end
                               vim.cmd.edit(vim.uri_to_fname(result))
                       end, bufnr)
end

local function symbolInfo()
        local bufnr         = vim.api.nvim_get_current_buf()
        local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
        ---@diagnostic disable-next-line: unknown-diag-code
        ---@diagnostic disable-next-line: param-type-not-match, missing-parameter, param-type-mismatch
        if not clangd_client or not clangd_client.supports_method"textDocument/symbolInfo" then
                return vim.notify("Clangd client not found", vim.log.levels.ERROR)
        end
        local win    = vim.api.nvim_get_current_win()
        local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
        ---@diagnostic disable-next-line: unknown-diag-code
        ---@diagnostic disable-next-line: param-type-not-match, param-type-mismatch
        clangd_client.request("textDocument/symbolInfo", params, function(err, res)
                                      if err or #res == 0 then
                                              -- Clangd always returns an error, there is not reason to parse it
                                              return
                                      end
                                      local container = string.format("container: %s", res[1].containerName) ---@type string
                                      local name      = string.format("name: %s", res[1].name) ---@type string
                                      vim.lsp.util.open_floating_preview({ name, container }, "", {
                                              height    = 2,
                                              width     = math.max(string.len(name), string.len(container)),
                                              focusable = false,
                                              focus     = false,
                                              border    = Border.borderStyle,
                                              title     = "Symbol Info",
                                      })
                                      ---@diagnostic disable-next-line: unknown-diag-code
                                      ---@diagnostic disable-next-line: param-type-not-match, param-type-mismatch
                              end, bufnr)
end

local function semanticTokens()
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
end

local cmd = {
        "clangd",

        "--all-scopes-completion=true",
        "--background-index",
        "--background-index-priority=background",
        -- "--check",
        "--clang-tidy",
        "--completion-parse=always",
        -- "--completion-parse=never",
        -- "--completion-style=bundled",
        "--completion-style=detailed",
        -- "--debug-origin",
        -- "--experimental-modules-support",
        "--fallback-style=llvm",
        "--function-arg-placeholders=0",
        "--header-insertion-decorators",
        -- "--header-insertion=iwyu",
        "--import-insertions",
        "-j=8",
        "--limit-references=0",
        -- "--limit-results=0",
        "--log=verbose",
        "--malloc-trim",
        "--parse-forwarding-functions",
        "--pch-storage=memory",
        -- "--ranking-model=decision_forest",
        "--ranking-model=heuristics",
        "--rename-file-limit=0",
        -- "--use-dirty-headers",
}

---@type vim.lsp.Config
return {
        cmd                = cmd,
        filetypes          = { "c", "cpp" },
        root_markers       = {
                "build.ninja",
                ".clangd",
                ".clang-format",
                ".clang-tidy",
                "compile_commands.json",
                "compile_flags.txt",
                "config.h.in",
                "configure.ac",
                "configure.in",
                ".git",
                "Makefile",
                "meson.build",
                "meson_options.txt",
        },
        settings           = {
                clangd = {
                        InlayHints         = {
                                Designators    = true,
                                Enabled        = true,
                                ParameterNames = true,
                                DeducedTypes   = true,
                        },
                        Completion         = { AllScopes = true, ArgumentLists = "Delimiters" },
                        CompileFlags       = { Add = "-Iinclude" },
                        usePlaceholders    = true,
                        completeUnimported = true,
                        clangdFileStatus   = true,
                        fallbackFlags      = { "-std=c++23" },
                },
        },
        capabilities       = { semanticTokens = { multilineTokenSupport = true } },
        on_init            = function(client, initResult)
                if initResult.offsetEncoding then
                        client.offset_encoding = initResult.offsetEncoding
                end
        end,
        on_attach          = function(_, bufnr)
                vim.api.nvim_buf_create_user_command(bufnr, "LspClangdSwitchSourceHeader", function()
                                                             switchSourceHeader(bufnr)
                                                     end, { desc = "Switch between source/header" })
                vim.api.nvim_buf_create_user_command(bufnr, "LspClangdShowSymbolInfo", function()
                                                             symbolInfo()
                                                     end, { desc = "Show symbol info" })

                semanticTokens()
        end,
        workspace_required = false,
}
