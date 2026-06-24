local lsp = vim.lsp

return {
        cmd                = { "vscode-eslint-language-server", "--stdio" },
        filetypes          = {
                "javascript",
                "javascriptreact",
                "javascript.jsx",
                "typescript",
                "typescriptreact",
                "typescript.tsx",
                "vue",
                "svelte",
                "astro",
                "htmlangular",
        },
        workspace_required = true,
        on_attach          = function(client, bufnr)
                local command = vim.api.nvim_buf_create_user_command
                command(0, "LspEslintFixAll", function()
                                client:request_sync(
                                        "workspace/executeCommand",
                                        {
                                                command   = "eslint.applyAllFixes",
                                                arguments = {
                                                        {
                                                                uri     = vim.uri_from_bufnr(bufnr),
                                                                version = lsp.util.buf_versions[bufnr],
                                                        },
                                                },
                                        },
                                        nil,
                                        bufnr
                                )
                        end, {})
        end,
        settings           = {
                validate            = "on",
                packageManager      = nil,
                useESLintClass      = false,
                experimental        = {
                        useFlatConfig = false,
                },
                codeActionOnSave    = {
                        enable = false,
                        mode   = "all",
                },
                format              = true,
                quiet               = false,
                onIgnoredFiles      = "off",
                rulesCustomizations = {},
                run                 = "onType",
                problems            = {
                        shortenToSingleLine = false,
                },
                nodePath            = "",
                workingDirectory    = { mode = "location" },
                codeAction          = {
                        disableRuleComment = {
                                enable   = true,
                                location = "separateLine",
                        },
                        showDocumentation  = {
                                enable = true,
                        },
                },
        },
        before_init        = function(_, config)
                local root_dir = config.root_dir

                if root_dir then
                        config.settings                 = config.settings or {}
                        config.settings.workspaceFolder = {
                                uri  = root_dir,
                                name = vim.fn.fnamemodify(root_dir, ":t"),
                        }

                        local flat_config_files = {
                                "eslint.config.js",
                                "eslint.config.mjs",
                                "eslint.config.cjs",
                                "eslint.config.ts",
                                "eslint.config.mts",
                                "eslint.config.cts",
                        }

                        for _, file in ipairs(flat_config_files) do
                                if vim.fn.filereadable(root_dir .. "/" .. file) == 1 then
                                        config.settings.experimental               = config.settings.experimental or {}
                                        config.settings.experimental.useFlatConfig = true
                                        break
                                end
                        end

                        local pnp_cjs = root_dir .. "/.pnp.cjs"
                        local pnp_js  = root_dir .. "/.pnp.js"
                        if vim.uv.fs_stat(pnp_cjs) or vim.uv.fs_stat(pnp_js) then
                                local cmd  = config.cmd
                                config.cmd = vim.list_extend({ "yarn", "exec" }, cmd)
                        end
                end
        end,
        handlers           = {
                ["eslint/openDoc"]                = function(_, result)
                        if result then
                                vim.ui.open(result.url)
                        end
                        return {}
                end,
                ["eslint/confirmESLintExecution"] = function(_, result)
                        if not result then
                                return
                        end
                        return 4
                end,
                ["eslint/probeFailed"]            = function()
                        vim.notify("[lspconfig] ESLint probe failed.", vim.log.levels.WARN)
                        return {}
                end,
                ["eslint/noLibrary"]              = function()
                        vim.notify("[lspconfig] Unable to find ESLint library.", vim.log.levels.WARN)
                        return {}
                end,
        },
}
