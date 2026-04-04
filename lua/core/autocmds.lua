local api     = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd
local o       = vim.o
local wo      = vim.wo
local fn      = vim.fn
local opt     = vim.opt
local cmd     = vim.cmd
local lsp     = vim.lsp

--[[AUTO CD TO PROJECT ROOT---------------------------------------------------------------------------------------------

local autoCdConfig = {
        childOfRoot  = { ".git" },
        parentOfRoot = { ".config", vim.fs.basename(vim.env.HOME) },
}

autocmd("VimEnter", {
        desc     = "User: Auto-cd to project root",
        callback = function(ctx)
                local root = vim.fs.root(ctx.buf, function(name, path)
                        local parent_name           = vim.fs.basename(vim.fs.dirname(path))
                        local dir_has_parent_marker = vim.tbl_contains(autoCdConfig.parentOfRoot, parent_name)
                        local dir_has_child_marker  = vim.tbl_contains(autoCdConfig.childOfRoot, name)
                        return dir_has_child_marker or dir_has_parent_marker
                end)
                if root and root ~= "" then vim.uv.chdir(root) end
        end,
})
--]]

----`q` and `Esc`-------------------------------------------------------------------------------------------------------

autocmd("FileType", {
        desc     = "Quit windows with both `Esc` and `q`",
        group    = augroup("Close with <q>", { clear = true }),
        pattern  = {
                "checkhealth",
                -- "help",
                "lazy",
                "lspinfo",
                "man",
                "neotest-output",
                "neotest-output-panel",
                "neotest-summary",
                "neo-tree",
                "nofile",
                "notify",
                "PlenaryTestPopup",
                "qf",
                "spectre_panel",
                "startuptime",
                "tsplayground",
                "query",
        },
        callback = function(event)
                -- local keys = { "q" }
                local keys = { "<Esc>" }
                -- local keys = { "q", "<Esc>" }
                for _, value in pairs(keys) do
                        vim.keymap.set("n", value, "<cmd>close<CR>", { buffer = event.buf, silent = true })
                end
        end,
})

----BUFFER--------------------------------------------------------------------------------------------------------------

autocmd("FocusGained", {
        desc     = "User: FIX `cwd` being not available when it is deleted outside nvim.",
        callback = function()
                if not vim.uv.cwd() then vim.uv.chdir("/") end
        end,
})
autocmd("FocusGained", {
        desc     = "User: Close all non-existing buffers on `FocusGained`.",
        callback = function()
                local closed_buffers = {}
                local all_bufs       = fn.getbufinfo{ buflisted = 1 }
                vim.iter(all_bufs):each(function(buf)
                        if not api.nvim_buf_is_valid(buf.bufnr) then return end
                        local still_exists   = vim.uv.fs_stat(buf.name) ~= nil
                        local special_buffer = vim.bo[buf.bufnr].buftype ~= ""
                        local new_buffer     = buf.name == ""
                        if still_exists or special_buffer or new_buffer then return end
                        table.insert(closed_buffers, vim.fs.basename(buf.name))
                        api.nvim_buf_delete(buf.bufnr, { force = false })
                end)
                if #closed_buffers == 0 then return end

                if #closed_buffers == 1 then
                        vim.notify(closed_buffers[1], nil, { title = "Buffer closed", icon = "󰅗" })
                else
                        local text = "- " .. table.concat(closed_buffers, "\n- ")
                        vim.notify(text, nil, { title = "Buffers closed", icon = "󰅗" })
                end

                vim.defer_fn(function()
                                     if api.nvim_buf_get_name(0) ~= "" then return end
                                     for _, file in ipairs(vim.v.oldfiles) do
                                             if vim.uv.fs_stat(file) and vim.fs.basename(file) ~= "COMMIT_EDITMSG" then
                                                     vim.cmd.edit(file)
                                                     return
                                             end
                                     end
                             end, 1)
        end,
})

----AUTO-NOHL & INLINE SEARCH COUNT-------------------------------------------------------------------------------------

---@param mode? "clear"
local function searchCountIndicator(mode)
        local sign_column_plus_scrollbar_width = 2 + 3

        local count_ns = api.nvim_create_namespace("searchCounter")
        api.nvim_buf_clear_namespace(0, count_ns, 0, -1)
        if mode == "clear" then return end

        local row   = api.nvim_win_get_cursor(0)[1]
        local count = fn.searchcount()
        if count.total == 0 then return end
        local text      = (" %d/%d "):format(count.current, count.total)
        local line      = api.nvim_get_current_line():gsub("\t", (" "):rep(vim.bo.shiftwidth))
        local line_full = #line + sign_column_plus_scrollbar_width >= api.nvim_win_get_width(0)
        local margin    = { (" "):rep(line_full and sign_column_plus_scrollbar_width or 0) }

        api.nvim_buf_set_extmark(0, count_ns, row - 1, 0, {
                virt_text     = { { text, "IncSearch" }, margin },
                virt_text_pos = line_full and "right_align" or "eol",
                priority      = 200,
        })
end

-- without the `searchCountIndicator`, this `on_key` simply does `auto-nohl`
---@diagnostic disable-next-line: unused-local
vim.on_key(function(key, _typed)
                   key                     = fn.keytrans(key)
                   local is_cmdline_search = fn.getcmdtype():find("[/?]") ~= nil
                   local is_normal_mode    = api.nvim_get_mode().mode == "n"
                   local search_started    = (key == "/" or key == "?") and is_normal_mode
                   local search_confirmed  = (key == "<CR>" and is_cmdline_search)
                   local search_cancelled  = (key == "<Esc>" and is_cmdline_search)
                   if not (search_started or search_confirmed or search_cancelled or is_normal_mode) then return end

                   -- works for RHS, therefore no need to consider remaps
                   local search_movement = vim.tbl_contains({ "n", "N", "*", "#" }, key)
                   local short_pattern   = fn.getreg("/"):gsub([[\V\C]], ""):len() <= 1 -- for `fF` function

                   if search_cancelled or (not search_movement and not search_confirmed) then
                           vim.opt.hlsearch = false
                           searchCountIndicator("clear")
                   elseif (search_movement and not short_pattern) or search_confirmed or search_started then
                           vim.opt.hlsearch = true
                           vim.defer_fn(searchCountIndicator, 1)
                   end
           end, api.nvim_create_namespace("autoNohlAndSearchCount"))

----SKELETONS (TEMPLATES)-----------------------------------------------------------------------------------------------

local template_dir         = fn.stdpath("config") .. "/templates"
local home_dir             = os.getenv("HOME")
local glob_to_template_map = {
        [home_dir .. "/.local/share/bin/lua/*.lua"]      = "script.lua",
        [Config.localRepos .. "/**/*.lua"]               = "module.lua",
        [fn.stdpath("config") .. "/lua/functions/*.lua"] = "module.lua",
        [fn.stdpath("config") .. "/lua/plugins/*.lua"]   = "plugin-spec.lua",
        [fn.stdpath("config") .. "/lsp/*.lua"]           = "lsp.lua",

        -- ["**/*.py"]                                           = "template.py",
        ["**/*.sh"]  = "template.zsh",
        ["**/*.*sh"] = "template.zsh",
}

autocmd({ "BufNewFile", "BufReadPost" }, {
        desc     = "User: Apply templates (`BufReadPost` for files created outside of nvim.)",
        callback = function(ctx)
                vim.defer_fn(
                        function()
                                local stats = vim.uv.fs_stat(ctx.file)
                                if not stats or stats.size > 10 then return end
                                local filepath, bufnr = ctx.file, ctx.buf

                                local matched_glob = vim.iter(glob_to_template_map):find(function(glob)
                                        local glob_matches_filename = vim.glob.to_lpeg(glob):match(filepath)
                                        return glob_matches_filename
                                end)
                                if not matched_glob then return end
                                local template_file = glob_to_template_map[matched_glob]
                                local template_path = vim.fs.normalize(template_dir .. "/" .. template_file)
                                if not vim.uv.fs_stat(template_path) then return end

                                local content = {}
                                local cursor
                                local row     = 1
                                for line in io.lines(template_path) do
                                        local placeholder_pos = line:find("%$0")
                                        if placeholder_pos then
                                                line   = line:gsub("%$0", "")
                                                cursor = { row, placeholder_pos - 1 }
                                        end
                                        table.insert(content, line)
                                        row = row + 1
                                end
                                api.nvim_buf_set_lines(0, 0, -1, false, content)
                                if cursor then api.nvim_win_set_cursor(0, cursor) end

                                local new_ft = vim.filetype.match{ buf = bufnr }
                                ---@diagnostic disable-next-line: assign-type-mismatch
                                if vim.bo[bufnr].ft ~= new_ft then vim.bo[bufnr].ft = new_ft end
                        end, 100)
        end,
})

----ENFORCE SCROLLOF AT EOF---------------------------------------------------------------------------------------------

autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled" }, {
        desc     = "Fix scrolloff when you are at the EOF",
        group    = augroup("ScrollEOF", { clear = true }),
        callback = function()
                if api.nvim_win_get_config(0).relative ~= "" then
                        return
                end

                local win_height             = fn.winheight(0)
                local scrolloff              = math.min(o.scrolloff, math.floor(win_height / 2))
                local visual_distance_to_eof = win_height - fn.winline()

                if visual_distance_to_eof < scrolloff then
                        local win_view = fn.winsaveview()
                        fn.winrestview({ topline = win_view.topline + scrolloff - visual_distance_to_eof })
                end
        end,
})

local original_scrolloff = o.scrolloff
autocmd({ "BufReadPost", "BufNew" }, {
        desc     = "User: FIX scrolloff on entering new buffer",
        callback = function(ctx)
                vim.defer_fn(function()
                                     if not api.nvim_buf_is_valid(ctx.buf) or vim.bo[ctx.buf].buftype ~= "" then return end
                                     if vim.o.scrolloff == 0 then
                                             o.scrolloff = original_scrolloff
                                             vim.notify("Triggered by [" .. ctx.event .. "]", nil,
                                                        { title = "Scrolloff fix" })
                                     end
                             end, 150)
        end,
})

----LSP-----------------------------------------------------------------------------------------------------------------

autocmd("LspAttach", {
        desc     = "LSP stuff",
        group    = augroup("lsp-attach", { clear = true }),
        callback = function(ev)
                local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

                ---[[ HIGHLIGHT
                if fn.has("nvim-0.11") == 1 and client:supports_method("textDocument/documentHighlight", 0) then
                        local buf               = ev.buf
                        local highlight_augroup = augroup("lsp-highlight", { clear = false })

                        autocmd({ "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" }, {
                                desc     = "Highlight LSP symbol under cursor",
                                buffer   = buf,
                                group    = highlight_augroup,
                                callback = lsp.buf.document_highlight,
                        })
                        autocmd({ "CursorMoved", "CursorMovedI" }, {
                                desc     = "Clear LSP symbol highlight",
                                buffer   = buf,
                                group    = highlight_augroup,
                                callback = lsp.buf.clear_references,
                        })
                end
                --]]

                --[[ INLAY HINTS
                if fn.has("nvim-0.10") == 1 and client:supports_method("textDocument/inlayHint") then
                        local hint_augroup = augroup("lsp-inlay-hint", { clear = false })
                        autocmd({ "CursorHold", "CursorMoved" }, {
                                buffer   = args.buf,
                                group    = hint_augroup,
                                callback = function() lsp.inlay_hint.enable(false) end,
                        })
                end
                --]]

                ---[[ COLOR
                if fn.has("nvim-0.12") == 1 and client:supports_method("textDocument/documentColor") then
                        local color_augroup = augroup("lsp-color", { clear = false })
                        autocmd({ "CursorHold", "CursorMoved" }, {
                                desc     = "LSP colors",
                                buffer   = ev.buf,
                                group    = color_augroup,
                                -- callback = function() lsp.document_color.enable(true, 0, { style = "virtual" }) end,
                                callback = function() lsp.document_color.enable(false) end,
                        })
                end
                --]]

                --[[ CODELENSE
                if fn.has("nvim-0.11") == 1 and client:supports_method("textDocument/codeLens") then
                        local codelens_augroup = augroup("lsd-codelens", { clear = false })
                        autocmd({ "BufEnter", "FocusGained", "LspAttach", "LspProgress" }, {
                                desc     = "Enable LSP codelenses",
                                callback = function(ctx)
                                        local lsp_progress_end = ctx.event == "LspProgress"
                                            and ctx.data.params.value.kind == "end"
                                            and ctx.data.params.value.title == "Loading Workspace"
                                        if ctx.event == "LspProgress" and not lsp_progress_end then return end
                                        vim.lsp.codelens.refresh({ bufnr = ctx.buf })
                                        vim.keymap.set("n", ",l", vim.lsp.codelens.run)
                                end
                        })
                end
                --]]
        end,
})

autocmd("LspDetach", {
        desc     = "Stop LSP when no buffer",
        group    = augroup("lsp-detach", { clear = true }),
        callback = function(args)
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

                if not client or not client.attached_buffers then
                        return
                end

                for bufnr in pairs(client.attached_buffers) do
                        if bufnr ~= args.buf then
                                return
                        end
                end
                client:stop()
        end,
})

----SMART VIRTUAL EDITING-----------------------------------------------------------------------------------------------

autocmd("ModeChanged", {
        desc     = "Move cursor everywhere",
        pattern  = "*:*",
        callback = function()
                local mode = fn.mode()
                if mode == "n" or mode == "\22" then vim.opt.virtualedit = "all" end
                if mode == "i" then vim.opt.virtualedit = "block" end
                if mode == "v" or mode == "V" then vim.opt.virtualedit = "onemore" end
        end,
})

----SHOW WHITESPACES----------------------------------------------------------------------------------------------------

autocmd({ "ModeChanged" }, {
        desc     = "Show whitespace chars in selection",
        pattern  = "*:*",
        callback = function()
                local mode = fn.mode()
                if mode == "n" or mode == "\22" or mode == "i" then
                        vim.opt.listchars = {
                                multispace = " ",
                                lead       = " ",
                                trail      = " ",
                                tab        = "  ",
                        }
                end
                if mode == "v" or mode == "V" then
                        vim.opt.listchars = {
                                multispace = ".",
                                lead       = ".",
                                trail      = ".",
                                tab        = "..",
                        }
                end
        end,
})

---[[SWITCH BETWEEN `rlnu` and `lnu`-------------------------------------------------------------------------------------

autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
        desc     = "Enable relative line numbers in active window",
        pattern  = "*",
        callback = function()
                if wo.number and api.nvim_get_mode().mode ~= "i" then
                        wo.relativenumber = true
                        wo.signcolumn     = "yes"
                end
        end,
})
autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
        desc     = "Disable relative line numbers in inactive window",
        pattern  = "*",
        callback = function()
                if wo.number then
                        wo.relativenumber = false
                        wo.foldcolumn     = "0"
                end
        end,
})

----RESTORE CURSOR POSITION---------------------------------------------------------------------------------------------

autocmd({ "BufReadPost", "BufReadPre", "BufWinEnter" }, {
        desc     = "Restore cursor position",
        pattern  = "*",
        callback = function(ctx)
                if vim.bo[ctx.buf].buftype ~= "" then return end
                vim.cmd([[silent! normal! g`"]])
        end,
})

----TRIM TRAILING WHITESPACE--------------------------------------------------------------------------------------------

autocmd({ "BufWritePre" }, {
        desc     = "Remove trailing whitespace",
        pattern  = "*",
        callback = function()
                if vim.bo.filetype ~= "markdown" then
                        vim.cmd([[%s/\s\+$//e]])
                end
        end,
})

----SPLITS--------------------------------------------------------------------------------------------------------------

autocmd("FileType", {
        desc     = "Automatically split help buffers to the right",
        pattern  = { "help" },
        callback = function()
                if vim.o.filetype ~= "help" or "qf" then return end
                local function hasDiffviewInCurrentTab()
                        return vim.tbl_contains(
                                vim.tbl_map(function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype end,
                                            vim.api.nvim_tabpage_list_wins(0)), "DiffviewFiles")
                end
                if hasDiffviewInCurrentTab() then return end
                vim.cmd.wincmd("L")
        end,
})
autocmd("VimResized", {
        desc    = "Automatically resize splits",
        command = "wincmd =",
})

----QUICKFIX------------------------------------------------------------------------------------------------------------

autocmd("FileType", {
        desc     = "Open quickfix window in vertical split",
        pattern  = "qf",
        callback = function()
                vim.cmd("wincmd L")
                vim.cmd("vertical resize 70")
        end,
})
autocmd("FileType", {
        desc     = "Show quickfix results interactively",
        pattern  = "qf",
        callback = function(event)
                local opts = { buffer = event.buf, silent = true }
                vim.keymap.set("n", "J", "<cmd>cn<CR>zz<cmd>wincmd p<CR>", opts)
                vim.keymap.set("n", "K", "<cmd>cN<CR>zz<cmd>wincmd p<CR>", opts)
                vim.keymap.set("n", "<leader>qr", function() vim.cmd.cexpr("[]") end,
                               { desc = "󰚃 Remove quickfix items" })
                vim.keymap.set("n", "<leader>q1", "<cmd>silent cfirst<CR>zv", { desc = "󰴩 Goto 1st quickfix" })
        end,
})

----CMDLINE COMPLETION--------------------------------------------------------------------------------------------------

opt.wildmode = "noselect"
autocmd("CmdlineChanged", {
        desc     = "Add fuzzy completion for command line",
        pattern  = { ":", "/", "!", "?" },
        callback = function()
                vim.fn.wildtrigger()
        end,
})

----SNIPPET-------------------------------------------------------------------------------------------------------------

autocmd("WinScrolled", {
        desc     = "Exit snippet on window scroll",
        callback = function() vim.snippet.stop() end,
})

----RELOAD ON CHANGE----------------------------------------------------------------------------------------------------

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
        desc     = "Reload files if they changed externaly",
        callback = function()
                if o.buftype ~= "nofile" then
                        cmd.checktime()
                end
        end,
})

----STATUSCOL-----------------------------------------------------------------------------------------------------------

autocmd("BufWinEnter", {
        desc     = "Reset statuscolumn for miscellaneous buffers",
        callback = function()
                if vim.tbl_contains({ "nofile", "help", "prompt" }, vim.bo[0].buftype) then
                        vim.wo[0][0].statuscolumn = ""
                end
        end,
})
