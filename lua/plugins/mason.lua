local ensure_installed = {
        -- ASM
        -- "asm-lsp",

        ---- BASH --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        "shfmt",
        "shellcheck",
        "bash-language-server",

        ---- C/C++ --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        "clangd",
        "clang-format",

        ---- WEB ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        -- "tsgo",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "superhtml",
        "emmet-language-server",
        "css-variables-language-server",
        -- "typescript-language-server",
        -- "phpactor",
        "intelephense",
        "prettier",
        "prettierd",

        ---- GO ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        "gopls",
        -- "templ",
        -- "golangci-lint-langserver",
        -- "delve",
        -- "go-debug-adapter",

        ---- LUA ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        "lua-language-server",
        -- "luaformatter",
        -- "emmylua_ls",
        -- "emmylua-codeformat",
        "local-lua-debugger-vscode",

        ---- PYTHON ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        -- "ty",
        -- "ruff",

        ---- OTHER -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        -- "rust-analyzer",
        -- "omnisharp",
        -- "markdown-oxide",
        -- "ts_query_ls",
        -- "qmlls",
        -- "ltex-ls-plus",
        -- "systemd-lsp",
        -- "just-lsp",
        -- "kakehashi",
        "tree-sitter-cli",
        "yaml-language-server",
        -- "gh-actions-language-server",
}

---@param msg string
---@param level "info"|"warn"|"error"|"debug"|"trace"
---@param opts? table
local function notify(msg, level, opts)
        if not opts then opts = {} end
        opts.title = "Mason"
        opts.icon  = ""
        vim.notify(msg, vim.log.levels[level:upper()], opts)
end

local function enableLsps()
        local installed_packs  = require("mason-registry").get_installed_packages()
        local lsp_config_names = vim.iter(installed_packs):fold({}, function(acc, pack)
                table.insert(acc, pack.spec.neovim and pack.spec.neovim.lspconfig)
                return acc
        end)
        vim.lsp.enable(lsp_config_names)
end

---@param pack { name: string, install: function }
---@param version? string
local function installOrUpdate(pack, version)
        local mode = version and ("updating to %s"):format(version) or "installing"
        local msg  = ("[%s] %s…"):format(pack.name, mode)
        notify(msg, "info", { id = "mason.install" })

        pack:install({ version = version }, function(success, error)
                if success then
                        mode = version and ("updated to %s"):format(version) or "installed"
                        msg  = ("[%s] %s "):format(pack.name, mode)
                        notify(msg, "info", { id = "mason.install" })
                else
                        mode = version and "update" or "install"
                        msg  = ("[%s] failed to %s: %s"):format(pack.name, mode, error)
                        notify(msg, "error", { id = "mason.install" })
                end
        end)
end

local function syncPackages()
        local mason_reg = require("mason-registry")

        mason_reg.refresh(function(ok, _)
                assert(ok, "Could not refresh mason registry.")

                vim.iter(ensure_installed):each(function(packName)
                        if not mason_reg.has_package(packName) then
                                local msg = ("No package [%s] available."):format(packName)
                                vim.notify(msg, vim.log.levels.WARN, { title = "mason" })
                                return
                        end
                        local pack = mason_reg.get_package(packName)
                        if pack:is_installed() then
                                local latest_version = pack:get_latest_version()
                                local version        = pack:get_installed_version()
                                if latest_version ~= version then installOrUpdate(pack, latest_version) end
                        else
                                installOrUpdate(pack)
                        end
                end)

                assert(#ensure_installed > 10, "< 10 mason packages, aborting uninstalls.")
                local installed_packages = mason_reg.get_installed_package_names()
                vim.iter(installed_packages):each(function(packName)
                        if vim.tbl_contains(ensure_installed, packName) then return end
                        mason_reg.get_package(packName):uninstall({}, function(success, error)
                                local lvl = success and "info" or "error"
                                local msg = success and ("[%s] uninstalled."):format(packName)
                                           or ("[%s] failed to uninstall: %s"):format(packName, error)
                                notify(msg, lvl)
                        end)
                end)
        end)
end

return {
        "mason-org/mason.nvim",
        event  = "BufReadPre",
        keys   = { { "<leader>m", vim.cmd.Mason, desc = " Mason Home" } },
        opts   = {
                registries = { "github:mason-org/mason-registry" },
                ui         = {
                        border   = Border.borderStyleNone,
                        height   = 0.9,
                        width    = 0.8,
                        backdrop = Config.backdrop,
                        icons    = {
                                package_installed   = Icons.Misc.package_installed,
                                package_pending     = Icons.Misc.package_pending,
                                package_uninstalled = Icons.Misc.package_uninstalled,
                        },
                        keymaps  = {
                                apply_language_filter = "f",
                                uninstall_package     = "x",
                                toggle_help           = "?",
                                toggle_package_expand = "<Tab>",
                        },
                },
        },
        config = function(_, opts)
                vim.env.npm_config_cache = vim.env.HOME .. "/.cache/npm"
                require("mason").setup(opts)
                enableLsps()
                vim.defer_fn(syncPackages, 2000)

                local groups = {
                        { "Error",                       "DiagnosticError" },
                        { "Muted",                       "Comment" },
                        { "Highlight",                   "Special" },
                        { "HighlightSecondary",          "Structure" },
                        { "Backdrop",                    "Backdrop" },
                        { "MutedBlock",                  "LspInlayHint" },
                        { "HighlightBlock",              "CurSearch" },
                        { "HighlightBlockSecondary",     "Search" },
                        { "Heading",                     "FloatTitle" },
                        { "Doc",                         "Comment" },
                        { "Pod",                         "Comment" },
                        { "Header",                      "Title" },
                        { "MutedBlockBold",              "LspInlayHint" },
                        { "HeaderSecondary",             "Search" },
                        { "HighlightBlockBold",          "CurSearch" },
                        { "Warning",                     "DiagnosticWarn" },
                        { "Link",                        "Special" },
                        { "HighlightBlockBoldSecondary", "Search" },
                        { "Normal",                      "Normal" },
                }
                vim.iter(groups):each(function(group)
                        vim.api.nvim_set_hl(0, "Mason" .. group[1], { link = group[2] })
                end)
        end,
}
