local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
        local repo = "https://github.com/folke/lazy.nvim.git"
        local args = { "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath }
        local out  = vim.system(args):wait()
        if out.code ~= 0 then
                vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out.stderr, "ErrorMsg" } }, true, {})
                vim.fn.getchar()
                os.exit(1)
        end
end

vim.opt.runtimepath:prepend(lazypath)

--------------------------------------------------------------------------------------------------------------------------------------------

require("lazy").setup({
        spec             = { import = "plugins" },
        defaults         = { lazy = true },
        dev              = { patterns = { "nvim" }, path = Config.localRepos, fallback = true },
        install          = { colorscheme = { "catppuccin-mocha" } },
        git              = { log = { "--since=4 days ago" } },
        ui               = {
                title       = " lazy.nvim ",
                wrap        = true,
                backdrop    = Config.backdrop,
                border      = Border.borderStyle,
                pills       = false,
                size        = { width = 0.80, height = 0.9 },
                custom_keys = {
                        ["<localleader>l"] = false,
                        ["<localleader>t"] = false,
                        ["<localleader>i"] = false,
                        ["gi"]             = {
                                function(plug)
                                        local url    = plug.url:gsub("%.git$", "")
                                        local line   = vim.api.nvim_get_current_line()
                                        local issue  = line:match("#(%d+)")
                                        local commit = line:match(("%x"):rep(6) .. "+")
                                        if issue then
                                                vim.ui.open(url .. "/issues/" .. issue)
                                        elseif commit then
                                                vim.ui.open(url .. "/commit/" .. commit)
                                        end
                                end,
                                desc = " Open issue/commit",
                        },
                },
        },
        checker          = { enabled = true, frequency = 60 * 60 * 24 * 7 },
        diff             = { cmd = "browser" },
        change_detection = { notify = false },
        readme           = { enabled = true, skip_if_doc_exists = false },
        performance      = {
                rtp = {
                        disabled_plugins = {
                                "rplugin",
                                "matchit",
                                "netrwPlugin",
                                "man",
                                "tutor",
                                "health",
                                "tohtml",
                                "gzip",
                                "zipPlugin",
                                "tarPlugin",
                                "osc52",
                        },
                },
        },
})

-- KEYMAPS FOR LAZY UI

require("lazy.view.config").keys.hover   = "o"
require("lazy.view.config").keys.details = "<Tab>"

--------------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPS FOR NVIM TRIGGERING LAZY

local map = require("core.utils").uniqueKeymap

map("n", "<leader>pp", require("lazy").sync, { desc = "󰒲 Lazy Sync" })
map("n", "<leader>pl", require("lazy").home, { desc = "󰒲 Lazy Home" })
map("n", "<leader>pi", require("lazy").install, { desc = "󰒲 Lazy Install" })

local pluginTypeIcons = {
        ["ai-plugins"]              = "󰚩",
        ["appearance"]              = "",
        ["completion-and-snippets"] = "󰩫",
        ["editing-support"]         = "󰏫",
        ["files-and-buffers"]       = "",
        ["folding"]                 = "󰘖",
        ["git-plugins"]             = "󰊢",
        ["lsp-plugins"]             = "󰒕",
        ["lualine"]                 = "",
        ["mason-and-lspconfig"]     = "",
        ["motions-and-textobjects"] = "󱡔",
        ["notification"]            = "󰎟",
        ["refactoring"]             = "󱗘",
        ["telescope"]               = "󰭎",
        ["themes"]                  = "",
        ["treesitter"]              = "",
        ["which-key"]               = "⌨️",
}

------------------------------------------------------------------------------------------------------------------------
-- GOTO PLUGIN SPEC

map("n", "<leader><leader>,", function()
            vim.api.nvim_create_autocmd("FileType", {
                    desc     = "User (once): Colorize icons in `TelescopeResults`",
                    once     = true,
                    pattern  = "TelescopeResults",
                    callback = function() vim.fn.matchadd("Title", [[^..\zs.]]) end,
            })
            local specRoot  = require("lazy.core.config").options.spec.import
            local specPath  = vim.fn.stdpath("config") .. "/lua/" .. specRoot
            local specFiles = vim.fs.dir(specPath)

            local allPlugins = vim.iter(specFiles):fold({}, function(acc, name, _)
                    if not vim.endswith(name, ".lua") then return acc end
                    local moduleName = name:gsub("%.lua$", "")
                    local module     = require(specRoot .. "." .. moduleName)
                    if type(module[1]) ~= "table" then module = { module } end
                    local plugins = vim.iter(module)
                               :map(function(plugin) return { repo = plugin[1], module = moduleName } end)
                               :totable()
                    return vim.list_extend(acc, plugins)
            end)

            vim.ui.select(allPlugins, {
                                  prompt      = "󰒲 Goto Config",
                                  format_item = function(plugin)
                                          local icon = pluginTypeIcons[plugin.module] or "󱧕"
                                          return icon .. " " .. vim.fs.basename(plugin.repo)
                                  end,
                          },
                          function(plugin)
                                  if not plugin then return end
                                  local filepath = specPath .. "/" .. plugin.module .. ".lua"
                                  local repo     = plugin.repo:gsub("/", "\\/")
                                  vim.cmd(("edit +/%q %s"):format(repo, filepath))
                          end)
    end, { desc = "󰒲 Goto Plugin Config" })

-----------------------------------------------------------------------------------------------------------------
-- GOTO LOCAL PLUGIN CODE

map("n", "<leader><leader>p", function()
            vim.ui.select(
                    require("lazy").plugins(),
                    { prompt = "󰒲 Local Code", format_item = function(plugin) return plugin.name end },
                    function(plugin)
                            if not plugin then return end
                            Snacks.picker.files{ prompt_title = plugin.name, cwd = plugin.dir }
                    end)
    end, { desc = "󰒲 Local Plugin Code" })

------------------------------------------------------------------------------------------------------------------------
-- TEST FOR DUPLICATE KEYS (on every startup)

local function checkForDuplicateKeys()
        local alreadyMapped = {}
        local plugins       = require("lazy").plugins()

        -- 1) each plugin
        vim.iter(plugins):each(function(plugin)
                if not plugin.keys then return end

                -- 2) each keymap of a plugin (only none-ft-specific keymaps)
                vim.iter(plugin.keys)
                           :filter(function(lazyKey) return lazyKey.ft == nil end)
                           :each(function(lazyKey)
                                   local lhs   = lazyKey[1] or lazyKey
                                   local modes = lazyKey.mode or "n" ---@type string|string[]
                                   if type(modes) ~= "table" then modes = { modes } end

                                   -- 3) each mode of a keymap
                                   vim.iter(modes):each(function(mode)
                                           if not alreadyMapped[mode] then alreadyMapped[mode] = {} end
                                           if alreadyMapped[mode][lhs] then
                                                   local msg = ("Duplicate keymap: [%s (%s)]"):format(lhs, mode)
                                                   vim.notify(msg, vim.log.levels.WARN,
                                                              { title = "lazy.nvim", timeout = false })
                                           else
                                                   alreadyMapped[mode][lhs] = true
                                           end
                                   end)
                           end)
        end)
end

vim.defer_fn(checkForDuplicateKeys, 5000)
