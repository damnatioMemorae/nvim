-- DOCS
-- https://neovim.io/doc/user/pack/#vim.pack
-- https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
--------------------------------------------------------------------------------
local u   = require("config.utils")
local map = _G.smartMap

-- empty funcs to prevent errors when bisecting plugins (-> lualine/whichkey are disabled)
vim.g.lualineAdd      = function() end ---@diagnostic disable-line: duplicate-set-field
vim.g.whichkeyAddSpec = function() end ---@diagnostic disable-line: duplicate-set-field

---- HANDLE LOCAL PLUGINS ----------------------------------------------------------------------------------------------

-- create dummy package-bundle for `packpath`
local dummy = vim.fn.stdpath("data") .. "/symlink-to-local-plugins/"
vim.opt.packpath:prepend(dummy) -- prepend to prioritize local plugins
vim.fn.mkdir(dummy .. "/pack/core/", "p")
vim.uv.fs_symlink(vim.g.localRepos, dummy .. "/pack/core/opt", { dir = true })

local localPlugins = {}
for name, type in vim.fs.dir(vim.g.localRepos) do
        if type == "directory" then
                local plugin_name         = name:gsub("%.nvim$", ""):gsub("nvim%-", "")
                localPlugins[plugin_name] = name
        end
end

---- AUTO-INSTALL AND LOAD ---------------------------------------------------------------------------------------------

local pluginSpecDir  = "plugin-specs"
local pluginSpecPath = vim.fn.stdpath("config") .. "/lua/" .. pluginSpecDir
vim.iter(vim.fs.dir(pluginSpecPath)):each(function(fileName, type)
        assert(not fileName:find("%..*%.lua"), "Filename must not contain dots due `require`: " .. fileName)
        if type ~= "file" or not vim.endswith(fileName, ".lua") then return end
        local plugin_name = fileName:gsub("%.lua$", "")
        local local_name  = localPlugins[plugin_name]

        if local_name then
                -- HACK to load plugin config without triggering `vim.pack.add`
                local orig, noop = vim.pack.add, function() end
                vim.pack.add     = noop

                vim.cmd.packadd(local_name)
                u.safeRequire(pluginSpecDir .. "." .. plugin_name)

                vim.pack.add = orig
                vim.schedule(function()
                        local msg = ("[%s] loaded from local repo."):format(local_name)
                        vim.notify(msg, nil, { title = "nvim-pack", icon = "󰐱" })
                end)
        else
                u.safeRequire(pluginSpecDir .. "." .. plugin_name)
        end
end)

---- AUTO-CLEANUP ------------------------------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FocusLost", { -- on `FocusLost`, since `vim.pack.get()` is blocking?
        desc     = "User: auto-cleanup unused plugins",
        once     = true,
        callback = function()
                local outdated_plugins = vim.iter(vim.pack.get())
                           :filter(function(p) return not p.active end)
                           :map(function(p) return p.spec.name end)
                           :totable()
                if #outdated_plugins == 0 then return end
                assert(#outdated_plugins <= 10, "Not uninstalling more than 10 plugins at once.")
                vim.pack.del(outdated_plugins)
        end,
})

---- GLOBAL KEYMAPS ----------------------------------------------------------------------------------------------------

map{
        "<leader>pl",
        function()
                vim.cmd.edit(vim.fn.stdpath("log") .. "/nvim-pack.log")
                vim.schedule(function()
                        vim.bo.filetype = "nvim-pack"
                        vim.fn.search("========== Update", "b") -- goto last update
                end)
        end,
        desc = "󰐱 Log of updates",
}

map{
        "<leader>pr",
        function() vim.pack.update(nil, { offline = true, target = "lockfile" }) end,
        desc = "󰐱 Restore from lockfile",
}

map{ "<leader>pp", function() vim.pack.update() end, desc = "󰐱 Update plugins" }

---- PACK WINDOW KEYMAPS -----------------------------------------------------------------------------------------------

local function openCommitOrIssue()
        local cur_line = vim.api.nvim_get_current_line()
        local issue    = cur_line:match("#(%d+)")
        local commit   = cur_line:match("^> (%x+) ")
        if not issue and not commit then
                vim.notify("No commit or issue on current line.", vim.log.levels.WARN)
                return
        end

        local row = vim.api.nvim_win_get_cursor(0)[1]
        local repo_line
        while row > 1 do
                repo_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
                if vim.startswith(repo_line, "Source: ") then break end
                row = row - 1
        end
        assert(repo_line, "No source line found.")
        local repo = repo_line:match("Source: *(%S+)")
        local url  = repo .. (issue and "/issues/" .. issue or "/commit/" .. commit)
        vim.ui.open(url)
end

map{ "q", vim.cmd.bdelete, ft = "nvim-pack", nowait = true, desc = "󰐱 Quit" }
map{ "<CR>", vim.cmd.write, ft = "nvim-pack", desc = "󰐱 Confirm update" }
map{ "<C-j>", "]]", remap = true, ft = "nvim-pack", desc = "󰐱 Next plugin" }
map{ "<C-k>", "[[", remap = true, ft = "nvim-pack", desc = "󰐱 Previous plugin" }
map{ "gi", openCommitOrIssue, ft = "nvim-pack", desc = "󰐱 Open commit or issue" }

---- CONCEAL NOISE IN PACK WINDOW --------------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
        desc     = "User: Conceal noise in nvim-pack window",
        pattern  = "nvim-pack",
        callback = function(ctx)
                vim.opt_local.wrap = true

                vim.opt_local.foldmethod = "manual"
                local lines              = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
                local foldlength         = 6 -- 6 for `# Updates`, 3 for `# Same`
                for lnum = 1, #lines do
                        if vim.startswith(lines[lnum], "## ") then
                                vim.cmd.fold{ range = { lnum, lnum + foldlength } }  -- fold repo details
                        end
                        if vim.startswith(lines[lnum], "# Same") then foldlength = 3 end
                end
        end,
})
