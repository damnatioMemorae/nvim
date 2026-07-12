local nano = require("functions.nano-plugins")
local eval = require("functions.inspect-and-eval")

local map = _G.smartMap

local n, i, c, v, o, x, _t = "n", "i", "c", "v", "o", "x", "t"

---- META ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<LocalLeader>k", "<cmd>help!<CR>", desc = "Help", mode = { n, x } })
map({ "<leader>R", "<cmd>rest<CR>", desc = "Restart TUI" })
map({ "ZZ", "<cmd>qa<CR>", desc = "Quit" })

map({ -- `A-;` EDIT KEYMAPS FILE
        "<A-;>",
        function()
                local path_of_this_lua_file = debug.getinfo(1, "S").source:gsub("^@", "")
                vim.cmd.edit(path_of_this_lua_file)
        end,
        desc = "Edit keybindings",
})

map({ "<leader>pd", function() vim.ui.open(vim.fn.stdpath("data")) end, desc = "Local data dir" })
map({ "<leader>pD", function() vim.ui.open(vim.fn.stdpath("log")) end, desc = "Log dir" })

---- NAVIGATION ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "_", "0" })

map({ "{", "{", mode = { n, x }, silent = true })
map({ "}", "}", mode = { n, x }, silent = true })
map({ "(", "{", mode = { n, x }, silent = true })
map({ ")", "}", mode = { n, x }, silent = true })

-- j/k should on wrapped lines
map({ "j", "gj", mode = { n, x } })
map({ "k", "gk", mode = { n, x } })

-- make HJKL behave like hjkl but with bigger distance
map({ "J", "6gj", mode = x })
map({ "K", "6gk", mode = x })

---- SEARCH --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- map(x,  "/",     fuzzySearch,                { desc = " Fuzzy search" })
map({ "\\", "<Esc>/\\%V", desc = "Search in sel", mode = x })
map({ "n", "n", desc = "Search next" })
map({ "N", "N", desc = "Search previous" })
map({ "<esc>", "<cmd>nohlsearch<cr><esc>", desc = "Escape and Clear hlsearch", mode = { n, i }, silent = true })

--[[ -- `A-x` OPEN FIRST URL IN FILE
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
})
--]]

--[[ make `fF` use `nN` instead of `;,`
map(n, "f", function() nano.fF("f") end, { desc = "f" })
map(n, "F", function() nano.fF("F") end, { desc = "F" })
--]]

---- EDITING -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Undo
map({ -- `spc-u` UNDO TREE
        "<leader>u",
        function()
                if not package.loaded["undotree"] then
                        vim.cmd.packadd("nvim.undotree")
                end
                require("undotree").open()
        end,
        desc = "Undo Tree",
})
map({ "u", "<cmd>silent undo<CR>", desc = "Silent undo" })
map({ "U", "<cmd>silent redo<CR>", desc = "Silent redo" })
map({ "<LocalLeader>u", ":earlier ", desc = "Undo to earlier" })
map({ "<LocalLeader>U", function() vim.cmd.later(vim.o.undolevels) end, desc = "Redo all" })

-- Duplicate line
map({ "<C-w>", nano.smartDuplicate, desc = "Duplicate line", nowait = true })

-- Toggles
map({ "~", "v~", desc = "Toggle char case (w/o moving)" })
map({ "<", nano.toggleWordCasing, desc = "Toggle lower/Title case", dotmap = true })
map({ ">", nano.camelSnakeToggle, desc = "Toggle camelCase and snake_case", dotmap = true })

map({ -- `X` DELETE AT EOL
        "X",
        function()
                local updated_line = vim.api.nvim_get_current_line():sub(1, -2)
                vim.api.nvim_set_current_line(updated_line)
        end,
        desc   = "Delete char at EoL",
        dotmap = true,
})

-- Append to EoL
vim
           .iter({ ",", ")", ";", ".", '"', "'", " \\", " {", "?" })
           :each(function(char)
                   map({
                           "<leader>" .. vim.trim(char),
                           function()
                                   local updated_line = vim.api.nvim_get_current_line() .. char
                                   vim.api.nvim_set_current_line(updated_line)
                           end,
                           dotmap = true,
                   })
           end)

map({ "z.", "1z=", desc = "Fix spelling" }) -- works even with `spell=false`

map({ -- `zl` SPELL SUGGESTIONS
        "zl",
        function()
                local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
                suggestions = vim.list_slice(suggestions, 1, 9)
                vim.ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" }, function(selection)
                        if not selection then
                                return
                        end
                        vim.cmd.normal{ '"_ciw' .. selection, bang = true }
                end)
        end,
        desc = "Spell suggestions",
})

map({ -- `A-t` TEMPLATE STRING
        "<A-t>",
        function() require("functions.auto-template-str").insertTemplateStr() end,
        desc = "Insert template string",
        mode = i,
})

-- Repeatable edit
map({ "<C-Space>", '*N"_cgn', desc = "Repeatable edit (cword)", silent = true })
map({ -- `C-spc` REPEATABLE SELECTION EDIT
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
})

-- Merging
map({ "m", "J", desc = "Merge line up" })
map({ "M", "<cmd>. move +1<CR>kJ", desc = "Merge line down" })

-- Make file executable
-- keymap(n, "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" })

-- Backspace in INSERT mode
map({ "<C-d>", "<Backspace>", desc = "Delete", mode = { i, c } })

-- Save file
map({ "<C-s>", vim.cmd.write, desc = "Save File" })

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
map({ -- `spc-spc-q` TOGGLE QF WINDOW
        "<leader>q",
        function()
                local quickfix_win_open = vim.fn.getqflist({ winid = true }).winid ~= 0
                vim.cmd(quickfix_win_open and "cclose" or "copen")
        end,
        desc = "Toggle quickfix window",
})

---- FOLDS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---- YANK ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<C-y>", ":%y<CR>", desc = "Yank all", silent = true })

do -- STICKY YANK
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
end
do -- YANKRING
        map({ "<A-p>", '"1p', desc = "Paste from yankring" })

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
end

-- map({ "d", '"_d', mode = { n, x } })
map({ "x", '"_x', mode = { n, x } })
map({ "c", '"_c', mode = { n, x } })
map({ "C", '"_C' })
map({ "p", "P", mode = x })
map({ -- `dd` DONT SAVE EMPTY LINES
        "dd",
        function()
                local line_empty = vim.trim(vim.api.nvim_get_current_line()) == ""
                return (line_empty and '"_dd' or "dd")
        end,
        expr = true,
})

---- PASTE ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ -- `C-p` PASTE AT EOL
        "<C-p>",
        function()
                local cur_line = vim.api.nvim_get_current_line():gsub("%s*$", "")
                local reg      = vim.trim(vim.fn.getreg("+"))
                vim.api.nvim_set_current_line(cur_line .. " " .. reg)
        end,
        desc = "Sticky paste at EoL",
})
map({ -- `C-v` INSERT MODE PASTE
        "<C-v>",
        function()
                local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n")
                vim.fn.setreg("+", reg, "v")
                return "<C-g>u<C-r><C-o>+"
        end,
        desc = "Paste charwise",
        mode = i,
        expr = true,
})

-- default paste
map({ "p", "]p", desc = "Paste & indent" })

---- TEXTOBJECTS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local textobj_remaps = {
        { "c", "}", "curly" },
        { "r", "]", "rectangular" },
        { "m", "W", "WORD" },
        { "q", '"', "double" },
        { "z", "'", "single" },
        { "e", "`", "backtick" },
}
vim
           .iter(textobj_remaps)
           :each(function(value)
                   local remap, original, label = unpack(value)
                   map({ "i" .. remap, "i" .. original, desc = "inner " .. label, mode = { o, x } })
                   map({ "a" .. remap, "a" .. original, desc = "outer " .. label, mode = { o, x } })
           end)

-- Special remaps
map({ "J", "2j", mode = o })
map({ "d<Space>", '"_daw', desc = "delete word", mode = n })

---- COMMENTS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "q", "gc", desc = "Comment operator", mode = { n, x }, remap = true })
map({ "qq", "gcc", desc = "Comment line", remap = true })

do
        map({ "u", "gc", desc = "Multiline comment", mode = o, remap = true })
        map({ "guu", "guu" })
end

do
        local com = require("functions.comment")
        map({ "qw", function() com.commentHr("replaceMode") end, desc = "Horizontal Divider + Label", dotmap = true })
        map({ "qe", function() com.commentHr() end, desc = "Horizontal Divider", dotmap = true })
        map({ "qy", function() com.duplicateLineAsComment() end, desc = "Duplicate Line as Comment", dotmap = true })
        map({ "Q", function() com.addComment("eol") end, desc = "Append Comment", dotmap = true })
        map({ "qo", function() com.addComment("below") end, desc = "Comment Below", dotmap = true })
        map({ "qO", function() com.addComment("above") end, desc = "Comment Above", dotmap = true })
        map({ "dQ", "<cmd>DeleteComments<CR>", desc = "Delete All Comments" })

        com.setupReplaceModeHelpersForComments()
end

---- LSP -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ -- `A-d` DIAGNOSTIC NEXT
        "<A-d>",
        function()
                vim.diagnostic.jump({ count = 1, float = false })
        end,
        desc = "Diagnostic Next",
        mode = { n, x },
})
map({ -- `A-d` DIAGNOSTIC PREV
        "<A-D>",
        function()
                vim.diagnostic.jump({ count = -1, float = false })
        end,
        desc = "Diagnostic Prev",
        mode = { n, x },
})

map({ "K", vim.lsp.buf.hover, desc = "Hover Documentation", unique = false })
map({ "J", vim.lsp.buf.signature_help, desc = "Signature Help" })

map({ "<LocalLeader>f", "gF", desc = "LSP Goto File" })
map({ "<LocalLeader>t", "grt", desc = "LSP Type Definition" })
map({ "<LocalLeader>q", vim.lsp.buf.code_action, desc = "LSP Code Action", mode = { n, x } })

map({ "<A-j>", function() nano.scrollLspOrOtherWin(5) end, desc = "Scroll other win" })
map({ "<A-K>", function() nano.scrollLspOrOtherWin(-5) end, desc = "Scroll other win" })

map({ -- `spc-k` DIAGNOSTIC LINES
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
})

---- MODES ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ -- `i` INSERT MODE
        "i",
        function()
                local line_empty = vim.trim(vim.api.nvim_get_current_line()) == ""
                return line_empty and '"_cc' or "i"
        end,
        desc = "indented i on empty line",
        expr = true,
})

-- VISUAL
map({ "<C-v>", "ggVG", desc = "select all" })
map({ "V", "j", desc = "repeated `V` selects more lines", mode = x })
map({ "v", "<C-v>", desc = "`vv` starts visual block", mode = x })

map({ -- `C-v` CMDLINE PASTE
        "<C-v>",
        function()
                vim.fn.setreg("+", vim.trim(vim.fn.getreg("+")))
                return "<C-r>+"
        end,
        desc = "Paste",
        mode = c,
        expr = true,
})

map({ -- `A-c` TANK CMDLINE
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
})

map({ -- `BS` DISABLE BS IN EMPTY CMDLINE
        "<BS>",
        function()
                if vim.fn.getcmdline() ~= "" then
                        return "<BS>"
                end
        end,
        desc = "disable <BS> when cmdline is empty",
        mode = c,
        expr = true,
})

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

map({ "<leader>in", eval.nodeAtCursor, desc = "Node at cursor" })
map({ "<leader>ia", eval.inspectNodeAncestors, desc = "Node ancestors" })

map({ "<leader>iL", function() vim.cmd.edit(vim.lsp.log.get_filename()) end, desc = "LSP log" })
map({ "<leader>il", eval.lspCapabilities, desc = "LSP capabilities" })
map({ "<leader>ib", eval.bufferInfo, desc = "Buffer info" })
map({ "<leader>ie", eval.evalNvimLua, desc = "Eval", mode = { n, x } })
map({ "<leader><leader>x", eval.runFile, desc = "Run file" })

map({ -- `spc-i-d` NEXT DIAGNOSTIC
        "<leader>id",
        function()
                local diag = vim.diagnostic.get_next()
                vim.notify(vim.inspect(diag), nil, { ft = "lua" })
        end,
        desc = "Next diagnostic",
})

map({ -- `spc-E` EVLA LUA EXPRESSION
        "<leader>iE",
        function()
                local selection = vim.fn.mode() == "n" and "" or
                           vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
                return ":lua = " .. selection
        end,
        desc = "Eval lua expr",
        mode = { n, x },
        expr = true,
})

map({ -- `spc-y-e` YANK LAST EX COMMAND
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
})

---- WINDOWS & SPLITS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<A-m>", "<cmd>vsplit<CR>", desc = "Split altfile", mode = { n, x, i } })
map({ "<A-Space>", "<C-w>w", desc = "Cycle windows", mode = { n, v, i } })
map({ "<A-n>", "<cmd>vertical split #<CR>", desc = "Split altfile", mode = { n, x, i } })
map({ "<C-n>", "<cmd>messages<CR>", desc = "Notification History" })
map({ "<A-W>", vim.cmd.only, desc = "Close other windows", mode = { n, x, i } })

---- BUFFERS & FILES -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ -- `A-w` DELETE WINDOW/BUFFER
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
        desc = "Close window/buffer",
        mode = { n, i, x },
})

map({ "<A-r>", vim.cmd.edit, desc = "Reload buffer" })
map({ -- `H` PREVIOUS BUFFER
        "H",
        function()
                if vim.bo.buftype ~= "" then return end
                vim.cmd.bprevious()
        end,
        desc = "Prev Buffer",
})
map({ -- `L` NEXT BUFFER
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

map({ "<LocalLeader>n", vim.lsp.buf.rename, desc = "LSP rename" })
map({ "<LocalLeader>m", nano.camelSnakeLspRename, desc = "LSP rename: camel/snake", dotmap = true })

---- OPTION TOGGLING -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ -- `spc-o-l` RESTART LSP
        "<leader>ol",
        function()
                vim.cmd.lsp("restart")
                vim.notify("Restarting LSPs", vim.log.levels.DEBUG)
        end,
        desc = "LSP restart",
})

map({ "<leader>oc", Toggle.concealLvl, desc = "Toggle Conceal" })
map({ "<leader>o<leader>", Toggle.all, desc = "Toggle UI" })

---- RELOAD PLUGINS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "<leader>lr",
        function()
                local plugin_names = {}
                vim
                           .iter(require("lazy").plugins())
                           :each(function(plugin)
                                   table.insert(plugin_names, plugin.name)
                           end)

                vim.ui.select(
                        plugin_names,
                        { title = "Reload plugin" },
                        function(selected) require("lazy").reload({ plugins = { selected } }) end
                )
        end,
        desc = "Reload plugin",
})
