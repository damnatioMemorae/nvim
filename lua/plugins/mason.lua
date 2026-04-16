local ensure_installed = {
        -- LSP
        "asm-lsp",
        "shfmt",
        "shellcheck",
        "bash-language-server",
        "clangd",
        "clang-format",
        "biome",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "superhtml",
        "emmet-language-server",
        "css-variables-language-server",
        "gopls",
        "jdtls",
        "kotlin-lsp",
        "lua-language-server",
        "ty",
        "ruff",
        "ltex-ls-plus",
        "markdown-oxide",
        "tsgo",
        "typescript-language-server",
        "rust-analyzer",
        "systemd-lsp",
        "omnisharp",
        -- "phpactor",
        "intelephense",
        "stimulus-language-server",
        -- FORMATTERS
        "prettier",
        "prettierd",
        -- "ts_query_ls",
        "qmlls",

        -- DEBUGGERS

        -- OTHER
        "just-lsp",
        "tree-sitter-cli",
        "yaml-language-server",
        "gh-actions-language-server",
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
---@param version? string if provided, updates to that version
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

-- 1. install missing packages
-- 2. update installed ones
-- 3. uninstall unused packages
local function syncPackages()
        local mason_reg = require("mason-registry")

        mason_reg.refresh(function(ok, _)
                assert(ok, "Could not refresh mason registry.")

                -- auto-install missing packages & auto-update installed ones
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

                -- auto-clean unused packages
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
                registries = {
                        -- personal registry must come first to have priority
                        -- "file:" .. vim.fn.stdpath("config") .. "/mason-registry",
                        "github:mason-org/mason-registry",
                },
                ui         = {
                        border   = Border.borderStyleNone,
                        height   = 0.9,
                        width    = 0.8,
                        backdrop = Config.backdrop,
                        icons    = {
                                package_installed   = "󱧕",
                                package_pending     = "󱧘",
                                package_uninstalled = "󱧙",
                        },
                        keymaps  = {
                                uninstall_package     = "x",
                                toggle_help           = "?",
                                toggle_package_expand = "<Tab>",
                        },
                },
        },
        config = function(_, opts)
                vim.env.npm_config_cache = vim.env.HOME .. "/.cache/npm"  -- don't crowd $HOME with `.npm` folder
                require("mason").setup(opts)
                enableLsps()
                vim.defer_fn(syncPackages, 2000)
        end,
}
