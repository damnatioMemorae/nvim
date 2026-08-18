local g   = vim.g
local fn  = vim.fn
local ui  = vim.ui
local uv  = vim.uv
local api = vim.api
local log = vim.log
local opt = vim.opt

local levels = log.levels

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local lazypath = fn.stdpath "data" .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
        local repo = "https://github.com/folke/lazy.ngit"
        local args = { "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath }
        local out  = vim.system(args):wait()
        if out.code ~= 0 then
                api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out.stderr, "ErrorMsg" } }, true, {})
                fn.getchar()
                os.exit(1)
        end
end

opt.runtimepath:prepend(lazypath)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

require "lazy".setup {
        spec             = { import = "plugins" },
        defaults         = { lazy = true },
        dev              = { patterns = { "nvim" }, path = g.localRepos, fallback = true },
        install          = { colorscheme = { "catppuccin-mocha" } },
        git              = { log = { "--since=4 days ago" } },
        ui               = {
                title       = " lazy.nvim ",
                wrap        = true,
                backdrop    = g.backdrop,
                border      = Border.Default.None,
                pills       = false,
                size        = { width = 0.80, height = 0.9 },
                custom_keys = {
                        ["<localleader>l"] = false,
                        ["<localleader>t"] = false,
                        ["<localleader>i"] = false,
                        ["gi"]             = {
                                function(plug)
                                        local url    = plug.url:gsub("%.git$", "")
                                        local line   = api.nvim_get_current_line()
                                        local issue  = line:match "#(%d+)"
                                        local commit = line:match(("%x"):rep(6) .. "+")
                                        if issue then
                                                ui.open(url .. "/issues/" .. issue)
                                        elseif commit then
                                                ui.open(url .. "/commit/" .. commit)
                                        end
                                end,
                                desc = " Open issue/commit",
                        },
                },
        },
        checker          = { enabled = true, frequency = 60 * 60 * 24 * 7 },
        diff             = { cmd = "browser" },
        change_detection = { enabled = true, notify = false },
        readme           = { enabled = true, skip_if_doc_exists = false },
        performance      = {
                rtp = {
                        disabled_plugins = {
                                "cfilter",
                                "difftool",
                                "editorconfig",
                                "ft-shada",
                                "gzip",
                                "health",
                                "justify",
                                "man.lua",
                                "msgpack",
                                "netrwPlugin",
                                "nohlsearch",
                                "osc52",
                                "rplugin",
                                "spec",
                                "spellfile",
                                "swapmouse",
                                "tar",
                                "tarPlugin",
                                "termdebug",
                                "tohtml",
                                "tutor",
                                "undotree",
                                "zip",
                                "zipPlugin",
                        },
                },
        },
}

---- TEST FOR DUPLICATE KEYS -----------------------------------------------------------------------------------------------------------------------------------------------------------------

local function checkForDuplicateKeys()
        local already_mapped = {}
        local plugins        = require "lazy".plugins()

        vim
            .iter(plugins)
            :each(function(plugin)
                    if not plugin.keys then
                            return
                    end

                    vim
                        .iter(plugin.keys)
                        :filter(function(lazyKey)
                                return lazyKey.ft == nil
                        end)
                        :each(function(lazyKey)
                                local lhs   = lazyKey[1] or lazyKey
                                local modes = lazyKey.mode or "n"

                                if type(modes) ~= "table" then
                                        modes = { modes } ---@diagnostic disable-line: cast-local-type
                                end

                                vim
                                    .iter(modes)
                                    :each(function(mode)
                                            if not already_mapped[mode] then
                                                    already_mapped[mode] = {}
                                            end

                                            if already_mapped[mode][lhs] then
                                                    local msg = ("Duplicate keymap: %s (%s)")
                                                        :format(lhs, mode)
                                                    vim.notify(msg, levels.WARN,
                                                               { title = "lazy.nvim", timeout = 4000 })
                                            else
                                                    already_mapped[mode][lhs] = true
                                            end
                                    end)
                        end)
            end)
end

vim.defer_fn(checkForDuplicateKeys, 5000)
api.nvim_set_hl(0, "LazyNormal", { link = "Normal" })
