--- @class go_dir_custom_args
--- @field envvar_id string
--- @field custom_subdir string?

local mod_cache = nil
local std_lib   = nil

---@param custom_args go_dir_custom_args
---@param on_complete fun(dir: string | nil)
local function identify_go_dir(custom_args, on_complete)
        local cmd = { "go", "env", custom_args.envvar_id }
        vim.system(cmd, { text = true }, function(output)
                local res = vim.trim(output.stdout or "")
                if output.code == 0 and res ~= "" then
                        if custom_args.custom_subdir and custom_args.custom_subdir ~= "" then
                                res = res .. custom_args.custom_subdir
                        end
                        on_complete(res)
                else
                        vim.schedule(function()
                                vim.notify(
                                        ("[gopls] identify " .. custom_args.envvar_id .. " dir cmd failed with code %d: %s\n%s")
                                        :format(
                                                output.code,
                                                vim.inspect(cmd),
                                                output.stderr
                                        )
                                )
                        end)
                        on_complete(nil)
                end
        end)
end

---@return string?
local function get_std_lib_dir()
        if std_lib and std_lib ~= "" then
                return std_lib
        end

        identify_go_dir({ envvar_id = "GOROOT", custom_subdir = "/src" }, function(dir)
                if dir then
                        std_lib = dir
                end
        end)
        return std_lib
end

---@return string?
local function get_mod_cache_dir()
        if mod_cache and mod_cache ~= "" then
                return mod_cache
        end

        identify_go_dir({ envvar_id = "GOMODCACHE" }, function(dir)
                if dir then
                        mod_cache = dir
                end
        end)
        return mod_cache
end

---@param fname string
---@return string?
local function get_root_dir(fname)
        if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
                local clients = vim.lsp.get_clients({ name = "gopls" })
                if #clients > 0 then
                        return clients[#clients].config.root_dir
                end
        end
        if std_lib and fname:sub(1, #std_lib) == std_lib then
                local clients = vim.lsp.get_clients({ name = "gopls" })
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
        root_dir     = function(bufnr, on_dir)
                local fname = vim.api.nvim_buf_get_name(bufnr)
                get_mod_cache_dir()
                get_std_lib_dir()
                -- see: https://github.com/neovim/nvim-lspconfig/issues/804
                on_dir(get_root_dir(fname))
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
