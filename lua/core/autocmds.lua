local api     = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd
local o       = vim.o
local wo      = vim.wo
local fn      = vim.fn
local opt     = vim.opt

------------------------------------------------------------------------------------------------------------------------
--[[ AUTO CD TO PROJECT ROOT

local autoCdConfig = {
        childOfRoot  = { ".git" },
        parentOfRoot = { ".config", vim.fs.basename(vim.env.HOME) },
}

autocmd("VimEnter", {
        desc     = "User: Auto-cd to project root",
        callback = function(ctx)
                local root = vim.fs.root(ctx.buf, function(name, path)
                        local parentName         = vim.fs.basename(vim.fs.dirname(path))
                        local dirHasParentMarker = vim.tbl_contains(autoCdConfig.parentOfRoot, parentName)
                        local dirHasChildMarker  = vim.tbl_contains(autoCdConfig.childOfRoot, name)
                        return dirHasChildMarker or dirHasParentMarker
                end)
                if root and root ~= "" then vim.uv.chdir(root) end
        end,
})
--]]

------------------------------------------------------------------------------------------------------------------------
-- `q` and `Esc`

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
                -- local keys = { "q", "<Esc>" }
                local keys = { "<Esc>" }
                for _, value in pairs(keys) do
                        vim.keymap.set("n", value, "<cmd>close<CR>", { buffer = event.buf, silent = true })
                end
        end,
})

------------------------------------------------------------------------------------------------------------------------
-- BUFFERS

autocmd("FocusGained", {
        desc     = "User: FIX `cwd` being not available when it is deleted outside nvim.",
        callback = function()
                if not vim.uv.cwd() then vim.uv.chdir("/") end
        end,
})
autocmd("FocusGained", {
        desc     = "User: Close all non-existing buffers on `FocusGained`.",
        callback = function()
                local closedBuffers = {}
                local allBufs       = fn.getbufinfo{ buflisted = 1 }
                vim.iter(allBufs):each(function(buf)
                        if not api.nvim_buf_is_valid(buf.bufnr) then return end
                        local stillExists   = vim.uv.fs_stat(buf.name) ~= nil
                        local specialBuffer = vim.bo[buf.bufnr].buftype ~= ""
                        local newBuffer     = buf.name == ""
                        if stillExists or specialBuffer or newBuffer then return end
                        table.insert(closedBuffers, vim.fs.basename(buf.name))
                        api.nvim_buf_delete(buf.bufnr, { force = false })
                end)
                if #closedBuffers == 0 then return end

                if #closedBuffers == 1 then
                        vim.notify(closedBuffers[1], nil, { title = "Buffer closed", icon = "󰅗" })
                else
                        local text = "- " .. table.concat(closedBuffers, "\n- ")
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

------------------------------------------------------------------------------------------------------------------------
-- AUTO-NOHL & INLINE SEARCH COUNT

---@param mode? "clear"
local function searchCountIndicator(mode)
        local signColumnPlusScrollbarWidth = 2 + 3

        local countNs = api.nvim_create_namespace("searchCounter")
        api.nvim_buf_clear_namespace(0, countNs, 0, -1)
        if mode == "clear" then return end

        local row   = api.nvim_win_get_cursor(0)[1]
        local count = fn.searchcount()
        if count.total == 0 then return end
        local text     = (" %d/%d "):format(count.current, count.total)
        local line     = api.nvim_get_current_line():gsub("\t", (" "):rep(vim.bo.shiftwidth))
        local lineFull = #line + signColumnPlusScrollbarWidth >= api.nvim_win_get_width(0)
        local margin   = { (" "):rep(lineFull and signColumnPlusScrollbarWidth or 0) }

        api.nvim_buf_set_extmark(0, countNs, row - 1, 0, {
                virt_text     = { { text, "IncSearch" }, margin },
                virt_text_pos = lineFull and "right_align" or "eol",
                priority      = 200,
        })
end

-- without the `searchCountIndicator`, this `on_key` simply does `auto-nohl`
---@diagnostic disable-next-line: unused-local
vim.on_key(function(key, _typed)
                   key                   = fn.keytrans(key)
                   local isCmdlineSearch = fn.getcmdtype():find("[/?]") ~= nil
                   local isNormalMode    = api.nvim_get_mode().mode == "n"
                   local searchStarted   = (key == "/" or key == "?") and isNormalMode
                   local searchConfirmed = (key == "<CR>" and isCmdlineSearch)
                   local searchCancelled = (key == "<Esc>" and isCmdlineSearch)
                   if not (searchStarted or searchConfirmed or searchCancelled or isNormalMode) then return end

                   -- works for RHS, therefore no need to consider remaps
                   local searchMovement = vim.tbl_contains({ "n", "N", "*", "#" }, key)
                   local shortPattern   = fn.getreg("/"):gsub([[\V\C]], ""):len() <= 1 -- for `fF` function

                   if searchCancelled or (not searchMovement and not searchConfirmed) then
                           vim.opt.hlsearch = false
                           searchCountIndicator("clear")
                   elseif (searchMovement and not shortPattern) or searchConfirmed or searchStarted then
                           vim.opt.hlsearch = true
                           vim.defer_fn(searchCountIndicator, 1)
                   end
           end, api.nvim_create_namespace("autoNohlAndSearchCount"))

------------------------------------------------------------------------------------------------------------------------
-- SKELETONS (TEMPLATES)

local templateDir       = fn.stdpath("config") .. "/templates"
local homeDir           = os.getenv("HOME")
local globToTemplateMap = {
        [homeDir .. "/.local/share/bin/lua/*.lua"]       = "script.lua",
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

                                local matchedGlob = vim.iter(globToTemplateMap):find(function(glob)
                                        local globMatchesFilename = vim.glob.to_lpeg(glob):match(filepath)
                                        return globMatchesFilename
                                end)
                                if not matchedGlob then return end
                                local templateFile = globToTemplateMap[matchedGlob]
                                local templatePath = vim.fs.normalize(templateDir .. "/" .. templateFile)
                                if not vim.uv.fs_stat(templatePath) then return end

                                local content = {}
                                local cursor
                                local row     = 1
                                for line in io.lines(templatePath) do
                                        local placeholderPos = line:find("%$0")
                                        if placeholderPos then
                                                line   = line:gsub("%$0", "")
                                                cursor = { row, placeholderPos - 1 }
                                        end
                                        table.insert(content, line)
                                        row = row + 1
                                end
                                api.nvim_buf_set_lines(0, 0, -1, false, content)
                                if cursor then api.nvim_win_set_cursor(0, cursor) end

                                local newFt = vim.filetype.match{ buf = bufnr }
                                ---@diagnostic disable-next-line: assign-type-mismatch
                                if vim.bo[bufnr].ft ~= newFt then vim.bo[bufnr].ft = newFt end
                        end, 100)
        end,
})

------------------------------------------------------------------------------------------------------------------------
-- ENFORCE SCROLLOFF AT EOF

autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled" }, {
        desc     = "Fix scrolloff when you are at the EOF",
        group    = augroup("ScrollEOF", { clear = true }),
        callback = function()
                if api.nvim_win_get_config(0).relative ~= "" then
                        return -- Ignore floating windows
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

-- FIX: for some reason `scrolloff` sometimes being set to `0` on new buffers
local originalScrolloff = o.scrolloff
autocmd({ "BufReadPost", "BufNew" }, {
        desc     = "User: FIX scrolloff on entering new buffer",
        callback = function(ctx)
                vim.defer_fn(function()
                                     if not api.nvim_buf_is_valid(ctx.buf) or vim.bo[ctx.buf].buftype ~= "" then return end
                                     if vim.o.scrolloff == 0 then
                                             o.scrolloff = originalScrolloff
                                             vim.notify("Triggered by [" .. ctx.event .. "]", nil,
                                                        { title = "Scrolloff fix" })
                                     end
                             end, 150)
        end,
})

------------------------------------------------------------------------------------------------------------------------
-- LSP

autocmd("LspAttach", {
        desc     = "LSP stuff",
        group    = augroup("lsp-attach", { clear = true }),
        callback = function(args)
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                local lsp    = vim.lsp

                ---[[ HIGHLIGHT
                if fn.has("nvim-0.11") == 1 and client:supports_method("textDocument/documentHighlight", 0) then
                        local buf               = args.buf
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
                                buffer   = args.buf,
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

------------------------------------------------------------------------------------------------------------------------
-- SMART VIRTUAL EDITING

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

------------------------------------------------------------------------------------------------------------------------
-- SHOW WHITESPACES

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

------------------------------------------------------------------------------------------------------------------------
-- SWITCH BETWEEN `rlnu` and `lnu`

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

------------------------------------------------------------------------------------------------------------------------
-- RESTORE CURSOR POSITION

autocmd({ "BufReadPost", "BufReadPre", "BufWinEnter" }, {
        desc     = "Restore cursor position",
        pattern  = "*",
        callback = function(ctx)
                if vim.bo[ctx.buf].buftype ~= "" then return end
                vim.cmd([[silent! normal! g`"]])
        end,
})

------------------------------------------------------------------------------------------------------------------------
-- TRIM TRAILING WHITESPACE

autocmd({ "BufWritePre" }, {
        desc     = "Remove trailing whitespace",
        pattern  = "*",
        callback = function()
                if vim.bo.filetype ~= "markdown" then
                        vim.cmd([[%s/\s\+$//e]])
                end
        end,
})

------------------------------------------------------------------------------------------------------------------------
-- SPLITS

autocmd("FileType", {
        desc     = "Automatically split help buffers to the right",
        pattern  = { "help" },
        callback = function()
                if vim.o.filetype ~= "help" or "qf" then return end
                local function has_diffview_in_current_tab()
                        return vim.tbl_contains(
                                vim.tbl_map(function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype end,
                                            vim.api.nvim_tabpage_list_wins(0)), "DiffviewFiles")
                end
                if has_diffview_in_current_tab() then return end
                vim.cmd.wincmd("L")
        end,
})
autocmd("VimResized", {
        desc    = "Automatically resize splits",
        command = "wincmd =",
})

------------------------------------------------------------------------------------------------------------------------
-- QUICKFIX

autocmd("FileType", {
        desc     = "Open quickfix window in vertical split",
        pattern  = "qf",
        callback = function()
                vim.cmd("wincmd L")
                vim.cmd("vertical resize 70")
                o.signcolumn = "yes:1"
                o.number     = false
        end,
})
autocmd("FileType", {
        desc     = "Show quickfix results interactively",
        pattern  = "qf",
        callback = function(event)
                local opts = { buffer = event.buf, silent = true }
                vim.keymap.set("n", "J", "<cmd>cn<CR>zz<cmd>wincmd p<CR>", opts)
                vim.keymap.set("n", "K", "<cmd>cN<CR>zz<cmd>wincmd p<CR>", opts)
        end,
})

------------------------------------------------------------------------------------------------------------------------
-- CMDLINE COMPLETION

opt.wildmode = "noselect"
autocmd("CmdlineChanged", {
        desc     = "Add fuzzy completion for command line",
        pattern  = { ":", "/", "!", "?" },
        callback = function()
                vim.fn.wildtrigger()
        end,
})

------------------------------------------------------------------------------------------------------------------------
-- BACKDROP

vim.api.nvim_create_autocmd({ "FileType", "FocusGained", "BufWinEnter" }, {
        desc     = "Add backdrop to windows",
        pattern  = { "dropbar_menu" },
        callback = function(ctx)
                local backdropName = "MasonBackdrop"
                local masonBufnr   = ctx.buf
                local masonZindex  = 10

                local backdropBufnr = vim.api.nvim_create_buf(false, true)
                local winnr         = vim.api.nvim_open_win(backdropBufnr, false, {
                        relative  = "editor",
                        row       = 0,
                        col       = 0,
                        width     = vim.o.columns,
                        height    = vim.o.lines,
                        focusable = false,
                        style     = "minimal",
                        zindex    = masonZindex - 1,
                })

                vim.api.nvim_set_hl(0, backdropName, { link = "SnacksBackdrop" })
                vim.wo[winnr].winhighlight    = "Normal:" .. backdropName
                vim.wo[winnr].winblend        = 40
                vim.bo[backdropBufnr].buftype = "nofile"

                vim.api.nvim_create_autocmd({ "WinClosed" }, {
                        once     = true,
                        buffer   = masonBufnr,
                        callback = function()
                                if vim.api.nvim_win_is_valid(winnr) then vim.api.nvim_win_close(winnr, true) end
                                if vim.api.nvim_buf_is_valid(backdropBufnr) then
                                        vim.api.nvim_buf_delete(backdropBufnr, { force = true })
                                end
                        end,
                })
        end,
})

--------------------------------------------------------------------------------------------------------------------------------------------
-- SNIPPET

autocmd("WinScrolled", {
        desc     = "Exit snippet on window scroll",
        callback = function() vim.snippet.stop() end,
})
