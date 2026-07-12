local map = _G.smartMap

local o       = vim.o
local api     = vim.api
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local general = augroup("General Autocmds", { clear = true })

---- GENERAL -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

vim.opt.wildmode = "noselect"
autocmd("CmdlineChanged", {
        desc     = "User: Add fuzzy completion for command line",
        group    = general,
        pattern  = { ":", "/", "!", "?" },
        callback = function()
                vim.fn.wildtrigger()
        end,
})

autocmd("TextYankPost", {
        desc     = "User: Highlighted Yank",
        group    = general,
        callback = function() vim.hl.hl_op() end,
})

autocmd("VimResized", { -- RESIZE SPLITS
        desc    = "User: Automatically resize splits",
        group   = general,
        command = "wincmd =",
})

autocmd("WinScrolled", { -- SNIPPET
        desc     = "User: Exit snippet on window scroll",
        group    = general,
        callback = function() vim.snippet.stop() end,
})

autocmd("BufEnter", { -- STOP COMMENT
        group    = general,
        callback = function()
                vim.opt.formatoptions:remove({ "c", "r", "o" })
        end,
})

autocmd("BufWritePre", { -- TRAILING WHITESPACE
        desc     = "User: Remove trailing whitespace",
        group    = general,
        pattern  = "*",
        callback = function()
                if vim.bo.filetype ~= "markdown" then
                        vim.cmd([[%s/\s\+$//e]])
                end
        end,
})

autocmd("ModeChanged", { -- VIRTUAL EDIT
        pattern  = "*:*",
        group    = general,
        callback = function()
                local mode = vim.fn.mode()
                if mode == "n" or mode == "\22" then
                        vim.opt.virtualedit = "all"
                end
                if mode == "i" then
                        vim.opt.virtualedit = "block"
                end
                if mode == "v" or mode == "V" then
                        vim.opt.virtualedit = "none"
                end
        end,
})

autocmd("FocusGained", { -- CWD
        desc     = "User: FIX `cwd` being not available when it is deleted outside nvim.",
        group    = general,
        callback = function()
                if not vim.uv.cwd() then
                        vim.uv.chdir("/")
                end
        end,
})

autocmd("FileType", { -- JSON
        pattern = { "json", "jsonc", "json5" },
        group   = general,
        command = "setlocal conceallevel=0",
})

autocmd("FileType", { -- NOFILE
        pattern  = "*",
        group    = general,
        callback = function(args)
                if vim.bo[args.buf].buftype == "nofile" then
                        _G.bufMap({ "<Esc>", "<cmd>q<CR>", silent = true })
                        vim.opt_local.number         = false
                        vim.opt_local.relativenumber = false
                        vim.opt_local.statuscolumn   = ""
                        vim.opt_local.signcolumn     = "no"
                end
        end,
})

autocmd({ "FocusGained", "BufWinEnter", "FileType" }, { -- BACKDROP
        desc     = "User: Add backdrop to floating windows",
        group    = general,
        pattern  = { "dropbar_menu", "Glance", "rip-substitute", "terminal" },
        callback = function() require("core.utils.misc").addBackdrop() end,
})

autocmd({ "FocusGained", "TermClose", "TermLeave" }, { -- RELOAD ON CHANGE
        desc     = "User: Reload files if they changed externaly",
        group    = general,
        callback = function()
                if o.buftype ~= "nofile" then
                        vim.cmd.checktime()
                end
        end,
})

autocmd({ "BufReadPost", "BufReadPre", "BufWinEnter" }, { -- RESTORE CURSOR
        desc     = "User: Restore cursor position",
        group    = general,
        pattern  = "*",
        callback = function(args)
                local mark       = api.nvim_buf_get_mark(args.buf, '"')
                local line_count = api.nvim_buf_line_count(args.buf)
                if mark[1] > 0 and mark[1] <= line_count then
                        api.nvim_win_set_cursor(0, mark)
                end
        end,
})

---- `q` and `Esc` -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

autocmd("FileType", {
        desc     = "User: Quit windows with both `Esc` and `q`",
        group    = general,
        pattern  = {
                "gitcommit",
                "pager",
                "nvim-undotree",
                "checkhealth",
                "lazy",
                "lspinfo",
                "man",
                "nofile",
                "notify",
                "PlenaryTestPopup",
                "spectre_panel",
                "startuptime",
                "terminal",
        },
        callback = function(args)
                map({ "<Esc>", "<cmd>q<CR>", buf = args.buf, silent = true })
        end,
})

---- AUTO-CLOSE DELETED BUFFERS ------------------------------------------------------------------------------------------------------------------------------------------------------------

autocmd("FocusGained", {
        desc     = "User: Close all non-existing buffers on `FocusGained`.",
        callback = function()
                local all_bufs       = vim.fn.getbufinfo{ buflisted = 1 }
                local closed_buffers = vim
                           .iter(all_bufs)
                           :fold({}, function(acc, buf)
                                   if not api.nvim_buf_is_valid(buf.bufnr) then
                                           return acc
                                   end

                                   local still_exists   = vim.uv.fs_stat(buf.name) ~= nil
                                   local special_buffer = vim.bo[buf.bufnr].buftype ~= ""
                                   local new_buffer     = buf.name == ""

                                   if still_exists or special_buffer or new_buffer then
                                           return acc
                                   end

                                   table.insert(acc, vim.fs.basename(buf.name))
                                   api.nvim_buf_delete(buf.bufnr, { force = false })
                                   return acc
                           end)

                if #closed_buffers == 0 then
                        return
                end

                if #closed_buffers == 1 then
                        vim.notify(closed_buffers[1], nil, { title = "Buffer closed", icon = "󰅗" })
                else
                        local text = "- " .. table.concat(closed_buffers, "\n- ")
                        vim.notify(text, nil, { title = "Buffers closed", icon = "󰅗" })
                end

                vim.schedule(function()
                        if api.nvim_buf_get_name(0) ~= "" then return end
                        for _, file in ipairs(vim.v.oldfiles) do
                                if vim.uv.fs_stat(file) and vim.fs.basename(file) ~= "COMMIT_EDITMSG" then
                                        vim.cmd.edit(file)
                                        return
                                end
                        end
                end)
        end,
})

---- AUTO-NOHL & INLINE SEARCH COUNT -------------------------------------------------------------------------------------------------------------------------------------------------------

do
        local prev_key
        local config = {
                scrollbarWidth            = 3,
                ignoredPrevNormalModeKeys = { "g", vim.g.mapleader },
        }

        ---@param mode? "clear"
        local function searchCountIndicator(mode)
                local count_ns = api.nvim_create_namespace("searchCounter")
                api.nvim_buf_clear_namespace(0, count_ns, 0, -1)
                if mode == "clear" then return end

                local row   = api.nvim_win_get_cursor(0)[1]
                local count = vim.fn.searchcount()
                if vim.tbl_isempty(count) or count.total == 0 then return end
                local text           = (" %d/%d "):format(count.current, count.total)
                local line           = api.nvim_get_current_line():gsub("\t", (" "):rep(vim.bo.shiftwidth))
                local signcolumn     = tonumber(vim.wo.signcolumn:match("%d+") or "0") * 2
                local viewport_width = api.nvim_win_get_width(0) - signcolumn - config.scrollbarWidth
                local line_full      = #line + #text > viewport_width
                local margin         = { line_full and (" "):rep(config.scrollbarWidth) or "" }

                api.nvim_buf_set_extmark(0, count_ns, row - 1, 0, {
                        virt_text     = { { text, "IncSearch" }, margin },
                        virt_text_pos = line_full and "right_align" or "eol",
                        priority      = 49,
                })
        end

        vim.on_key(function(key, typed)
                           local ignore = vim.tbl_contains(config.ignoredPrevNormalModeKeys, prev_key)
                           prev_key     = typed
                           if ignore then return end

                           key                     = vim.fn.keytrans(key)
                           local is_cmdline_search = vim.fn.getcmdtype():find("[/?]") ~= nil
                           local is_normal_mode    = api.nvim_get_mode().mode == "n"
                           local search_started    = (key == "/" or key == "?") and is_normal_mode
                           local search_confirmed  = (key == "<CR>" and is_cmdline_search)
                           local search_cancelled  = (key == "<Esc>" and is_cmdline_search)
                           if not (search_started or search_confirmed or search_cancelled or is_normal_mode) then return end

                           local search_movement = vim.tbl_contains({ "n", "N", "*", "#" }, key)

                           if search_cancelled or (not search_movement and not search_confirmed) then
                                   vim.opt.hlsearch = false
                                   searchCountIndicator("clear")
                           elseif search_movement or search_confirmed or search_started then
                                   vim.opt.hlsearch = true
                                   vim.defer_fn(searchCountIndicator, 1)
                           end
                   end, api.nvim_create_namespace("autoNohlAndSearchCount"))
end

--[[ TEMPLATES -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local template_config = {
        templateDir       = vim.fn.stdpath("config") .. "/templates",
        ignoreDirs        = {
                vim.fn.stdpath("data"),
                vim.fn.stdpath("config") .. "/after/ftplugin/",
                "/tmp/",
        },
        globToTemplateMap = {
                [vim.fn.stdpath("config") .. "/lsp/*.lua"]              = "lsp-server-config.lua",
                [vim.fn.stdpath("config") .. "/lua/plugin-specs/*.lua"] = "vim-pack-plugin.lua",
                ["**/*.lua"]                                            = "module.lua",

                ["**/*.py"]            = "template.py",
                ["**/*.scm"]           = "template.scm",
                ["**/*.swift"]         = "template.swift",
                ["**/*.{sh,zsh}"]      = "template.zsh",
                ["**/zsh/utilities/*"] = "template.zsh",
                ["**/*.applescript"]   = "template.applescript",

                ["**/*.mjs"]                                      = "node-module.mjs",
                ["**/Alfred.alfredpreferences/workflows/**/*.js"] = "jxa.js",
                ["**/Justfile"]                                   = "justfile.just",
                ["**/.github/workflows/*.{yml,yaml}"]             = "github-action.yaml",

                -- [vim.g.notesDir .. "/**/*.md"] = "note.md",
        },
}

autocmd({ "BufNewFile", "BufReadPost" }, {
        desc     = "User: Apply templates",
        callback = function(ctx)
                vim.defer_fn(function()
                                     local stats = vim.uv.fs_stat(ctx.file)

                                     if not stats or stats.size > 10 then
                                             return
                                     end

                                     local filepath = ctx.file
                                     local bufnr    = ctx.buf
                                     local conf     = template_config
                                     local ignore   = vim.iter(conf.ignoreDirs)
                                                :any(function(dir) return vim.startswith(filepath, dir) end)

                                     if ignore then
                                             return
                                     end

                                     local longest_matching_glob = vim.iter(conf.globToTemplateMap)
                                                :filter(function(glob) return vim.glob.to_lpeg(glob):match(filepath) end)
                                                :fold("", function(longGlob, glob)
                                                        return #longGlob < #glob and glob or longGlob
                                                end)
                                     if longest_matching_glob == "" then
                                             return
                                     end

                                     local template_file = conf.globToTemplateMap[longest_matching_glob]
                                     local template_path = vim.fs.normalize(conf.templateDir .. "/" .. template_file)

                                     local content = table.concat(vim.fn.readfile(template_path), "\n")
                                     vim.snippet.expand(content)

                                     local new_ft = vim.filetype.match{ buf = bufnr }

                                     if new_ft and vim.bo[bufnr].ft ~= new_ft then
                                             vim.bo[bufnr].ft = new_ft
                                     end
                             end, 100)
        end,
})
--]]
