local g      = vim.g
local fn     = vim.fn
local ui     = vim.ui
local uv     = vim.uv
local api    = vim.api
local opt    = vim.opt
local iter   = vim.iter
local levels = vim.log.levels

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local lazypath = fn.stdpath "data" .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
        local repo = "https://github.com/folke/lazy.nvim.git"
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
        iter(require "lazy".plugins())
            :each(function(_)
                    if not _.keys then return end
                    iter(_.keys)
                        :filter(function(_) return _.ft == nil end)
                        :each(function(_)
                                local lhs   = _[1] or _
                                local modes = _.mode or "n"
                                if type(modes) ~= "table" then
                                        modes = { modes } ---@diagnostic disable-line: cast-local-type
                                end
                                iter(modes)
                                    :each(function(_)
                                            if not already_mapped[_] then
                                                    already_mapped[_] = {}
                                            end
                                            if already_mapped[_][lhs] then
                                                    local msg = ("Duplicate keymap: %s (%s)")
                                                        :format(lhs, _)
                                                    vim.notify(msg, levels.WARN,
                                                               { title = "lazy.nvim", timeout = 4000 })
                                            else
                                                    already_mapped[_][lhs] = true
                                            end
                                    end)
                        end)
            end)
end

vim.defer_fn(checkForDuplicateKeys, 5000)
api.nvim_set_hl(0, "LazyNormal", { link = "Normal" })
