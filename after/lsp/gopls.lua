local mod_cache = nil
local std_lib   = nil

---@param customArgs string
---@param onComplete fun(dir: string | nil)
local function identifyGoDir(customArgs, onComplete)
        local cmd = { "go", "env", customArgs.envvar_id }
        vim.system(cmd, { text = true }, function(output)
                local res = vim.trim(output.stdout or "")
                if output.code == 0 and res ~= "" then
                        if customArgs.custom_subdir and customArgs.custom_subdir ~= "" then
                                res = res .. customArgs.custom_subdir
                        end
                        onComplete(res)
                else
                        vim.schedule(function()
                                vim.notify(
                                        ("[gopls] identify " .. customArgs.envvar_id .. " dir cmd failed with code %d: %s\n%s")
                                        :format(
                                                output.code,
                                                vim.inspect(cmd),
                                                output.stderr
                                        )
                                )
                        end)
                        onComplete(nil)
                end
        end)
end

---@return string?
local function getStdLibDir()
        if std_lib and std_lib ~= "" then
                return std_lib
        end

        identifyGoDir({ envvar_id = "GOROOT", custom_subdir = "/src" }, function(dir)
                if dir then
                        std_lib = dir
                end
        end)
        return std_lib
end

---@return string?
local function getModCacheDir()
        if mod_cache and mod_cache ~= "" then
                return mod_cache
        end

        identifyGoDir({ envvar_id = "GOMODCACHE" }, function(dir)
                if dir then
                        mod_cache = dir
                end
        end)
        return mod_cache
end

---@param fname string
---@return string?
local function getRootDir(fname)
        if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
                local clients = vim.lsp.get_clients { name = "gopls" }
                if #clients > 0 then
                        return clients[#clients].config.root_dir
                end
        end
        if std_lib and fname:sub(1, #std_lib) == std_lib then
                local clients = vim.lsp.get_clients { name = "gopls" }
                if #clients > 0 then
                        return clients[#clients].config.root_dir
                end
        end
        return vim.fs.root(fname, "go.work") or vim.fs.root(fname, "go.mod") or vim.fs.root(fname, ".git")
end

return {
        cmd          = { "gopls", "-remote.debug=:0" },
        filetypes    = { "go", "gomod", "gowork", "gotmpl", "gosum", "gohtmltmpl", "gotexttmpl" },
        ---[[
        root_dir     = function(bufnr, onDir)
                local fname = vim.api.nvim_buf_get_name(bufnr)
                getModCacheDir()
                getStdLibDir()
                -- see: https://github.com/neovim/nvim-lspconfig/issues/804
                onDir(getRootDir(fname))
        end,
        --]]
        capabilities = {
                textDocument = {
                        completion          = {
                                completionItem = {
                                        commitCharactersSupport = true,
                                        deprecatedSupport       = true,
                                        documentationFormat     = { "markdown", "plaintext" },
                                        preselectSupport        = true,
                                        insertReplaceSupport    = true,
                                        labelDetailsSupport     = true,
                                        snippetSupport          = true,
                                        resolveSupport          = {
                                                properties = {
                                                        "documentation",
                                                        "details",
                                                        "additionalTextEdits",
                                                },
                                        },
                                },
                        },
                        contextSupport      = true,
                        dynamicRegistration = true,
                },
        },
        glags        = { allow_incremental_sync = true, debounce_text_changes = 500 },
        settings     = {
                gopls = {
                        -- more settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
                        -- not supported
                        analyses                       = {
                                unreachable    = true,
                                nilness        = true,
                                unusedparams   = true,
                                useany         = true,
                                unusedwrite    = true,
                                ST1003         = true,
                                undeclaredname = true,
                                fillreturns    = true,
                                nonewvars      = true,
                                fieldalignment = false,
                                shadow         = true,
                        },
                        codelenses                     = {
                                generate           = true, -- show the `go generate` lens.
                                gc_details         = true, -- Show a code lens toggling the display of gc's choices.
                                test               = true,
                                tidy               = true,
                                vendor             = true,
                                regenerate_cgo     = true,
                                upgrade_dependency = true,
                        },
                        hints                          = {
                                assignVariableTypes    = true,
                                compositeLiteralFields = true,
                                compositeLiteralTypes  = true,
                                constantValues         = true,
                                functionTypeParameters = true,
                                parameterNames         = true,
                                rangeVariableTypes     = true,
                        },
                        semanticTokenTypes             = {
                                string = false, -- disable semantic string tokens so we can use treesitter highlight injection
                                number = false, -- disable semantic number tokens so we can use treesitter highlight injection
                        },
                        usePlaceholders                = true,
                        completeUnimported             = true,
                        completionBudget               = "100ms",
                        experimentalPostfixCompletions = true,
                        staticcheck                    = true,
                        matcher                        = "Fuzzy",
                        diagnosticsDelay               = "500ms",
                        symbolMatcher                  = "Fuzzy",
                        semanticTokens                 = false,
                        buildFlags                     = { "-tags", "integration" },
                        hoverKind                      = "FullDocumentation",
                        -- linkTarget                     = "pkg.go.dev",
                        linkTarget                     = "godoc.org",
                        linksInHover                   = "gopls",
                },
        },
}
