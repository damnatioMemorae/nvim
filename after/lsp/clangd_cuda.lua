local api = vim.api
local cmd = vim.cmd
local log = vim.log
local lsp = vim.lsp

local levels = log.levels
local util    = lsp.util

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function switchSourceHeader(bufnr)
        local method_name = "textDocument/switchSourceHeader"
        local client      = lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
        if not client then
                return vim.notify(("method %s is not supported by any servers active on the current buffer"):format(
                        method_name))
        end
        local params = util.make_text_document_params(bufnr)
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
                               cmd.edit(vim.uri_to_fname(result))
                       end, bufnr)
end

local function symbolInfo()
        local bufnr         = api.nvim_get_current_buf()
        local clangd_client = lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
        ---@diagnostic disable-next-line: unknown-diag-code
        ---@diagnostic disable-next-line: param-type-not-match, missing-parameter, param-type-mismatch
        if not clangd_client or not clangd_client.supports_method "textDocument/symbolInfo" then
                return vim.notify("Clangd client not found", levels.ERROR)
        end
        local win    = api.nvim_get_current_win()
        local params = util.make_position_params(win, clangd_client.offset_encoding)
        ---@diagnostic disable-next-line: unknown-diag-code
        ---@diagnostic disable-next-line: param-type-not-match, param-type-mismatch
        clangd_client.request("textDocument/symbolInfo", params, function(err, res)
                                      if err or #res == 0 then
                                              -- Clangd always returns an error, there is not reason to parse it
                                              return
                                      end
                                      local container = string.format("container: %s", res[1].containerName) ---@type string
                                      local name      = string.format("name: %s", res[1].name) ---@type string
                                      util.open_floating_preview({ name, container }, "", {
                                              height    = 2,
                                              width     = math.max(string.len(name), string.len(container)),
                                              focusable = false,
                                              focus     = false,
                                              border    = Border.Default.Normal,
                                              title     = "Symbol Info",
                                      })
                                      ---@diagnostic disable-next-line: unknown-diag-code
                                      ---@diagnostic disable-next-line: param-type-not-match, param-type-mismatch
                              end, bufnr)
end

return {
        cmd          = { "clangd", "--background-index", "--background-index-priority=normal", "--query-driver=/opt/cuda/bin/nvcc" },
        filetypes    = { "cuda" },
        root_markers = {
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
        settings     = {
                clangd = {
                        InlayHints         = {
                                Designators    = true,
                                Enabled        = true,
                                ParameterNames = true,
                                DeducedTypes   = true,
                        },
                        Completion         = {
                                AllScopes     = true,
                                ArgumentLists = "Delimiters",
                        },
                        CompileFlags       = { Add = "-Iinclude" },
                        usePlaceholders    = true,
                        completeUnimported = true,
                        clangdFileStatus   = true,
                        fallbackFlags      = {
                                "-xcuda",
                                "--cuda-path=/opt/cuda",
                                "-I/opt/cuda/include",
                                "-I/opt/cuda/include/cccl",
                                "--no-cuda-version-check",
                                "-std=c++17",
                                "-D__CUDACC__",
                                "-D_LIBCUDACXX_STD_VER=17",
                        },
                },
        },
        capabilities = {
                offsetEncoding = { "utf-8", "utf-16" },
                semanticTokens = { multilineTokenSupport = true },
                textDocument   = { completion = { editsNearCursor = true } },
        },
        on_init      = function(client, initResult)
                if initResult.offsetEncoding then
                        client.offset_encoding = initResult.offsetEncoding
                end
        end,
        on_attach    = function(_, bufnr)
                api.nvim_buf_create_user_command(bufnr, "LspClangdSwitchSourceHeader", function()
                                                         switchSourceHeader(bufnr)
                                                 end, { desc = "Switch between source/header" })

                api.nvim_buf_create_user_command(bufnr, "LspClangdShowSymbolInfo", function()
                                                         symbolInfo()
                                                 end, { desc = "Show symbol info" })
        end,
}
