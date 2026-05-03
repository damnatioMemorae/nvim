local api     = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd
local o       = vim.o
local wo      = vim.wo
local fn      = vim.fn
local keymap  = require("core.utils").uniqueKeymap

---- AUTO CD TO PROJECT ROOT -------------------------------------------------------------------------------------------

local autoCdConfig = {
        childOfRoot  = { ".git" },
        parentOfRoot = { ".config", vim.fs.basename(vim.env.HOME) },
}

autocmd("VimEnter", {
        desc     = "User: Auto-cd to project root",
        callback = function(args)
                local root = vim.fs.root(args.buf, function(name, path)
                        local parent_name           = vim.fs.basename(vim.fs.dirname(path))
                        local dir_has_parent_marker = vim.tbl_contains(autoCdConfig.parentOfRoot, parent_name)
                        local dir_has_child_marker  = vim.tbl_contains(autoCdConfig.childOfRoot, name)
                        return dir_has_child_marker or dir_has_parent_marker
                end)
                if root and root ~= "" then vim.uv.chdir(root) end
        end,
})

---- `q` and `Esc` -----------------------------------------------------------------------------------------------------

autocmd("FileType", {
        desc     = "Quit windows with both `Esc` and `q`",
        group    = augroup("Close with <q>", { clear = true }),
        pattern  = {
                "gitcommit",
                "pager",
                "nvim-undotree",
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
        callback = function(args)
                -- local keys = { "q" }
                local keys = { "<Esc>" }
                -- local keys = { "q", "<Esc>" }
                for _, value in pairs(keys) do
                        vim.keymap.set("n", value, "<cmd>close<CR>", { buffer = args.buf, silent = true })
                end
        end,
})

---- BUFFER ------------------------------------------------------------------------------------------------------------

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

---- AUTO-NOHL & INLINE SEARCH COUNT -----------------------------------------------------------------------------------

---@param mode? "clear"
-- local function searchCountIndicator(mode)
--         local sign_column_plus_scrollbar_width = 2 + 3
--
--         local count_ns = api.nvim_create_namespace("searchCounter")
--         api.nvim_buf_clear_namespace(0, count_ns, 0, -1)
--         if mode == "clear" then return end
--
--         local row   = api.nvim_win_get_cursor(0)[1]
--         local count = fn.searchcount()
--         if count.total == 0 then return end
--         local text      = (" %d/%d "):format(count.current, count.total)
--         local line      = api.nvim_get_current_line():gsub("\t", (" "):rep(vim.bo.shiftwidth))
--         local line_full = #line + sign_column_plus_scrollbar_width >= api.nvim_win_get_width(0)
--         local margin    = { (" "):rep(line_full and sign_column_plus_scrollbar_width or 0) }
--
--         api.nvim_buf_set_extmark(0, count_ns, row - 1, 0, {
--                 virt_text     = { { text, "IncSearch" }, margin },
--                 virt_text_pos = line_full and "right_align" or "eol",
--                 priority      = 200,
--         })
-- end

-- without the `searchCountIndicator`, this `on_key` simply does `auto-nohl`
-- vim.on_key(function(key, _typed)
--                    key                     = fn.keytrans(key)
--                    local is_cmdline_search = fn.getcmdtype():find("[/?]") ~= nil
--                    local is_normal_mode    = api.nvim_get_mode().mode == "n"
--                    local search_started    = (key == "/" or key == "?") and is_normal_mode
--                    local search_confirmed  = (key == "<CR>" and is_cmdline_search)
--                    local search_cancelled  = (key == "<Esc>" and is_cmdline_search)
--                    if not (search_started or search_confirmed or search_cancelled or is_normal_mode) then return end
--
--                    -- works for RHS, therefore no need to consider remaps
--                    local search_movement = vim.tbl_contains({ "n", "N", "*", "#" }, key)
--                    local short_pattern   = fn.getreg("/"):gsub([[\V\C]], ""):len() <= 1 -- for `fF` function
--
--                    if search_cancelled or (not search_movement and not search_confirmed) then
--                            vim.opt.hlsearch = false
--                            searchCountIndicator("clear")
--                    elseif (search_movement and not short_pattern) or search_confirmed or search_started then
--                            vim.opt.hlsearch = true
--                            vim.defer_fn(searchCountIndicator, 1)
--                    end
--            end, api.nvim_create_namespace("autoNohlAndSearchCount"))

---- SKELETONS (TEMPLATES) ---------------------------------------------------------------------------------------------

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
        callback = function(args)
                vim.defer_fn(
                        function()
                                local stats = vim.uv.fs_stat(args.file)
                                if not stats or stats.size > 10 then return end
                                local filepath, bufnr = args.file, args.buf

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

---- SMART VIRTUAL EDITING ---------------------------------------------------------------------------------------------

autocmd("ModeChanged", {
        pattern  = "*:*",
        callback = function()
                local mode = vim.fn.mode()
                if mode == "n" or mode == "\22" then vim.opt.virtualedit = "all" end
                if mode == "i" then vim.opt.virtualedit = "block" end
                if mode == "v" or mode == "V" then vim.opt.virtualedit = "none" end
        end,
})

---- LSP ---------------------------------------------------------------------------------------------------------------

autocmd("LspAttach", {
        desc     = "LSP stuff",
        group    = augroup("lsp-attach", { clear = true }),
        callback = function(args)
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

                --[[ DOCUMENT HIGHLIGHT
                if fn.has("nvim-0.11") == 1 and client:supports_method("textDocument/documentHighlight", 0) then
                        local buf               = args.buf
                        local highlight_augroup = augroup("lsp-highlight", { clear = false })

                        autocmd({ "CursorHold", "CursorHoldI" }, {
                                desc     = "Highlight LSP symbol under cursor",
                                buffer   = buf,
                                group    = highlight_augroup,
                                callback = function()
                                        local timer = vim.uv.new_timer()
                                        timer:stop()
                                        timer:start(2000, 0, vim.schedule_wrap(function()
                                                vim.lsp.buf.document_highlight()
                                        end))
                                end,
                        })
                        autocmd({ "CursorMoved", "CursorMovedI" }, {
                                desc     = "Clear LSP symbol highlight",
                                buffer   = buf,
                                group    = highlight_augroup,
                                callback = vim.lsp.buf.clear_references,
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
                                buffer   = args.buf,
                                group    = color_augroup,
                                -- callback = function() lsp.document_color.enable(true, 0, { style = "virtual" }) end,
                                callback = function() vim.lsp.document_color.enable(false) end,
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
                                        keymap("n", ",l", vim.lsp.codelens.run)
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

---[[ SWITCH BETWEEN `rlnu` and `lnu` -----------------------------------------------------------------------------------

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

---- RESTORE CURSOR POSITION -------------------------------------------------------------------------------------------

autocmd({ "BufReadPost", "BufReadPre", "BufWinEnter" }, {
        desc     = "Restore cursor position",
        pattern  = "*",
        callback = function()
                local test_line_data = vim.api.nvim_buf_get_mark(0, '"')
                local test_line      = test_line_data[1]
                local last_line      = vim.api.nvim_buf_line_count(0)

                if test_line > 0 and test_line <= last_line then
                        vim.api.nvim_win_set_cursor(0, test_line_data)
                end
                vim.cmd.normal("zz")
        end,
})

---- TRIM TRAILING WHITESPACE ------------------------------------------------------------------------------------------

autocmd({ "BufWritePre" }, {
        desc     = "Remove trailing whitespace",
        pattern  = "*",
        callback = function()
                if vim.bo.filetype ~= "markdown" then
                        vim.cmd([[%s/\s\+$//e]])
                end
        end,
})

---- SPLITS ------------------------------------------------------------------------------------------------------------

autocmd("FileType", {
        desc     = "Automatically split help buffers to the right",
        pattern  = "help",
        callback = function()
                if vim.o.filetype ~= "help" then return end
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

---- QUICKFIX ----------------------------------------------------------------------------------------------------------

autocmd("FileType", {
        desc     = "Show quickfix results interactively",
        pattern  = "qf",
        callback = function(args)
                local opts = { buffer = args.buf, silent = true }
                keymap("n", "J", "<cmd>cn<CR>zz<cmd>wincmd p<CR>", opts)
                keymap("n", "K", "<cmd>cN<CR>zz<cmd>wincmd p<CR>", opts)
                keymap("n", "<leader>qr", function() vim.cmd.cexpr("[]") end,
                       { desc = "󰚃 Remove quickfix items" })
                keymap("n", "<leader>q1", "<cmd>silent cfirst<CR>zv", { desc = "󰴩 Goto 1st quickfix" })
                -- vim.cmd("wincmd L")
                -- vim.cmd("vertical resize 70")
        end,
})

---- CMDLINE COMPLETION ------------------------------------------------------------------------------------------------

vim.opt.wildmode = "noselect"
autocmd("CmdlineChanged", {
        desc     = "Add fuzzy completion for command line",
        pattern  = { ":", "/", "!", "?" },
        callback = function()
                vim.fn.wildtrigger()
        end,
})

---- SNIPPET -----------------------------------------------------------------------------------------------------------

autocmd("WinScrolled", {
        desc     = "Exit snippet on window scroll",
        callback = function() vim.snippet.stop() end,
})

---- RELOAD ON CHANGE --------------------------------------------------------------------------------------------------

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
        desc     = "Reload files if they changed externaly",
        callback = function()
                if o.buftype ~= "nofile" then
                        vim.cmd.checktime()
                end
        end,
})

---- STATUSCOL ---------------------------------------------------------------------------------------------------------

autocmd("BufWinEnter", {
        desc     = "Reset statuscolumn for miscellaneous buffers",
        callback = function()
                if vim.tbl_contains({ "nofile", "help", "prompt", "terminal" }, vim.bo[0].buftype) then
                        vim.wo[0][0].statuscolumn = ""
                end
        end,
})

---- JSON --------------------------------------------------------------------------------------------------------------

autocmd("FileType", {
        pattern = { "json", "jsonc", "json5" },
        command = "setlocal conceallevel=0",
})

---- BACKDROP ----------------------------------------------------------------------------------------------------------

local backdrop = 40

vim.api.nvim_create_autocmd({ "FileType", "FocusGained", "BufWinEnter" }, {
        desc     = "Add backdrop to windows",
        pattern  = { "dropbar_menu", "convy", "yazi" },
        callback = function(args)
                local backdrop_name = "Backdrop"
                local bufnr         = args.buf
                local zindex        = 20

                local backdrop_bufnr = vim.api.nvim_create_buf(false, true)
                local winnr          = vim.api.nvim_open_win(backdrop_bufnr, false, {
                        relative  = "editor",
                        row       = 0,
                        col       = 0,
                        width     = vim.o.columns,
                        height    = vim.o.lines,
                        focusable = false,
                        style     = "minimal",
                        zindex    = zindex - 1,
                })

                vim.api.nvim_set_hl(0, backdrop_name, { link = "Backdrop" })
                vim.wo[winnr].winhighlight     = "Normal:" .. backdrop_name
                -- vim.wo[winnr].winhighlight     = backdrop_name .. ":Normal"
                -- vim.wo[winnr].winhighlight     = "Normal:Backdrop"
                vim.wo[winnr].winblend         = backdrop
                vim.bo[backdrop_bufnr].buftype = "nofile"

                vim.api.nvim_create_autocmd({ "WinClosed" }, {
                        once     = true,
                        buffer   = bufnr,
                        callback = function()
                                if vim.api.nvim_win_is_valid(winnr) then
                                        vim.api.nvim_win_close(winnr, true)
                                end

                                if vim.api.nvim_buf_is_valid(backdrop_bufnr) then
                                        vim.api.nvim_buf_delete(backdrop_bufnr, { force = true })
                                end
                        end,
                })
        end,
})

autocmd("FileType", {
        pattern  = "*",
        callback = function()
                vim.opt_local.formatoptions:remove({ "c", "r", "o" })
        end,
})
