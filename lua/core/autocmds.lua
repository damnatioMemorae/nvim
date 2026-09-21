local g     = vim.g
local o     = vim.o
local v     = vim.v
local bo    = vim.bo
local fn    = vim.fn
local fs    = vim.fs
local uv    = vim.uv
local wo    = vim.wo
local api   = vim.api
local cmd   = vim.cmd
local opt   = vim.opt
local opt_l = vim.opt_local
local iter  = vim.iter

local augroup = vim.api.nvim_create_augroup
local general = augroup("General Autocmds", { clear = true })

local T = require "utils.functional".matching.thunk

---- GENERAL -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

auq "TermOpen" { -- TERMINAL
        group    = general,
        callback = function()
                o.statuscolumn  = ""
                opt_l.buflisted = false
        end,
}
auq "BufEnter" { -- STOP COMMENT
        group    = general,
        callback = function() opt.formatoptions:remove { "c", "r", "o" } end,
}
auq "FileType" { -- JSON
        pattern = { "json", "jsonc", "json5" },
        group   = general,
        command = "setlocal conceallevel=0",
}
auq "FileType" { -- NOFILE
        pattern  = "*",
        group    = general,
        callback = function(_)
                match(bo[_.buf].buftype) {
                        nofile = function()
                                opt_l.number         = false
                                opt_l.relativenumber = false
                                opt_l.statuscolumn   = ""
                                opt_l.signcolumn     = "no"
                        end,
                }
        end,
}
auq "VimResized" { -- RESIZE SPLITS
        desc    = "User: Automatically resize splits",
        group   = general,
        command = "wincmd =",
}
auq "FocusGained" { -- CWD
        desc     = "User: FIX `cwd` being not available when it is deleted outside nvim.",
        group    = general,
        callback = function() if not uv.cwd() then uv.chdir "/" end end,
}
auq "WinScrolled" { -- SNIPPET
        desc     = "User: Exit snippet on window scroll",
        group    = general,
        callback = function() vim.snippet.stop() end,
}
auq "BufWritePre" { -- TRAILING WHITESPACE
        desc     = "User: Remove trailing whitespace",
        group    = general,
        pattern  = "*",
        callback = function() if bo.filetype ~= "markdown" then cmd [[%s/\s\+$//e]] end end,
}
auq "TextYankPost" { -- HIGHLIGHT ON YANK
        desc     = "User: Highlighted Yank",
        group    = general,
        callback = function() vim.hl.hl_op { higroup = "Visual", timeout = 150 } end,
}
auq { "BufWinEnter", "FileType" } { -- BACKDROP
        desc     = "User: Add backdrop to floating windows",
        group    = general,
        pattern  = g.backdrop_wins,
        callback = function() require "utils.misc".addBackdrop() end,
}
auq { "CursorMoved", "CursorMovedI" } { -- EOLMARK
        desc     = "User: Put a mark at the end of the line",
        group    = general,
        callback = function(_)
                local buf = 0
                local row = api.nvim_win_get_cursor(0)[1] - 1
                local ns  = api.nvim_create_namespace "current_line_symbol"
                if string.find(bo[_.buf].buftype, ".+") then return end
                api.nvim_buf_clear_namespace(buf, ns, 0, -1)
                api.nvim_buf_set_extmark(buf, ns, row, -1, {
                        virt_text     = { { "󱞣", "Comment" } },
                        virt_text_pos = "eol",
                })
        end,
}
auq { "BufReadPost", "BufReadPre", "BufWinEnter" } { -- RESTORE CURSOR
        desc     = "User: Restore cursor position",
        group    = general,
        pattern  = "*",
        callback = function(_)
                local mark       = api.nvim_buf_get_mark(_.buf, '"')
                local line_count = api.nvim_buf_line_count(_.buf)
                if mark[1] > 0 and mark[1] <= line_count then
                        api.nvim_win_set_cursor(0, mark)
                end
        end,
}
do -- VIRTUAL EDIT & MODES
        local get = api.nvim_win_get_cursor
        local set = api.nvim_win_set_cursor
        local pos = get(0)
        auq "ModeChanged" {
                group    = general,
                pattern  = "*:*",
                callback = function(_)
                        local modes    = vim.split(_.match, ":")
                        local old, new = modes[1], modes[2]
                        match(old) {
                                [{ "i", "n", "nt" }] = function() pos = get(0) end,
                        }
                        match(new) {
                                i = function() pos = get(0) end,
                                n = function() set(0, pos) end,
                        }
                        opt.virtualedit = match(fn.mode()) {
                                [{ "i" }]        = "block",
                                [{ "v", "V" }]   = "none",
                                [{ "n", "\22" }] = "all",
                        }
                end,
        }
end

---- CMDLINE -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

auq "CmdlineChanged" { -- QUICKFIX LIVE GREP
        group    = general,
        pattern  = ":",
        callback = function()
                local cmdline = fn.getcmdline()
                local words   = vim.split(cmdline, " ", { trimempty = true })
                if words[1] == "livegrep" and #words > 1 then
                        cmd("silent grep! " .. fn.escape(words[2], " "))
                        cmd "cwindow"
                end
        end,
}
auq "CmdlineChanged" { -- LIVE COLORSCHEME PREVIEW
        group    = general,
        pattern  = ":",
        callback = function()
                local cmdline = fn.getcmdline()
                local words   = vim.split(cmdline, " ", { trimempty = true })
                if words[1] == "colorscheme" and #words > 1 then
                        pcmd("colorscheme " .. words[2])()
                end
        end,
}
auq "CmdlineChanged" { -- CMDLINE FUZZY COMPLETION
        pattern  = { ":", "/", "?", "v", "vimgrep" },
        callback = function() fn.wildtrigger() end,
}

---- ATOM ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do -- REPEAT LAST MOTION
        local key = '"'
        local last
        auq "CmdAtom" {
                callback = function(_)
                        local motion = _.data.moved or _.match == "motion"
                        if motion and not (_.data.changed or _.data.lhs == key) then
                                last = _.data
                        end
                end,
        }
        kq "" { key, function()
                vim.schedule(function()
                        if last then
                                api.nvim_feedkeys(last.keys or last.lhs, last.keys and "n" or "m", false)
                        end
                end)
        end }
end

---- `q` and `Esc` -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

auq "FileType" {
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
        callback = function(_) keymapq { "<Esc>", "<cmd>q<CR>", buf = _.buf, silent = true, nowait = true } end,
}

---- AUTO-CLOSE DELETED BUFFERS ------------------------------------------------------------------------------------------------------------------------------------------------------------

auq "FocusGained" {
        desc     = "User: Close all non-existing buffers on `FocusGained`.",
        callback = function()
                local all    = fn.getbufinfo { buflisted = 1 }
                local closed = iter(all)
                    :fold({}, function(acc, buf)
                            if not api.nvim_buf_is_valid(buf.bufnr) then return acc end
                            local still_exists   = uv.fs_stat(buf.name) ~= nil
                            local special_buffer = bo[buf.bufnr].buftype ~= ""
                            local new_buffer     = buf.name == ""
                            if still_exists or special_buffer or new_buffer then return acc end
                            table.insert(acc, fs.basename(buf.name))
                            api.nvim_buf_delete(buf.bufnr, { force = false })
                            return acc
                    end)
                if #closed == 0 then return end
                match(#closed) {
                        [1] = T(vim.notify, closed[1], nil, { title = "Buffer closed" }),
                        _   = function()
                                local text = "- " .. table.concat(closed, "\n- ")
                                vim.notify(text, nil, { title = "Buffers closed", icon = "󰅗" })
                        end,
                }
                vim.schedule(function()
                        if api.nvim_buf_get_name(0) ~= "" then return end
                        for _, file in ipairs(v.oldfiles) do
                                if uv.fs_stat(file) and fs.basename(file) ~= "COMMIT_EDITMSG" then
                                        cmd.edit(file)
                                        return
                                end
                        end
                end)
        end,
}

---- AUTO-NOHL & INLINE SEARCH COUNT -------------------------------------------------------------------------------------------------------------------------------------------------------

do
        local prev_key
        local config = { scrollbarWidth = 3, ignoredPrevNormalModeKeys = { "g", g.mapleader } }
        ---@param mode? "clear"
        local function searchCountIndicator(mode)
                local count_ns = api.nvim_create_namespace "searchCounter"
                api.nvim_buf_clear_namespace(0, count_ns, 0, -1)
                if mode == "clear" then return end
                local row   = api.nvim_win_get_cursor(0)[1]
                local count = fn.searchcount()
                if vim.tbl_isempty(count) or count.total == 0 then return end
                local text           = (" %d/%d "):format(count.current, count.total)
                local line           = api.nvim_get_current_line():gsub("\t", (" "):rep(bo.shiftwidth))
                local signcolumn     = tonumber(wo.signcolumn:match "%d+" or "0") * 2
                local viewport_width = api.nvim_win_get_width(0) - signcolumn - config.scrollbarWidth
                local line_full      = #line + #text > viewport_width
                local margin         = { line_full and (" "):rep(config.scrollbarWidth) or "" }
                api.nvim_buf_set_extmark(0, count_ns, row - 1, 0, {
                        virt_text     = { { text, "CurSearch" }, margin },
                        virt_text_pos = line_full and "right_align" or "eol",
                        priority      = 4000,
                })
        end
        vim.on_key(function(key, typed)
                           local ignore = vim.tbl_contains(config.ignoredPrevNormalModeKeys, prev_key)
                           prev_key     = typed
                           if ignore then return end
                           key                     = fn.keytrans(key)
                           local is_cmdline_search = fn.getcmdtype():find "[/?]" ~= nil
                           local is_normal_mode    = api.nvim_get_mode().mode == "n"
                           local search_started    = (key == "/" or key == "?") and is_normal_mode
                           local search_confirmed  = (key == "<CR>" and is_cmdline_search)
                           local search_cancelled  = (key == "<Esc>" and is_cmdline_search)
                           if not (search_started or search_confirmed or search_cancelled or is_normal_mode) then return end
                           local search_movement = vim.tbl_contains({ "n", "N", "*", "#" }, key)
                           if search_cancelled or (not search_movement and not search_confirmed) then
                                   opt.hlsearch = false
                                   searchCountIndicator "clear"
                           elseif search_movement or search_confirmed or search_started then
                                   opt.hlsearch = true
                                   vim.defer_fn(searchCountIndicator, 1)
                           end
                   end, api.nvim_create_namespace "autoNohlAndSearchCount")
end

--[[ TEMPLATES -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local template_config = {
        templateDir       = fn.stdpath "config" .. "/templates",
        ignoreDirs        = {
                fn.stdpath "data",
                fn.stdpath "config" .. "/after/ftplugin/",
                "/tmp/",
        },
        globToTemplateMap = {
                [fn.stdpath "config" .. "/lsp/*.lua"]              = "lsp-server-config.lua",
                [fn.stdpath "config" .. "/lua/plugin-specs/*.lua"] = "vim-pack-plugin.lua",
                ["**/*.lua"]                                       = "module.lua",

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

                -- [g.notesDir .. "/**/*.md"] = "note.md",
        },
}

auq { "BufNewFile", "BufReadPost" } {
        desc     = "User: Apply templates",
        callback = function(ctx)
                vim.defer_fn(function()
                                     local stats = uv.fs_stat(ctx.file)

                                     if not stats or stats.size > 10 then
                                             return
                                     end

                                     local filepath = ctx.file
                                     local bufnr    = ctx.buf
                                     local conf     = template_config
                                     local ignore   = iter(conf.ignoreDirs)
                                         :any(function(dir) return vim.startswith(filepath, dir) end)

                                     if ignore then
                                             return
                                     end

                                     local longest_matching_glob = iter(conf.globToTemplateMap)
                                         :filter(function(glob) return g.ob.to_lpeg(glob):match(filepath) end)
                                         :fold("", function(longGlob, glob)
                                                 return #longGlob < #glob and glob or longGlob
                                         end)
                                     if longest_matching_glob == "" then
                                             return
                                     end

                                     local template_file = conf.globToTemplateMap[longest_matching_glob]
                                     local template_path = vim.fs.normalize(conf.templateDir .. "/" .. template_file)

                                     local content = table.concat(fn.readfile(template_path), "\n")
                                     vim.snippet.expand(content)

                                     local new_ft = vim.filetype.match { buf = bufnr }

                                     if new_ft and bo[bufnr].ft ~= new_ft then
                                             bo[bufnr].ft = new_ft
                                     end
                             end, 100)
        end,
}
--]]
