-- DOCS
-- https://neovim.io/doc/user/pack/#pack
-- https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local g     = vim.g
local bo    = vim.bo
local fn    = vim.fn
local fs    = vim.fs
local ui    = vim.ui
local uv    = vim.uv
local api   = vim.api
local cmd   = vim.cmd
local log   = vim.log
local opt   = vim.opt
local opt_l = vim.opt_local
local pack  = vim.pack

local levels = log.levels

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

g.lualineAdd      = function() end ---@diagnostic disable-line: duplicate-set-field
g.whichkeyAddSpec = function() end ---@diagnostic disable-line: duplicate-set-field

---- HANDLE LOCAL PLUGINS ------------------------------------------------------------------------------------------------------------------------------------------------------------------

local dummy = fn.stdpath "data" .. "/symlink-to-local-plugins/"
opt.packpath:prepend(dummy)
fn.mkdir(dummy .. "/pack/core/", "p")
uv.fs_symlink(g.localRepos, dummy .. "/pack/core/opt", { dir = true })

local local_plugins = {}
for name, type in fs.dir(g.localRepos) do
        if type == "directory" then
                local plugin_name          = name:gsub("%.nvim$", ""):gsub("nvim%-", "")
                local_plugins[plugin_name] = name
        end
end

---- AUTO-INSTALL AND LOAD -----------------------------------------------------------------------------------------------------------------------------------------------------------------

local spec_dir  = "plugin-specs"
local spec_path = fn.stdpath "config" .. "/lua/" .. spec_dir

vim
           .iter(fs.dir(spec_path))
           :each(function(fileName, type)
                   assert(not fileName:find "%..*%.lua", "Filename must not contain dots due `require`: " .. fileName)
                   if type ~= "file" or not vim.endswith(fileName, ".lua") then return end
                   local plugin_name = fileName:gsub("%.lua$", "")
                   local local_name  = local_plugins[plugin_name]

                   if local_name then
                           local orig, noop = pack.add, function() end
                           pack.add         = noop

                           cmd.packadd(local_name)
                           -- safeRequireLazy(spec_dir .. "." .. plugin_name)
                           req(spec_dir)(plugin_name)

                           pack.add = orig
                           vim.schedule(function()
                                   local msg = ("[%s] loaded from local repo."):format(local_name)
                                   vim.notify(msg, nil, { title = "nvim-pack", icon = "󰐱" })
                           end)
                   else
                           req(spec_dir)(plugin_name)
                   end
           end)

---- AUTO CLEANUP --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

auq "FocusLost" {
        desc     = "User: auto-cleanup unused plugins",
        once     = true,
        callback = function()
                local outdated_plugins = vim
                           .iter(pack.get())
                           :filter(function(p) return not p.active end)
                           :map(function(p) return p.spec.name end)
                           :totable()

                if #outdated_plugins == 0 then return end
                assert(#outdated_plugins <= 10, "Not uninstalling more than 10 plugins at once.")
                pack.del(outdated_plugins)
        end,
}

---- GLOBAL KEYMAPS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyq { "<leader>pl", function()
        cmd.edit(fn.stdpath "log" .. "/nvim-pack.log")
        vim.schedule(function()
                bo.filetype = "nvim-pack"
                fn.search("========== Update", "b")
        end)
end, desc = "Log of updates" }

keyq { "<leader>pr", function()
        pack.update(nil, { offline = true, target = "lockfile" })
end, desc = "Restore from lockfile" }

keyq { "<leader>pp", function() pack.update() end, desc = "Update plugins" }

---- PACK WINDOW KEYMAPS -------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function openCommitOrIssue()
        local cur_line = api.nvim_get_current_line()
        local issue    = cur_line:match "#(%d+)"
        local commit   = cur_line:match "^> (%x+) "
        if not issue and not commit then
                vim.notify("No commit or issue on current line.", levels.WARN)
                return
        end

        local row = api.nvim_win_get_cursor(0)[1]
        local repo_line
        while row > 1 do
                repo_line = api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
                if vim.startswith(repo_line, "Source: ") then break end
                row = row - 1
        end
        assert(repo_line, "No source line found.")
        local repo = repo_line:match "Source: *(%S+)"
        local url  = repo .. (issue and "/issues/" .. issue or "/commit/" .. commit)
        ui.open(url)
end

keyq { "q", cmd.bdelete, ft = "nvim-pack", nowait = true, desc = "Quit" }
keyq { "<CR>", cmd.write, ft = "nvim-pack", desc = "Confirm update" }
keyq { "<C-j>", "]]", remap = true, ft = "nvim-pack", desc = "Next plugin" }
keyq { "<C-k>", "[[", remap = true, ft = "nvim-pack", desc = "Previous plugin" }
keyq { "gi", openCommitOrIssue, ft = "nvim-pack", desc = "Open commit or issue" }

---- CONCEAL NOISE IN PACK WINDOW ----------------------------------------------------------------------------------------------------------------------------------------------------------

auq "FileType" {
        desc     = "User: Conceal noise in nvim-pack window",
        pattern  = "nvim-pack",
        callback = function(ctx)
                opt_l.wrap = true

                opt_l.foldmethod = "manual"
                local lines      = api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
                local foldlength = 6
                for lnum = 1, #lines do
                        if vim.startswith(lines[lnum], "## ") then
                                cmd.fold { range = { lnum, lnum + foldlength } }
                        end
                        if vim.startswith(lines[lnum], "# Same") then foldlength = 3 end
                end
        end,
}
