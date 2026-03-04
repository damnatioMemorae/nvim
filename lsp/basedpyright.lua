local function set_python_path(path)
        local clients = vim.lsp.get_clients{
                bufnr = vim.api.nvim_get_current_buf(),
                name  = "basedpyright",
        }
        for _, client in ipairs(clients) do
                if client.settings then
                        client.settings.python = vim.tbl_deep_extend("force", client.settings.python or {},
                                                                     { pythonPath = path })
                else
                        client.config.settings = vim.tbl_deep_extend("force", client.config.settings,
                                                                     { python = { pythonPath = path } })
                end
                client.notify("workspace/didChangeConfiguration", { settings = nil })
        end
end

return {
        cmd          = { "basedpyright-langserver", "--stdio" },
        filetypes    = { "python" },
        root_markers = {
                ".git",
                "Pipfile",
                "pyproject.toml",
                "pyrightconfig.json",
                "requirements.txt",
                "setup.cfg",
                "setup.py",
        },
        settings     = {
                basedpyright = {
                        analysis = {
                                autoSearchPaths        = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode         = "openFilesOnly",
                        },
                },
        },
        capabilities = {
                textDocument = {
                        completion   = {
                                completionItem = {
                                        commitCharactersSupport = false,
                                        deprecatedSupport       = true,
                                        documentationFormat     = { "markdown", "plaintext" },
                                        insertReplaceSupport    = true,
                                        insertTextModeSupport   = {
                                                valueSet = { 1 },
                                        },
                                        labelDetailsSupport     = true,
                                        preselectSupport        = false,
                                        resolveSupport          = {
                                                properties = { "documentation", "detail", "additionalTextEdits", "command", "data" },
                                        },
                                        snippetSupport          = true,
                                        tagSupport              = {
                                                valueSet = { 1 },
                                        },
                                },
                                completionList = {
                                        -- itemDefaults  = { "commitCharacters", "editRange", "insertTextFormat", "insertTextMode", "data" }
                                },
                                contextSupport = true,
                                insertTextMode = 1,
                        },
                        foldingRange = {
                                dynamicRegistration = true,
                                lineFoldingOnly     = true,
                        },
                },
        },
        on_attach    = function(client, bufnr)
                vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
                                                             client:exec_cmd({
                                                                     command   = "basedpyright.organizeimports",
                                                                     arguments = { vim.uri_from_bufnr(bufnr) },
                                                             })
                                                     end, {
                                                             desc = "Organize Imports",
                                                     })

                vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
                        desc     = "Reconfigure basedpyright with the provided python path",
                        nargs    = 1,
                        complete = "file",
                })
        end,
}
