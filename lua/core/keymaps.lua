local b    = vim.b
local bo   = vim.bo
local fn   = vim.fn
local ui   = vim.ui
local api  = vim.api
local cmd  = vim.cmd
local log  = vim.log
local lsp  = vim.lsp
local ts   = vim.treesitter
local diag = vim.diagnostic

local levels = log.levels

local n, i, c, v, o, x, _t = "n", "i", "c", "v", "o", "x", "t"

local com  = require "functions.comment"
local eval = require "functions.inspect-and-eval"
local nano = require "functions.nano-plugins"

local send = nano.teleSend
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function spltis(mod)
        local command   = fn.getcmdline()
        local shell_cmd = command:match "^!%s*(.*)"
        if shell_cmd then
                command = string.format("%s terminal %s", mod, shell_cmd)
        elseif not command:match("^%s*" .. vim.pesc(mod) .. "%s+") then
                command = string.format("%s %s", mod, command)
        end

        return "<C-\\>e" .. fn.string(command) .. "<CR><CR>"
end

local function open(path)
        ui.open(fn.stdpath(path))
end

keyq { "<LocalLeader>k", "<cmd>help!<CR>", desc = "Help", mode = { n, x } }
keyq { "<leader>R", cmd.restart, desc = "Restart TUI" }
keyq { "<C-s>", cmd.write, desc = "Save File" }
keyq { "ZZ", function() cmd "qa" end, desc = "Quit" }
keyq { "<leader>pl", function() open "log" end, desc = "Log dir" }
keyq { "<leader>pd", function() open "data" end, desc = "Local data dir" }
keyq { "<leader>S", function() send "file" end, desc = "Telegram send file" }
keyq { "<leader>SS", function() send "text" end, desc = "Telegram send text" }

keyq { "_", "0" }
keyq { "j", "gj", mode = { n, x } }
keyq { "k", "gk", mode = { n, x } }
keyq { "J", "6gj", mode = x }
keyq { "K", "6gk", mode = x }

keyq { "n", "n", desc = "Search next" }
keyq { "N", "N", desc = "Search previous" }
keyq { "\\", "<Esc>/\\%V", desc = "Search in sel", mode = x }
keyq { "<esc>", "<cmd>nohlsearch<cr><esc>", desc = "Escape and Clear hlsearch", mode = { n, i }, silent = true }

keyq { "u", "<cmd>silent undo<CR>", desc = "Silent undo" }
keyq { "U", "<cmd>silent redo<CR>", desc = "Silent redo" }
keyq { "<LocalLeader>u", ":earlier ", desc = "Undo to earlier" }
keyq { "<LocalLeader>U", function() cmd.later(vim.o.undolevels) end, desc = "Redo all" }
keyq { "<leader>u", function() -- `spc-u` UNDO TREE
        if not package.loaded["undotree"] then
                cmd.packadd "nvim.undotree"
        end
        require "undotree".open()
end, desc = "Undo Tree" }

keyq { "<", nano.toggleWordCasing, desc = "Toggle lower/Title case" }
keyq { ">", nano.camelSnakeToggle, desc = "Toggle camelCase and snake_case" }
keyq { "<C-w>", nano.smartDuplicate, desc = "Duplicate line", nowait = true }
keyq { "M", "<cmd>. move +1<CR>kJ", desc = "Merge line down" }
keyq { "~", "v~", desc = "Toggle char case (w/o moving)" }
keyq { "m", "J", desc = "Merge line up" }
keyq { "z.", "1z=", desc = "Fix spelling" }
keyq { "zl", function() -- `zl` SPELL SUGGESTIONS
        local suggestions = fn.spellsuggest(fn.expand "<cword>")
        suggestions       = vim.list_slice(suggestions, 1, 9)
        ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" },
                  function(selection)
                          if not selection then return end
                          cmd.normal { '"_ciw' .. selection, bang = true }
                  end)
end, desc = "Spell suggestions" }

keyq { "X", function() -- `X` DELETE AT EOL
        local updated_line = api.nvim_get_current_line():sub(1, -2)
        api.nvim_set_current_line(updated_line)
end, desc = "Delete char at EoL" }

vim -- Append to EoL
           .iter { ",", ")", ";", ".", '"', "'", " \\", " {", "?", "_" }
           :each(function(char)
                   keyq { "<leader>" .. vim.trim(char), function()
                           local updated_line = api.nvim_get_current_line() .. char
                           api.nvim_set_current_line(updated_line)
                   end }
           end)

keyq { "<M-t>", function() -- `M-t` TEMPLATE STRING
        require "functions.auto-template-str".insertTemplateStr()
end, desc = "Insert template string", mode = i }

keyq { "<C-Space>", '*N"_cgn', desc = "Repeatable edit (cword)", silent = true }
keyq { "<C-Space>", function() -- `C-spc` REPEATABLE SELECTION EDIT,
        assert(fn.mode() == "v", "Only visual (character) mode.")
        local selection = fn.getregion(fn.getpos ".", fn.getpos "v")[1]
        fn.setreg("/", "\\V" .. fn.escape(selection, [[/\]]))
        return '<Esc>"_cgn'
end, desc = "Repeatable edit (selection)", mode = x, expr = true }

keyq { "<M-`>", [[wBi`<Esc>ea`<Esc>b]], desc = "Inline Code cword" }
keyq { "<M-`>", "<Esc>`<i`<Esc>`>la`<Esc>", desc = "Inline Code selection", mode = x }
keyq { "<M-`>", "``<Left>", desc = "Inline Code", mode = i }

keyq { "-", "[<Space>", desc = "blank above", remap = true }
keyq { "=", "]<Space>", desc = "blank below", remap = true }

keyq { "<C-y>", ":%y<CR>", desc = "Yank all", silent = true }
keyq { "y", function() -- STICKY
        b.preYankCursor = api.nvim_win_get_cursor(0)
        return "y"
end, mode = { n, x }, expr = true }
keyq { "Y", function() -- STICKY
        b.preYankCursor = api.nvim_win_get_cursor(0)
        return "y$"
end, expr = true, unique = false }

-- keyq { "d", '"_d', mode = { n, x } }
keyq { "x", '"_x', mode = { n, x } }
keyq { "c", '"_c', mode = { n, x } }
keyq { "C", '"_C' }
keyq { "p", "P", mode = x }
keyq { "dd", function() -- `dd` DONT SAVE EMPTY LINES
        local line_empty = vim.trim(api.nvim_get_current_line()) == ""
        return (line_empty and '"_dd' or "dd")
end, expr = true }

keyq { "p", "]p", desc = "Paste & indent" }

keyq { "<C-p>", function() -- STICKY PASTE AT EOL
        local cur_line = api.nvim_get_current_line():gsub("%s*$", "")
        local reg      = vim.trim(fn.getreg "+")
        api.nvim_set_current_line(cur_line .. " " .. reg)
end, desc = "Sticky paste at EoL" }

keyq { "<C-v>", function() -- PASTE CHARWISE
        local reg = vim.trim(fn.getreg "+"):gsub("\n%s*$", "\n")
        fn.setreg("+", reg, "v")
        return "<C-g>u<C-r><C-o>+"
end, desc = "Paste charwise", mode = i, expr = true }

do -- YANKRING
        keyq { "<M-p>", '"1p', desc = "Paste from yankring" }

        auq "TextYankPost" {
                desc     = "User: Yankring",
                callback = function()
                        if vim.v.event.operator ~= "y" then
                                return
                        end
                        for a = 9, 1, -1 do
                                fn.setreg(tostring(a), fn.getreg(tostring(a - 1)))
                        end
                end,
        }
end

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
                   keyq { "i" .. remap, "i" .. original, desc = "inner " .. label, mode = { o, x } }
                   keyq { "a" .. remap, "a" .. original, desc = "outer " .. label, mode = { o, x } }
           end)

keyq { "J", "2j", mode = o }
keyq { "d<Space>", '"_daw', desc = "delete word", mode = n }

do -- COMMENT
        keyq { "q", "gc", desc = "Comment operator", mode = { n, x }, remap = true }
        keyq { "qq", "gcc", desc = "Comment line", remap = true }
        keyq { "u", "gc", desc = "Multiline comment", mode = o, remap = true }
        keyq { "guu", "guu" }

        keyq { "qw", function() com.commentHr "replaceMode" end, desc = "Horizontal Divider + Label" }
        keyq { "qe", function() com.commentHr() end, desc = "Horizontal Divider" }
        keyq { "qy", function() com.duplicateLineAsComment() end, desc = "Duplicate Line as Comment" }
        keyq { "Q", function() com.addComment "eol" end, desc = "Append Comment" }
        keyq { "qo", function() com.addComment "below" end, desc = "Comment Below" }
        keyq { "qO", function() com.addComment "above" end, desc = "Comment Above" }
        keyq { "dQ", "<cmd>DeleteComments<CR>", { desc = "Delete All Comments" } }
        com.setupReplaceModeHelpersForComments()
end

keyq { "i", function()
        local line_empty = vim.trim(api.nvim_get_current_line()) == ""
        return line_empty and '"_cc' or "i"
end, desc = "indented i on empty line", expr = true }

keyq { "<C-v>", "ggVG", desc = "select all" }
keyq { "V", "j", desc = "repeated `V` selects more lines", mode = x }
keyq { "v", "<C-v>", desc = "`vv` starts visual block", mode = x }

keyq { "<C-a>", "<C-b>", desc = "Goto start of cmdline", mode = c }
keyq { "<M-Left>", "<C-b>", desc = "Goto start of cmdline", mode = c }
keyq { "<M-Right>", "<C-e>", desc = "Goto end of cmdline", mode = c }

keyq { "<C-v>", function() -- `C-v` PASTE CMDLINE
        fn.setreg("+", vim.trim(fn.getreg "+"))
        return "<C-r>+"
end, desc = "Cmdline Paste", mode = c, expr = true }
keyq { "<M-c>", function() -- `C-v` PASTE CMDLINE
        local cmdline = fn.getcmdline()
        if cmdline == "" then return vim.notify("Nothing to copy.", levels.WARN) end
        fn.setreg("+", cmdline)
        vim.notify(cmdline, nil, { title = "Copied", icon = "󰅍" })
end, desc = "Yank cmdline", mode = c }
keyq { "<BS>", function() -- `M-c` TANK CMDLINE
        if fn.getcmdline() ~= "" then return "<BS>" end
end, desc = "disable <BS> when cmdline is empty", mode = c, expr = true, unique = false }

keyq { "<c-l>", function() return spltis "vertical" end, mode = c, expr = true }
keyq { "<c-j>", function() return spltis "horizontal" end, mode = c, expr = true }
keyq { "<c-CR>", function() return spltis "tab" end, mode = c, expr = true }

keyq { "<leader>ii", cmd.Inspect, desc = "Inspect at cursor" }
keyq { "<leader>it", ts.inspect_tree, desc = "TS tree" }
keyq { "<leader>iq", ts.query.edit, desc = "TS query" }
keyq { "<leader>in", eval.nodeAtCursor, desc = "Node at cursor" }
keyq { "<leader>ia", eval.inspectNodeAncestors, desc = "Node ancestors" }
keyq { "<leader>iL", function() cmd.edit(lsp.log.get_filename()) end, desc = "LSP log" }
keyq { "<leader>il", eval.lspCapabilities, desc = "LSP capabilities" }
keyq { "<leader>ib", eval.bufferInfo, desc = "Buffer info" }
keyq { "<leader><leader>x", eval.runFile, desc = "Run file" }
keyq { "<leader>ye", function() -- `spc-y-e` YANK LAST EX COMMAND
        local command    = vim.trim(fn.getreg ":")
        local last_excmd = command:gsub("^lua ", ""):gsub("^= ?", "")
        if last_excmd == "" then return vim.notify("Nothing to copy", levels.TRACE) end
        local syntax = vim.startswith(command, "lua") and "lua" or "vim"
        vim.notify(last_excmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
        fn.setreg("+", last_excmd)
end, desc = "Yank last ex-cmd" }

keyq { "<leader>ie", eval.evalNvimLua, desc = "Eval" }
keyq { "<CR>", eval.evalNvimLua, desc = "Eval", mode = x, ft = "lua" }
keyq { "<leader>id", function() -- `spc-i-d` NEXT DIAGNOSTIC
        vim.notify(vim.inspect(diag.get_next()), nil, { ft = "lua" })
end, desc = "Next diagnostic" }
keyq { "<leader>iE", function() -- `spc-E` EVLA LUA EXPRESSION
        local selection = fn.mode() == "n" and "" or fn.getregion(fn.getpos ".", fn.getpos "v")[1]
        return ":lua  = " .. selection
end, desc = "Eval lua expr", mode = { n, x }, expr = true }

keyq { "<M-Space>", "<C-w>w", desc = "Cycle windows", mode = { n, v, i } }
keyq { "<M-m>", "<cmd>vsplit<CR>", desc = "Split altfile", mode = { n, x, i } }
keyq { "<M-n>", "<cmd>vertical split #<CR>", desc = "Split altfile", mode = { n, x, i } }
keyq { "<C-n>", "<cmd>messages<CR>", desc = "Notification History" }
keyq { "<M-W>", "<cmd>only<CR>", desc = "Close other windows", mode = { n, x, i } }

keyq { "<M-r>", cmd.edit, desc = "Reload buffer" }

keyq { "<M-w>", function() -- `M-w` DELETE WINDOW/BUFFER
        cmd "silent! update"
        local win_closed = pcall(cmd.close)
        if win_closed then
                return
        end
        local buf_count = #fn.getbufinfo { buflisted = 1 }
        if buf_count == 1 then
                return vim.notify("Only one buffer open.", levels.TRACE)
        end
        cmd.bdelete()
end, desc = "Close window/buffer", mode = { n, i, x } }
keyq { "H", function() -- `H` PREVIOUS BUFFER
        if bo.buftype ~= "" then return end
        cmd.bprevious()
end, desc = "Prev Buffer" }
keyq { "L", function() -- `L` NEXT BUFFER
        if bo.buftype ~= "" then return end
        cmd.bnext()
end, desc = "Next Buffer" }

do -- MACRO
        local reg        = "r"
        local toggle_key = "0"

        fn.setreg(reg, "")

        keyq { toggle_key, function() nano.startOrStopRecording(toggle_key, reg) end, desc = "Start/stop recording" }
        keyq { "9", function() nano.playRecording(reg) end, desc = "Play recording" }
end

keyq { "<leader>fd", ":global //d<Left><Left>", desc = "delete matching lines" }
keyq { "<LocalLeader>n", lsp.buf.rename, desc = "LSP rename" }
keyq { "<LocalLeader>m", nano.camelSnakeLspRename, desc = "LSP rename: camel/snake" }

keyq { "<leader>oc", Toggle.concealLvl, desc = "Toggle Conceal" }
keyq { "<leader>o<leader>", Toggle.all, desc = "Toggle UI" }
