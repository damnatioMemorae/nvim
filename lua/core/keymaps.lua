local nano = require("functions.nano-plugins")
local eval = require("functions.inspect-and-eval")

local prefix = "<LocalLeader>"
local map    = _G.smartMap

local n, i, c, v, o, x, _t = "n", "i", "c", "v", "o", "x", "t"

---- META ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ prefix .. "k", "<cmd>help!<CR>", desc = "Help", mode = { n, x } })
map({ "<leader>R", "<cmd>rest<CR>", desc = "Restart TUI" })
map({ "ZZ", "<cmd>qa<CR>", desc = "Quit" })

map({
        "<A-;>",
        function()
                local path_of_this_lua_file = debug.getinfo(1, "S").source:gsub("^@", "")
                vim.cmd.edit(path_of_this_lua_file)
        end,
        desc = "Edit keybindings",
}) -- [A-;] EDIT KEYMAPS FILE

map({ "<leader>pd", function() vim.ui.open(vim.fn.stdpath("data")) end, desc = "Local data dir" })
map({ "<leader>pD", function() vim.ui.open(vim.fn.stdpath("log")) end, desc = "Log dir" })

---- NAVIGATION ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "_", "0" })

map({ "{", "{zzzz", mode = { n, x }, silent = true })
map({ "}", "}zzzz", mode = { n, x }, silent = true })
map({ "(", "{zzzz", mode = { n, x }, silent = true })
map({ ")", "}zzzz", mode = { n, x }, silent = true })

-- j/k should on wrapped lines
map({ "j", "gj", mode = { n, x } })
map({ "k", "gk", mode = { n, x } })

-- make HJKL behave like hjkl but with bigger distance
map({ "J", "6gj", mode = x })
map({ "K", "6gk", mode = x })

-- Better scroll
map({ "<C-d>", "<C-d>zzzz", silent = true })
map({ "<C-u>", "<C-u>zzzz", silent = true })
map({ "<C-f>", "<C-f>zzzz", silent = true })
map({ "<C-b>", "<C-b>zzzz", silent = true })
map({ "<C-o>", "<C-o>zzzz", remap = true })
map({ "<C-i>", "<C-i>zzzz", remap = true })

-- Last line
map({ "G", "Gzzzz", desc = "Goto last line" })

---- SEARCH --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- map(x,  "/",     fuzzySearch,                { desc = " Fuzzy search" })
map({ "\\", "<Esc>/\\%V", desc = "Search in sel", mode = x })
map({ "n", "nzzzz", desc = "Search next" })
map({ "N", "Nzzzz", desc = "Search previous" })
map({ "<esc>", "<cmd>nohlsearch<cr><esc>", desc = "Escape and Clear hlsearch", mode = { n, i }, silent = true })

map({
        "<A-x>",
        function()
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                for _, line in ipairs(lines) do
                        local url = line:match("%l+://[^%s%)%]}\"'`>]+")
                        if url then return vim.ui.open(url) end
                end
                vim.notify("No URL found in file.", vim.log.levels.WARN)
        end,
        desc = "Open first URL in file",
}) -- [A-x] OPEN FIRST URL IN FILE

--[=[ make `fF` use `nN` instead of `;,`
map(n, "f", function() nano.fF("f") end, { desc = "f" })
map(n, "F", function() nano.fF("F") end, { desc = "F" })
--]=]

---- EDITING -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Undo
map({
        "<leader>u",
        function()
                if not package.loaded["undotree"] then vim.cmd.packadd("nvim.undotree") end
                require("undotree").open()
        end,
        desc = "Undo Tree",
}) -- [spc-u] UNDO TREE
map({ "u", "<cmd>silent undo<CR>", desc = "Silent undo" })
map({ "U", "<cmd>silent redo<CR>", desc = "Silent redo" })
map({ "<LocalLeader>u", ":earlier ", desc = "Undo to earlier" })
map({ "<LocalLeader>U", function() vim.cmd.later(vim.o.undolevels) end, desc = "Redo all" })

-- Duplicate line
map({ "<C-w>", function() nano.smartDuplicate() end, desc = "Duplicate line", nowait = true, dotmap = true })

-- Toggles
map({ "~", "v~", desc = "Toggle char case (w/o moving)" })
map({ "<", function() nano.toggleWordCasing() end, desc = "Toggle lower/Title case" })
map({ ">", function() nano.camelSnakeToggle() end, desc = "Toggle camelCase and snake_case", dotmap = true })

map({
        "X",
        function()
                local updated_line = vim.api.nvim_get_current_line():sub(1, -2)
                vim.api.nvim_set_current_line(updated_line)
        end,
        desc   = "Delete char at EoL",
        dotmap = true,
}) -- [X] DELETE AT EOL

-- Append to EoL
local trail_chars = { ",", ")", ";", ".", '"', "'", " \\", " {", "?" }
for _, chars in pairs(trail_chars) do
        map({
                "<leader>" .. vim.trim(chars),
                function()
                        local updated_line = vim.api.nvim_get_current_line() .. chars
                        vim.api.nvim_set_current_line(updated_line)
                end,
                dotmap = true,
        })
end

map({ "z.", "1z=", desc = "Fix spelling" }) -- works even with `spell=false`
map({
        "zl",
        function()
                local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
                suggestions = vim.list_slice(suggestions, 1, 9)
                vim.ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" }, function(selection)
                        if not selection then return end
                        vim.cmd.normal{ '"_ciw' .. selection, bang = true }
                end)
        end,
        desc = "Spell suggestions",
}) -- [zl] SPELL SUGGESTIONS

map({
        "<A-t>",
        function() require("functions.auto-template-str").insertTemplateStr() end,
        desc = "Insert template string",
        mode = i,
}) -- [A-t] TEMPLATE STRING

-- Repeatable edit
map({ "<C-Space>", '*N"_cgn', desc = "Repeatable edit (cword)", silent = true })
map({
        "<C-Space>",
        function()
                assert(vim.fn.mode() == "v", "Only visual (character) mode.")
                local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
                vim.fn.setreg("/", "\\V" .. vim.fn.escape(selection, [[/\]]))
                return '<Esc>"_cgn'
        end,
        desc = "Repeatable edit (selection)",
        mode = x,
        expr = true,
}) -- [C-spc] REPEATABLE SELECTION EDIT

-- Merging
map({ "m", "J", desc = "Merge line up" })
map({ "M", "<cmd>. move +1<CR>kJ", desc = "Merge line down" })

-- Make file executable
-- keymap(n, "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" })

-- Backspace in INSERT mode
map({ "<C-d>", "<Backspace>", desc = "Delete", mode = { i, c } })

-- Save file
map({ "<C-s>", function() vim.cmd.write() end, desc = "Save File" })

---- SURROUND ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<A-`>", [[wBi`<Esc>ea`<Esc>b]], desc = "Inline Code cword" })
map({ "<A-`>", "<Esc>`<i`<Esc>`>la`<Esc>", desc = "Inline Code selection", mode = x })
map({ "<A-`>", "``<Left>", desc = "Inline Code", mode = i })

---- WHITESPACE ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "-", "[<Space>", desc = "blank above", remap = true, dotmap = true })
map({ "=", "]<Space>", desc = "blank below", remap = true, dotmap = true })

---- QUICKFIX ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ ")", "<cmd>silent cnext<CR>zv<cmd>wincmd p<CR>", silent = true, unique = false })
map({ "(", "<cmd>silent cprev<CR>zv<cmd>wincmd p<CR>", silent = true, unique = false })
map({ "qr", function() vim.cmd.cexpr("[]") end, desc = "Remove items", ft = "qf" })
map({ "qq", "<cmd>silent cfirst<CR>zv<cmd>wincmd p<CR>", desc = "Goto 1st", ft = "qf" })
map({ "Q", "<cmd>silent clast<CR>zv<cmd>wincmd p<CR>", desc = "Goto last", ft = "qf" })
map({
        "<leader>q",
        function()
                local quickfix_win_open = vim.fn.getqflist({ winid = true }).winid ~= 0
                vim.cmd(quickfix_win_open and "cclose" or "copen")
        end,
        desc = "Toggle quickfix window",
}) -- [spc-spc-q] TOGGLE QF WINDOW

---- FOLDS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--[=[
map({ "zz", "<cmd>%foldclose<CR>", desc = "Close toplevel folds" })
map({ "zm", "zM", desc = "Close all folds" })
map({ "zv", "zv", desc = "Open until cursor visible" }) -- just for which-key
map({ "zr", "zR", desc = "Open all folds" })
map({ "zf", function() vim.opt.foldlevel = vim.v.count1 end, desc = "Set fold level to {count}" })
--]=]

---- YANK ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do
        map({
                "y",
                function()
                        vim.b.preYankCursor = vim.api.nvim_win_get_cursor(0)
                        return "y"
                end,
                mode = { n, x },
                expr = true,
        })
        map({
                "Y",
                function()
                        vim.b.preYankCursor = vim.api.nvim_win_get_cursor(0)
                        return "y$"
                end,
                expr   = true,
                unique = false,
        })

        vim.api.nvim_create_autocmd("TextYankPost", {
                desc     = "User: Sticky yank",
                callback = function()
                        if vim.v.event.operator == "y" and vim.b.preYankCursor then
                                vim.api.nvim_win_set_cursor(0, vim.b.preYankCursor)
                                vim.b.preYankCursor = nil
                        end
                end,
        })
end -- STICKY YANK
do
        map({ "<A-p>", '"1p', desc = " Paste from yankring" })

        vim.api.nvim_create_autocmd("TextYankPost", {
                desc     = "User: Yankring",
                callback = function()
                        if vim.v.event.operator ~= "y" then
                                return
                        end
                        for a = 9, 1, -1 do
                                vim.fn.setreg(tostring(a), vim.fn.getreg(tostring(a - 1)))
                        end
                end,
        })
end -- YANKRING

vim.api.nvim_create_autocmd({ "TextYankPost", "TextPutPost" }, {
        desc     = "User: Highlighted Yank",
        callback = function()
                -- play("pickup")
                vim.hl.hl_op({ higroup = "IncSearch", timeout = 150 })
        end,
})

map({ "<C-y>", ":%y<CR>", desc = " Yank all", silent = true })

-- map({ "d", '"_d', mode = { n, x } })
map({ "x", '"_x', mode = { n, x } })
map({ "c", '"_c', mode = { n, x } })
map({ "C", '"_C' })
map({ "p", "P", mode = x })
map({
        "dd",
        function()
                local line_empty = vim.trim(vim.api.nvim_get_current_line()) == ""
                return (line_empty and '"_dd' or "dd")
        end,
        expr = true,
}) -- [dd] DONT SAVE EMPTY LINES

---- PASTE ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "<C-p>",
        function()
                local cur_line = vim.api.nvim_get_current_line():gsub("%s*$", "")
                local reg      = vim.trim(vim.fn.getreg("+"))
                vim.api.nvim_set_current_line(cur_line .. " " .. reg)
        end,
        desc = " Sticky paste at EoL",
}) -- [C-p] PASTE AT EOL
map({
        "<C-v>",
        function()
                local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n")
                vim.fn.setreg("+", reg, "v")
                return "<C-g>u<C-r><C-o>+"
        end,
        desc = " Paste charwise",
        mode = i,
        expr = true,
}) -- [C-v] INSERT MODE PASTE

-- default paste
map({ "p", "]p", desc = " Paste & indent" })

---- TEXTOBJECTS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local textobj_remaps = {
        { "c", "}", "", "curly" },
        { "r", "]", "󰅪", "rectangular" },
        { "m", "W", "󰬞", "WORD" },
        { "q", '"', "", "double" },
        { "z", "'", "", "single" },
        { "e", "`", "", "backtick" },
}
for _, value in pairs(textobj_remaps) do
        local remap, original, icon, label = unpack(value)
        map({ "i" .. remap, "i" .. original, desc = icon .. " inner " .. label, mode = { o, x } })
        map({ "a" .. remap, "a" .. original, desc = icon .. " outer " .. label, mode = { o, x } })
end

-- Special remaps
map({ "J", "2j", mode = o })
-- map({ "<C-Space>", '"_ciw', desc = "change word" })
-- map({ "<C-Space>", '"_c', mode = x, desc = "change selection" })
map({ "d<Space>", '"_daw', desc = "delete word", mode = n })

---- COMMENTS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "q", "zzgc", desc = "Comment operator", mode = { n, x }, remap = true })
map({ "qq", "gcczz", desc = "Comment line", remap = true })

do
        map({ "u", "gc", desc = "Multiline comment", mode = o, remap = true })
        map({ "guu", "guu" }) -- prevent `omap u` above from overwriting `guu`
end
do
        local com = require("functions.comment")
        map({ "qw", function() com.commentHr("replaceMode") end, desc = "Horizontal Divider + Label", dotmap = true })
        map({ "qy", function() com.duplicateLineAsComment() end, desc = "Duplicate Line as Comment", dotmap = true })
        map({ "Q", function() com.addComment("eol") end, desc = "Append Comment", dotmap = true })
        map({ "qo", function() com.addComment("below") end, desc = "Comment Below", dotmap = true })
        map({ "qO", function() com.addComment("above") end, desc = "Comment Above", dotmap = true })
        -- map({
        --         "dQ",
        --         function()
        --                 vim.cmd(("g/%s/d"):format(vim.fn.escape(vim.fn.substitute(vim.o.commentstring, "%s", "", "g"),
        --                                                         "/.*[]~")))
        --         end,
        --         desc = "Delete Comments",
        -- })
        com.setupReplaceModeHelpersForComments()
end

---- LSP -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "<A-d>",
        function()
                vim.diagnostic.jump({ count = 1, float = false })
                vim.cmd.normal("zz")
        end,
        desc = "Diagnostic Next",
        mode = { n, x },
}) -- [A-d] DIAGNOSTIC NEXT
map({
        "<A-D>",
        function()
                vim.diagnostic.jump({ count = -1, float = false })
                vim.cmd.normal("zz")
        end,
        desc = "Diagnostic Prev",
        mode = { n, x },
}) -- [A-d] DIAGNOSTIC PREV

map({ "K", vim.lsp.buf.hover, desc = "Hover Documentation", unique = false })
map({ "J", vim.lsp.buf.signature_help, desc = "Signature Help" })

map({ prefix .. "f", "gF", desc = "LSP Goto File" })
map({ prefix .. "t", "grt", desc = "LSP Type Definition" })
map({ prefix .. "q", vim.lsp.buf.code_action, desc = "LSP Code Action", mode = { n, x }, dotmap = true })

map({ "<A-j>", function() nano.scrollLspOrOtherWin(5) end, desc = "Scroll other win" })
map({ "<A-K>", function() nano.scrollLspOrOtherWin(-5) end, desc = "Scroll other win" })

map({
        "<leader>k",
        function()
                vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })

                vim.api.nvim_create_autocmd("CursorMoved", {
                        group    = vim.api.nvim_create_augroup("line-diagnostics", { clear = true }),
                        callback = function()
                                vim.diagnostic.config({ virtual_lines = false, virtual_text = false })
                                return true
                        end,
                })
        end,
        desc = "Diagnostic Lines",
}) -- [spc-k] DIAGNOSTIC LINES

---- GOTO ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--[=[
map(n, prefix .. "D", vim.lsp.buf.declaration,    { desc = " Goto Declaration" })
map(n, prefix .. "d", vim.lsp.buf.definition,     { desc = " Goto Definition" })
map(n, prefix .. "i", vim.lsp.buf.implementation, { desc = " Goto Implementation" })
map(n, prefix .. "r", vim.lsp.buf.references,     { desc = " Goto Implementation" })
map(n, prefix .. "I", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
map(n, prefix .. "c", vim.lsp.buf.code_action,    { desc = "󱠀 Code Action" })
map(n, prefix .. "F", vim.lsp.buf.format,         { desc = "LSP Format" })
--]=]

---- MODES ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "i",
        function()
                local line_empty = vim.trim(vim.api.nvim_get_current_line()) == ""
                return line_empty and '"_cc' or "i"
        end,
        desc = "indented i on empty line",
        expr = true,
}) -- [i] INSERT MODE

-- VISUAL
map({ "<C-v>", "ggVG", desc = "select all" })
map({ "V", "j", desc = "repeated `V` selects more lines", mode = x })
map({ "v", "<C-v>", desc = "`vv` starts visual block", mode = x })

map({
        "<C-v>",
        function()
                vim.fn.setreg("+", vim.trim(vim.fn.getreg("+")))
                return "<C-r>+"
        end,
        desc = "Paste",
        mode = c,
        expr = true,
}) -- [C-v] CMDLINE PASTE

map({
        "<A-c>",
        function()
                local cmdline = vim.fn.getcmdline()

                if cmdline == "" then
                        return vim.notify("Nothing to copy.", vim.log.levels.WARN)
                end

                vim.fn.setreg("+", cmdline)
                vim.notify(cmdline, nil, { title = "Copied", icon = "󰅍" })
        end,
        desc = "Yank cmdline",
        mode = c,
}) -- [A-c] TANK CMDLINE

map({
        "<BS>",
        function()
                if vim.fn.getcmdline() ~= "" then
                        return "<BS>"
                end
        end,
        desc = "disable <BS> when cmdline is empty",
        mode = c,
        expr = true,
}) -- [BS] DISABLE BS IN EMPTY CMDLINE

map({ "<C-a>", "<C-b>", desc = "Goto start of cmdline", mode = c })
map({ "<A-Left>", "<C-b>", desc = "Goto start of cmdline", mode = c })
map({ "<A-Right>", "<C-e>", desc = "Goto end of cmdline", mode = c })

local function spltis(mod)
        local cmd       = vim.fn.getcmdline()
        local shell_cmd = cmd:match"^!%s*(.*)"
        if shell_cmd then
                cmd = string.format("%s terminal %s", mod, shell_cmd)
        elseif not cmd:match("^%s*" .. vim.pesc(mod) .. "%s+") then
                cmd = string.format("%s %s", mod, cmd)
        end

        return "<C-\\>e" .. vim.fn.string(cmd) .. "<CR><CR>"
end

map({ "<c-l>", function() return spltis("vertical") end, mode = c, expr = true })
map({ "<c-j>", function() return spltis("horizontal") end, mode = c, expr = true })
map({ "<c-cr>", function() return spltis("tab") end, mode = c, expr = true })

---- INSPECT & EVAL ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<leader>ii", vim.cmd.Inspect, desc = "Inspect at cursor" })
map({ "<leader>it", vim.treesitter.inspect_tree, desc = "TS tree" })
map({ "<leader>iq", vim.treesitter.query.edit, desc = "TS query" })

map({ "<leader>in", function() eval.nodeAtCursor() end, desc = "Node at cursor" })
map({ "<leader>ia", function() eval.inspectNodeAncestors() end, desc = "Node ancestors" })

map({ "<leader>iL", function() vim.cmd.edit(vim.lsp.log.get_filename()) end, desc = "LSP log" })
map({ "<leader>il", function() eval.lspCapabilities() end, desc = "LSP capabilities" })
map({ "<leader>ib", function() eval.bufferInfo() end, desc = "Buffer info" })
map({ "<leader>ie", function() eval.evalNvimLua() end, desc = "Eval", mode = { n, x } })
map({ "<leader><leader>x", function() eval.runFile() end, desc = "Run file" })

map({
        "<leader>id",
        function()
                local diag = vim.diagnostic.get_next()
                vim.notify(vim.inspect(diag), nil, { ft = "lua" })
        end,
        desc = "Next diagnostic",
}) -- [spc-i-d] NEXT DIAGNOSTIC

map({
        "<leader>E",
        function()
                local selection = vim.fn.mode() == "n" and "" or
                           vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
                return ":lua = " .. selection
        end,
        desc = "Eval lua expr",
        mode = { n, x },
        expr = true,
}) -- [spc-E] EVLA LUA EXPRESSION

map({
        "<leader>ye",
        function()
                local cmd        = vim.trim(vim.fn.getreg(":"))
                local last_excmd = cmd:gsub("^lua ", ""):gsub("^= ?", "")

                if last_excmd == "" then
                        return vim.notify("Nothing to copy", vim.log.levels.TRACE)
                end

                local syntax = vim.startswith(cmd, "lua") and "lua" or "vim"
                vim.notify(last_excmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
                vim.fn.setreg("+", last_excmd)
        end,
        desc = "Yank last ex-cmd",
}) -- [spc-y-e] YANK LAST EX COMMAND

---- WINDOWS & SPLITS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<A-m>", "<cmd>vsplit<CR>", desc = "Split altfile", mode = { n, x, i } })
map({ "<A-Space>", "<C-w>w", desc = "Cycle windows", mode = { n, v, i } })
map({ "<A-n>", "<cmd>vertical split #<CR>", desc = "Split altfile", mode = { n, x, i } })
map({ "<C-n>", desc = "Notification History", "<cmd>messages<CR>" })
map({ "<A-W>", vim.cmd.only, desc = "Close other windows", mode = { n, x, i } })

---- BUFFERS & FILES -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "<A-w>",
        function()
                vim.cmd("silent! update")
                local win_closed = pcall(vim.cmd.close) -- fails on last window
                if win_closed then
                        return
                end
                local buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
                if buf_count == 1 then
                        return vim.notify("Only one buffer open.", vim.log.levels.TRACE)
                end
                vim.cmd.bdelete()
        end,
        desc   = "Close window/buffer",
        mode   = { n, i, x },
        dotmap = true,
}) -- [A-w] DELETE WINDOW/BUFFER

map({ "<A-r>", vim.cmd.edit, desc = "Reload buffer" })
map({
        "H",
        function()
                if vim.bo.buftype ~= "" then return end
                vim.cmd.bprevious()
        end,
        desc = "Prev Buffer",
}) -- [H] PREVIOUS BUFFER
map({
        "L",
        function()
                if vim.bo.buftype ~= "" then return end
                vim.cmd.bnext()
        end,
        desc = "Next Buffer",
})

---- MACROS --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do
        local reg        = "r"
        local toggle_key = "0"

        vim.fn.setreg(reg, "")
        map({ toggle_key, function() nano.startOrStopRecording(toggle_key, reg) end, desc = "Start/stop recording" })
        map({ "9", function() nano.playRecording(reg) end, desc = "Play recording" })
end

---- REFACTORING ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<leader>fd", ":global //d<Left><Left>", desc = "delete matching lines" })

map({ "<LocalLeader>n", vim.lsp.buf.rename, desc = "LSP rename", dotmap = true })
map({ "<LocalLeader>m", function() nano.camelSnakeLspRename() end, desc = "LSP rename: camel/snake", dotmap = true })

--[=[
map({
        "<leader>qq",
        function()
                local updated_line =
                           vim.api.nvim_get_current_line():gsub("[\"']", { ['"'] = "'", ["'"] = '"' })
                vim.api.nvim_set_current_line(updated_line)
        end,
        mode = n,
        desc = "Switch quotes in line",
}) -- [spc-q-q] SWITCH QUOTES ]=]

---- OPTION TOGGLING -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "<leader>ol",
        function()
                vim.cmd.lsp("restart")
                vim.notify("Restarting LSPs", vim.log.levels.DEBUG)
        end,
        desc = "LSP restart",
}) -- [spc-o-l] RESTART LSP

map({ "<leader>oc", function() Toggle.concealLvl() end, desc = "Toggle Conceal" })
map({ "<leader>o<leader>", function() Toggle.all() end, desc = "Toggle UI" })

---- RELOAD PLUGINS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "<leader>lr",
        function()
                local plugins      = require("lazy").plugins()
                local plugin_names = {}
                for _, plugin in ipairs(plugins) do
                        table.insert(plugin_names, plugin.name)
                end

                vim.ui.select(
                        plugin_names,
                        { title = "Reload plugin" },
                        function(selected) require("lazy").reload({ plugins = { selected } }) end
                )
        end,
        desc = "Reload plugin",
})

local loaded = pcall(require, "tiny-cmdline")
if not loaded then
        map({ ":", function()
                require("functions.cmdline").cmdline()
        end })
end
