---@diagnostic disable: undefined-field
---@diagnostic disable-next-line: undefined-doc-name
---@param pack Package
---@param version? string
local function install(pack, version)
        local notifyOpts = { title = "Mason", icon = " ", id = "mason.install", style = "minimal" }

        local msg = version and ("[%s] updating to `%s`…"):format(pack.name, version)
                   or ("[%s] installing…"):format(pack.name)
        vim.notify(msg, nil, notifyOpts)

        pack:once("install:success", function()
                local msg2      = ("[%s] %s"):format(pack.name, version and "updated" or "installed")
                notifyOpts.icon = " "
                vim.notify(msg2, nil, notifyOpts)
        end)
        pack:once("install:failed", function()
                local error = "Failed to install [" .. pack.name .. "]"
                vim.notify(error, vim.log.levels.ERROR, notifyOpts)
        end)

        pack:install{ version = version }
end

-- 1. install missing packages
-- 2. update installed ones
-- 3. uninstall unused packages
---@param ensurePacks string[]
---@diagnostic disable-next-line: unused-local
local function syncPackages(ensurePacks)
        local masonReg = require("mason-registry")

        local function refreshCallback()
                -- auto-install missing packages & auto-update installed ones
                vim.iter(ensurePacks):each(function(packName)
                        if not masonReg.has_package(packName) then return end
                        local pack = masonReg.get_package(packName)
                        if pack:is_installed() then
                                pack:check_new_version(function(hasNewVersion, version)
                                        if not hasNewVersion then return end
                                        install(pack, version.latest_version)
                                end)
                        else
                                install(pack)
                        end
                end)

                -- auto-clean unused packages
                local installedPackages = masonReg.get_installed_package_names()
                vim.iter(installedPackages):each(function(packName)
                        if not vim.tbl_contains(ensurePacks, packName) then
                                masonReg.get_package(packName):uninstall()
                                local msg = ("[%s] uninstalled"):format(packName)
                                vim.notify(msg, nil, { title = "Mason", icon = "󰅗 ", style = "minimal" })
                        end
                end)
        end

        -- ensure registry is up-to-date, relevant when using extra personal registry
        -- refresh is async when callback is passed
        masonReg.refresh(refreshCallback)
end

return {
        "mason-org/mason.nvim",
        keys   = { { "<leader>m", vim.cmd.Mason, desc = " Mason Home" } },
        init   = function() vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH end,
        config = function()
                require("mason").setup({
                        -- PENDING https://github.com/mason-org/mason-registry/pull/7957
                        -- registries = {
                        --         -- local one must come first to take priority
                        --         -- add my own local registry: https://github.com/mason-org/mason-registry/pull/3671#issuecomment-1851976705
                        --         -- also requires `yq` being available in the system
                        --         ("file:%s/personal-mason-registry"):format(vim.fn.stdpath("config")),
                        --         "github:mason-org/mason-registry",
                        -- },
                        ui = {
                                border   = Border.borderStyle,
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
                })
        end,
}
