local g      = vim.g
local api    = vim.api
local cmd    = vim.cmd
local lsp    = vim.lsp
local log    = vim.log
local levels = log.levels

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function switchSourceHeader(bufnr, client)
        local method_name = "textDocument/switchSourceHeader"
        ---@diagnostic disable-next-line:param-type-mismatch
        if not client or not client:supports_method(method_name) then
                return vim.notify(("method %s is not supported by any servers active on the current buffer"):format(
                        method_name))
        end
        local params = lsp.util.make_text_document_params(bufnr)
        ---@diagnostic disable-next-line:param-type-mismatch
        client:request(method_name, params, function(err, result)
                               if err then
                                       error(tostring(err))
                               end
                               if not result then
                                       vim.notify "corresponding file cannot be determined"
                                       return
                               end
                               cmd.edit(vim.uri_to_fname(result))
                       end, bufnr)
end

local function symbolInfo(bufnr, client)
        local method_name = "textDocument/symbolInfo"
        ---@diagnostic disable-next-line:param-type-mismatch
        if not client or not client:supports_method(method_name) then
                return vim.notify("Clangd client not found", levels.ERROR)
        end
        local win    = api.nvim_get_current_win()
        local params = lsp.util.make_position_params(win, client.offset_encoding)
        ---@diagnostic disable-next-line:param-type-mismatch
        client:request(method_name, params, function(err, res)
                               if err or #res == 0 then
                                       return
                               end
                               local container = string.format("container: %s", res[1].containerName) ---@type string
                               local name      = string.format("name: %s", res[1].name) ---@type string
                               lsp.util.open_floating_preview({ name, container }, "", {
                                       anchor_bias = "below",
                                       border      = Border.Default.Normal,
                                       height      = 2,
                                       width       = math.max(string.len(name), string.len(container)),
                                       focusable   = false,
                                       focus       = false,
                                       title       = "",
                               })
                       end, bufnr)
end

local function semanticTokens()
        ---[[ GLOBAL SCOPE
        auq "LspTokenUpdate" {
                callback = function(args)
                        local token = args.data.token
                        if  token.type == "variable"
                        and token.modifiers.globalScope
                        and not token.modifiers.readonly
                        and not token.modifiers.defaultLibrary
                        then
                                lsp.semantic_tokens.highlight_token(
                                        token, args.buf, args.data.client_id, "varGlobScope")
                        end
                end,
        }
        --]]

        ---[[ FUNCTION SCOPE
        auq "LspTokenUpdate" {
                callback = function(args)
                        local token = args.data.token
                        if  token.type == "variable"
                        and token.modifiers.functionScope
                        and not token.modifiers.readonly
                        then
                                lsp.semantic_tokens.highlight_token(
                                        token, args.buf, args.data.client_id, "varFuncScope")
                        end
                end,
        }
        --]]

        ---[[ CLASS SCOPE
        auq "LspTokenUpdate" {
                callback = function(args)
                        local token = args.data.token
                        if  token.type == "constructor"
                        and token.modifiers.identifier
                        and not token.modifiers.readonly
                        then
                                lsp.semantic_tokens.highlight_token(
                                        token, args.buf, args.data.client_id, "varClassScope")
                        end
                end,
        }
        --]]

        ---[[
        auq "LspTokenUpdate" {
                callback = function(args)
                        local token = args.data.token
                        if  token.type == "cppType"
                        and token.modifiers.identifier
                        and not token.modifiers.readonly
                        then
                                lsp.semantic_tokens.highlight_token(
                                        token, args.buf, args.data.client_id, "LspInlayHint")
                        end
                end,
        }
        --]]
end

local command = {
        "clangd",
        "--j=" .. tostring(g.nproc - 1),
        "--all-scopes-completion=true",
        "--background-index",
        "--background-index-priority=background",
        "--clang-tidy",
        "--completion-parse=always",
        "--completion-style=detailed",
        "--fallback-style=llvm",
        "--function-arg-placeholders=0",
        "--header-insertion-decorators",
        "--header-insertion=iwyu",
        "--import-insertions",
        "--limit-references=0",
        "--log=verbose",
        "--malloc-trim",
        "--parse-forwarding-functions",
        "--pch-storage=memory",
        "--ranking-model=heuristics",
        "--rename-file-limit=0",
}

---@type vim.lsp.Config
return {
        cmd             = command,
        filetypes       = { "c", "cpp" },
        root_markers    = {
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
        get_language_id = function(_, ftype)
                local t = { objc = "objective-c", objcpp = "objective-cpp", cuda = "cuda-cpp" }
                return t[ftype] or ftype
        end,
        settings        = {
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
        capabilities    = {
                textDocument = { completion = { editsNearCursor = true } },
                offsetEncoding = { "utf-8", "utf-16" },
                semanticTokens = { multilineTokenSupport = true },
        },
        on_init         = function(client, initResult)
                if initResult.offsetEncoding then ---@diagnostic disable-line: undefined-field
                        client.offset_encoding = initResult.offsetEncoding ---@diagnostic disable-line: undefined-field
                end
        end,
        on_attach       = function(client, bufnr)
                local comm = api.nvim_buf_create_user_command

                comm(bufnr, "ClangdSwitchSourceHeader", function()
                             switchSourceHeader(bufnr, client)
                     end, { desc = "Switch between source/header" })
                comm(bufnr, "ClangdSymbolInfo", function()
                             symbolInfo(bufnr, client)
                     end, { desc = "Show symbol info" })

                keyq { "&", "<cmd>ClangdSwitchSourceHeader<CR>" }

                semanticTokens()
        end,
}
