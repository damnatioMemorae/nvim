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
local iter = vim.iter

local levels = log.levels

local n, i, c, v, o, x, _t = "n", "i", "c", "v", "o", "x", "t" ---@diagnostic disable-line unused-local

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

kq -- META
""
    { "ZZ", function() cmd "qa" end, desc = "Quit" }
    { "ZR", "<cmd>restart!<CR>", desc = "Restart" }
    { "<C-s>", cmd.write, desc = "Save File" }
    { "<LocalLeader>k", "<cmd>help!<CR>", desc = "Help", mode = { n, x } }
    { "<leader>pl", function() open "log" end, desc = "Log dir" }
    { "<leader>pd", function() open "data" end, desc = "Local data dir" }
    { "<leader>S", function() send "file" end, desc = "Telegram send file" }
    { "<leader>SS", function() send "text" end, desc = "Telegram send text" }

kq -- MOTIONS
""
    { "_", "0" }
    { "j", "gj", mode = { n, x } }
    { "k", "gk", mode = { n, x } }
    { "J", "6gj", mode = x }
    { "K", "6gk", mode = x }

kq -- SEARCH
""
    { "n", "n", desc = "Search next" }
    { "N", "N", desc = "Search previous" }
    { "\\", "<Esc>/\\%V", desc = "Search in sel", mode = x }
    { "<esc>", "<cmd>nohlsearch<cr><esc>", desc = "Escape and Clear hlsearch", mode = { n, i }, silent = true }

kq -- UNDO
""
    { "u", "<cmd>silent undo<CR>", desc = "Silent undo" }
    { "U", "<cmd>silent redo<CR>", desc = "Silent redo" }
    { "<LocalLeader>u", ":earlier ", desc = "Undo to earlier" }
    { "<LocalLeader>U", function() cmd.later(vim.o.undolevels) end, desc = "Redo all" }
    { "<leader>u", function() -- UNDO TREE
            if not package.loaded["undotree"] then
                    cmd.packadd "nvim.undotree"
            end
            require "undotree".open()
    end, desc = "Undo Tree" }

kq -- EDITING
""
    { "<", nano.toggleWordCasing, desc = "Toggle lower/Title case" }
    { ">", nano.camelSnakeToggle, desc = "Toggle camelCase and snake_case" }
    { "<C-w>", nano.smartDuplicate, desc = "Duplicate line", nowait = true }
    { "M", "<cmd>. move +1<CR>kJ", desc = "Merge line down" }
    { "~", "v~", desc = "Toggle char case (w/o moving)" }
    { "m", "J", desc = "Merge line up" }
    { "z.", "1z=", desc = "Fix spelling" }
    { "<C-Space>", '*N"_cgn', desc = "Repeatable edit (cword)", silent = true }
    { "zl", function() -- SPELL SUGGESTIONS
            local suggestions = fn.spellsuggest(fn.expand "<cword>")
            suggestions       = vim.list_slice(suggestions, 1, 9)
            ui.select(suggestions, { prompt = "Spelling suggestions" },
                      function(selection)
                              if not selection then return end
                              cmd.normal { '"_ciw' .. selection, bang = true }
                      end)
    end, desc = "Spell suggestions" }
    { "<C-Space>", function() -- REPEATABLE SELECTION EDIT,
            assert(fn.mode() == "v", "Only visual (character) mode.")
            local selection = fn.getregion(fn.getpos ".", fn.getpos "v")[1]
            fn.setreg("/", "\\V" .. fn.escape(selection, [[/\]]))
            return '<Esc>"_cgn'
    end, desc = "Repeatable edit (selection)", mode = x, expr = true }

kq "" { "X", function() -- DELETE AT EOL
        local updated_line = api.nvim_get_current_line():sub(1, -2)
        api.nvim_set_current_line(updated_line)
end, desc = "Delete char at EoL" }

iter { "(", ")", "[", "]", "{", "}", '"', "'", ",", ".", ";", ":", "\\", "?", "_" } -- APPEND TO EOL
    :each(function(_)
            kq "" { "<leader>" .. vim.trim(_), function()
                    local updated_line = api.nvim_get_current_line() .. _
                    api.nvim_set_current_line(updated_line)
            end }
    end)

kq "" { "<M-t>", function() -- TEMPLATE STRING
        require "functions.auto-template-str".insertTemplateStr()
end, desc = "Insert template string", mode = i }

kq -- INLINE CODE
""
    { "<M-`>", [[wBi`<Esc>ea`<Esc>b]], desc = "Inline Code cword" }
    { "<M-`>", "<Esc>`<i`<Esc>`>la`<Esc>", desc = "Inline Code selection", mode = x }
    { "<M-`>", "``<Left>", desc = "Inline Code", mode = i }

kq -- BLANK
""
    { "+", "[<Space>", desc = "blank above", remap = true }
    { "-", "]<Space>", desc = "blank below", remap = true }

kq -- YANK
""
    { "<C-y>", ":%y<CR>", desc = "Yank all", silent = true }
    { "y", function() -- STICKY
            b.preYankCursor = api.nvim_win_get_cursor(0)
            -- b.preYankCursor = vim.pos.cursor(0)
            return "y"
    end, mode = { n, x }, expr = true }
    { "Y", function() -- STICKY
            b.preYankCursor = api.nvim_win_get_cursor(0)
            -- b.preYankCursor = vim.pos.cursor(0)
            return "y$"
    end, expr = true, unique = false }

do -- YANKRING
        kq "" { "<M-p>", '"1p', desc = "Paste from yankring" }
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

-- { "d", '"_d', mode = { n, x } }
kq -- REGISTERS
""
    { "x", '"_x', mode = { n, x } }
    { "c", '"_c', mode = { n, x } }
    { "C", '"_C' }
    { "p", "P", mode = x }
    { "p", "]p", desc = "Paste & indent" }
    { "dd", function() -- DONT SAVE EMPTY LINES
            local line_empty = vim.trim(api.nvim_get_current_line()) == ""
            return (line_empty and '"_dd' or "dd")
    end, expr = true }

kq "" { "<C-p>", function() -- STICKY PASTE AT EOL
        local cur_line = api.nvim_get_current_line():gsub("%s*$", "")
        local reg      = vim.trim(fn.getreg "+")
        api.nvim_set_current_line(cur_line .. " " .. reg)
end, desc = "Sticky paste at EoL" }

kq "" { "<C-v>", function() -- PASTE CHARWISE
        local reg = vim.trim(fn.getreg "+"):gsub("\n%s*$", "\n")
        fn.setreg("+", reg, "v")
        return "<C-g>u<C-r><C-o>+"
end, desc = "Paste charwise", mode = i, expr = true }

kq -- TEXTOBJECTS
""
    { "J", "2j", mode = o }
    { "d<Space>", '"_daw', desc = "delete word", mode = n }

kq -- COMMENT OPERATOR
""
    { "q", "gc", desc = "Comment operator", mode = { n, x }, remap = true }
    { "qq", "gcc", desc = "Comment line", remap = true }
do -- MULTILINE COMMENT
        kq
        ""
            { "u", "gc", desc = "Multiline comment", mode = o, remap = true }
            { "guu", "guu" }
end
do -- COMMENTS
        kq
        ""
            { "Q", function() com.addComment "eol" end, desc = "Append Comment" }
            { "qo", function() com.addComment "below" end, desc = "Comment Below" }
            { "qO", function() com.addComment "above" end, desc = "Comment Above" }
            { "qe", function() com.commentHr() end, desc = "Horizontal Divider" }
            { "qw", function() com.commentHr "replaceMode" end, desc = "Horizontal Divider + Label" }
            { "qy", function() com.duplicateLineAsComment() end, desc = "Duplicate Line as Comment" }
        com.setupReplaceModeHelpersForComments()
end

kq "" { "i", function() -- INDENT I
        local line_empty = vim.trim(api.nvim_get_current_line()) == ""
        return line_empty and '"_cc' or "i"
end, desc = "indented i on empty line", expr = true }

kq -- VISUAL MODE
""
    { "<C-v>", "ggVG", desc = "select all" }
    { "V", "j", desc = "repeated `V` selects more lines", mode = x }
    { "v", "<C-v>", desc = "`vv` starts visual block", mode = x }

kq -- CMDZ
""
    { "<leader>r", ":luafile " .. fn.stdpath "config" .. "/" }
    { "<leader>l", ":livegrep " }
    { "<leader>f", ":find " }
    { "<leader>c", function()
            cmd "w"
            if vim.o.makeprg == "" or vim.o.makeprg == "make" then
                    local makeprg = fn.input "makeprg: "
                    api.nvim_set_option_value("makeprg", makeprg, { scope = "global" })
                    cmd "silent make!"
            end
            cmd "silent make!"
    end }
    { "<leader>C", function()
            local makeprg = fn.input "makeprg: "
            api.nvim_set_option_value("makeprg", makeprg, { scope = "global" })
            if makeprg then cmd "silent make!" end
    end }

kq -- CMDLINE
""
    { "<M-left>", "<C-b>", desc = "Goto start of cmdline", mode = c }
    { "<M-right>", "<C-e>", desc = "Goto end of cmdline", mode = c }
    { "<up>", "<C-p>", desc = "Cmdline completion scroll up", mode = c }
    { "<down>", "<C-n>", desc = "Cmdline completion scroll down", mode = c }
    { "<left>", "<Space><BS><Left>", desc = "Cmdline move left", mode = c, unique = true }
    { "<right>", "<Space><BS><Right>", desc = "Cmdline move right", mode = c, unique = true }

kq -- CMD EDIT
""
    { "<C-v>", function() -- PASTE CMDLINE
            fn.setreg("+", vim.trim(fn.getreg "+"))
            return "<C-r>+"
    end, desc = "Cmdline Paste", mode = c, expr = true }
    { "<M-c>", function() -- YANK CMDLINE
            local cmdline = fn.getcmdline()
            if cmdline == "" then return vim.notify("Nothing to copy.", levels.WARN) end
            fn.setreg("+", cmdline)
            vim.notify(cmdline, nil, { title = "Copied" })
    end, desc = "Yank cmdline", mode = c }
    { "<BS>", function() -- DISABLE BS ON EMPTY CMDLINE
            if fn.getcmdline() ~= "" then return "<BS>" end
    end, desc = "disable <BS> when cmdline is empty", mode = c, expr = true, unique = false }

kq -- CMD SPLIT
""
    { "<c-l>", function() return spltis "vertical" end, mode = c, expr = true }
    { "<c-j>", function() return spltis "horizontal" end, mode = c, expr = true }
    { "<c-CR>", function() return spltis "tab" end, mode = c, expr = true }

kq "" { "<M-Esc>", "<C-\\><C-n>", mode = "t" }
do -- TOGGLE TERMINAL
        local function toggle(key, h, w)
                return function()
                        match(bo.buftype) {
                                terminal = function() return cmd "bwipeout!" end,
                                _        = function()
                                        where(function(_)
                                                cmd(_.split[1])
                                                cmd "term"
                                                api["nvim_win_set_" .. _.split[2]](0, _.split[3])
                                        end) {
                                                    split = match(key) {
                                                            [_lower()] = { "new", "height", math.floor(vim.o.lines * (h or 50) * 0.01) },
                                                            [_upper()] = { "vnew", "width", math.floor(vim.o.columns * (w or 50) * 0.01) },
                                                    },
                                            }
                                end,
                        }
                end
        end
        iter { "t", "T" }:each(function(_) kq "" { "<leader>" .. _, toggle(_, 30, 30), desc = "Toggle terminal" } end)
end

kq -- INSPECT
""
    { "<leader>ii", "<cmd>Inspect<CR>", desc = "Inspect at cursor" }
    { "<leader>it", ts.inspect_tree, desc = "TS tree" }
    { "<leader>iq", ts.query.edit, desc = "TS query" }
    { "<leader>in", eval.nodeAtCursor, desc = "Node at cursor" }
    { "<leader>ia", eval.inspectNodeAncestors, desc = "Node ancestors" }
    { "<leader>iL", function() cmd.edit(lsp.log.get_filename()) end, desc = "LSP log" }
    { "<leader>il", eval.lspCapabilities, desc = "LSP capabilities" }
    { "<leader>ib", eval.bufferInfo, desc = "Buffer info" }
    { "<leader><leader>x", eval.runFile, desc = "Run file" }
    { "<leader>ye", function() -- YANK LAST EX COMMAND
            local command    = vim.trim(fn.getreg ":")
            local last_excmd = command:gsub("^lua ", ""):gsub("^= ?", "")
            if last_excmd == "" then return vim.notify("Nothing to copy", levels.TRACE) end
            local syntax = vim.startswith(command, "lua") and "lua" or "vim"
            vim.notify(last_excmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
            fn.setreg("+", last_excmd)
    end, desc = "Yank last ex-cmd" }

kq -- EVAL
""
    { "<leader>ie", eval.evalNvimLua, desc = "Eval" }
    { "<CR>", eval.evalNvimLua, desc = "Eval", mode = x, ft = "lua" }
    { "<leader>id", function() -- NEXT DIAGNOSTIC
            vim.notify(vim.inspect(diag.get_next()), nil, { ft = "lua" })
    end, desc = "Next diagnostic" }
    { "<leader>iE", function() -- EVAL LUA EXPRESSION
            local selection = fn.mode() == "n" and "" or fn.getregion(fn.getpos ".", fn.getpos "v")[1]
            return ":lua  = " .. selection
    end, desc = "Eval lua expr", mode = { n, x }, expr = true }

kq -- WINDOW
""
    { "<M-Space>", "<C-w>w", desc = "Cycle windows" }
    { "<M-m>", "<cmd>vsplit<CR>", desc = "Split altfile" }
    { "<M-n>", "<cmd>vertical split #<CR>", desc = "Split altfile" }
    { "<M-W>", "<cmd>only<CR>", desc = "Close other windows" }
    { "<C-n>", "<cmd>messages<CR>", desc = "Notification History" }

kq -- BUFFER
""
    { "<M-r>", cmd.edit, desc = "Reload buffer" }
    { "<M-w>", function() -- DELETE WINDOW/BUFFER
            cmd "silent! update"
            if bo.buftype == "terminal" then
                    cmd "bwipeout!"
                    return
            end
            local win_closed = pcall(cmd.close)
            if win_closed then return end
            local buf_count = #fn.getbufinfo { buflisted = 1 }
            if buf_count == 1 then
                    return vim.notify("Only one buffer open", levels.WARN)
            end
            cmd "bdelete"
    end, desc = "Close window/buffer" }
    { "H", function() -- PREVIOUS BUFFER
            if bo.buftype ~= "" then return end
            cmd.bprevious()
    end, desc = "Prev Buffer" }
    { "L", function() -- NEXT BUFFER
            if bo.buftype ~= "" then return end
            cmd.bnext()
    end, desc = "Next Buffer" }

kq -- MULTICURSOR
""
    { "<M-i>", "]C" }
    { "<M-I>", "[C" }
    { "<C-g>", "g<C-A>" }
    { "*", "Q*q=", unique = false }
    { "#", "Q#q=", unique = false }
    { "<LocalLeader><LocalLeader>", "q=" }
    { "<C-c>", function() api.nvim_buf_clear_namespace(0, api.nvim_create_namespace "nvim.multicursor", 0, -1) end, mode = { n, x } }
    { "<C-q>", function()
            local m = api.nvim_win_get_cursor(0)
            api.nvim_mcursor(0, { m[1], m[2] })
    end, mode = { n, v } }
    { "<M-y>", function()
            local m = api.nvim_win_get_cursor(0)
            api.nvim_mcursor(0, { m[1], m[2] })
            api.nvim_win_set_cursor(0, { m[1] + 1, m[2] })
    end }
    { "<M-Y>", "[CQ" }

where(function(_) -- MACROS
        fn.setreg(_.reg, "")
        kq
        ""
            { _.toggle, function() nano.startOrStopRecording(_.toggle, _.reg) end, desc = "Start/stop recording" }
            { "9", function() nano.playRecording(_.reg) end, desc = "Play recording" }
            { _.edit, function() nano.editMacro(_.reg) end, desc = "Edit recording" }
end) {
            reg    = "r",
            edit   = "1",
            toggle = "0",
    }

kq -- REFACTORING
""
    { "<leader>fd", ":global //d<Left><Left>", desc = "delete matching lines" }
    { "<LocalLeader>n", lsp.buf.rename, desc = "LSP rename" }
    { "<LocalLeader>m", nano.camelSnakeLspRename, desc = "LSP rename: camel/snake" }

kq -- TOGGLE
""
    { "<leader>oc", Toggle.concealLvl, desc = "Toggle Conceal" }
    { "<leader>o<leader>", Toggle.all, desc = "Toggle UI" }
