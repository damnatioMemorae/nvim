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

local com  = require("functions.comment")
local eval = require("functions.inspect-and-eval")
local nano = require("functions.nano-plugins")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function pcmd(command, fallback)
        local success = pcall(cmd, command) ---@diagnostic disable-line: param-type-mismatch
        if not success then
                cmd(fallback)
        end
end

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

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local K = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

K.Meta       = {
        { "<LocalLeader>k", "<cmd>help!<CR>",                           desc = "Help",          mode = { n, x } },
        { "<leader>R",      cmd.restart,                                desc = "Restart TUI" },
        { "<C-s>",          cmd.write,                                  desc = "Save File" },
        { "ZZ",             function() cmd("qa") end,                   desc = "Quit" },
        { "<leader>pd",     function() ui.open(fn.stdpath("data")) end, desc = "Local data dir" },
        { "<leader>pD",     function() ui.open(fn.stdpath("log")) end,  desc = "Log dir" },
}
K.Navigation = {
        { "_", "0" },
        { "{", "{",   mode = { n, x }, silent = true },
        { "}", "}",   mode = { n, x }, silent = true },
        { "",  "{",   mode = { n, x }, silent = true },
        { "",  "}",   mode = { n, x }, silent = true },
        { "j", "gj",  mode = { n, x } },
        { "k", "gk",  mode = { n, x } },
        { "J", "6gj", mode = x },
        { "K", "6gk", mode = x },
}
K.Search     = {
        { "n",     "n",                        desc = "Search next" },
        { "N",     "N",                        desc = "Search previous" },
        { "\\",    "<Esc>/\\%V",               desc = "Search in sel",             mode = x },
        { "<esc>", "<cmd>nohlsearch<cr><esc>", desc = "Escape and Clear hlsearch", mode = { n, i }, silent = true },
}
K.Undo       = {
        { "u",              "<cmd>silent undo<CR>",                     desc = "Silent undo" },
        { "U",              "<cmd>silent redo<CR>",                     desc = "Silent redo" },
        { "<LocalLeader>u", ":earlier ",                                desc = "Undo to earlier" },
        { "<LocalLeader>U", function() cmd.later(vim.o.undolevels) end, desc = "Redo all" },
        { -- `spc-u` UNDO TREE
                "<leader>u",
                function()
                        if not package.loaded["undotree"] then
                                cmd.packadd("nvim.undotree")
                        end
                        require("undotree").open()
                end,
                desc = "Undo Tree",
        },
}
K.Editing    = {
        { "<",     nano.toggleWordCasing,  desc = "Toggle lower/Title case",         dotmap = true },
        { ">",     nano.camelSnakeToggle,  desc = "Toggle camelCase and snake_case", dotmap = true },
        { "<C-w>", nano.smartDuplicate,    desc = "Duplicate line",                  nowait = true },
        { "M",     "<cmd>. move +1<CR>kJ", desc = "Merge line down" },
        { "~",     "v~",                   desc = "Toggle char case (w/o moving)" },
        { "m",     "J",                    desc = "Merge line up" },
        { "z.",    "1z=",                  desc = "Fix spelling" },
        { -- `zl` SPELL SUGGESTIONS
                "zl",
                function()
                        local suggestions = fn.spellsuggest(fn.expand("<cword>"))
                        suggestions       = vim.list_slice(suggestions, 1, 9)
                        ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" },
                                  function(selection)
                                          if not selection then return end
                                          cmd.normal { '"_ciw' .. selection, bang = true }
                                  end)
                end,
                desc = "Spell suggestions",
        },
}

_G.smartMap({ -- `X` DELETE AT EOL
        "X",
        function()
                local updated_line = api.nvim_get_current_line():sub(1, -2)
                api.nvim_set_current_line(updated_line)
        end,
        desc   = "Delete char at EoL",
        dotmap = true,
})

-- Append to EoL
vim
           .iter({ ",", ")", ";", ".", '"', "'", " \\", " {", "?", "_" })
           :each(function(char)
                   _G.smartMap({
                           "<leader>" .. vim.trim(char),
                           function()
                                   local updated_line = api.nvim_get_current_line() .. char
                                   api.nvim_set_current_line(updated_line)
                           end,
                           dotmap = true,
                   })
           end)
_G.smartMap({ -- `M-t` TEMPLATE STRING
        "<M-t>",
        function() require("functions.auto-template-str").insertTemplateStr() end,
        desc = "Insert template string",
        mode = i,
})

K.Repeatable = {
        { "<C-Space>", '*N"_cgn', desc = "Repeatable edit (cword)", silent = true },
        { -- `C-spc` REPEATABLE SELECTION EDIT,
                "<C-Space>",
                function()
                        assert(fn.mode() == "v", "Only visual (character) mode.")
                        local selection = fn.getregion(fn.getpos("."), fn.getpos("v"))[1]
                        fn.setreg("/", "\\V" .. fn.escape(selection, [[/\]]))
                        return '<Esc>"_cgn'
                end,
                desc = "Repeatable edit (selection)",
                mode = x,
                expr = true,
        },
}
K.Surround   = {
        { "<M-`>", [[wBi`<Esc>ea`<Esc>b]],     desc = "Inline Code cword" },
        { "<M-`>", "<Esc>`<i`<Esc>`>la`<Esc>", desc = "Inline Code selection", mode = x },
        { "<M-`>", "``<Left>",                 desc = "Inline Code",           mode = i },
}
K.Whitespace = {
        { "-", "[<Space>", desc = "blank above", remap = true, dotmap = true },
        { "=", "]<Space>", desc = "blank below", remap = true, dotmap = true },
}
K.Quickfix   = {
        { "[",  function() pcmd("cNfile", "clast") end,      desc = "Goto items",    nowait = true },
        { "]",  function() pcmd("cnfile", "cfirst") end,     desc = "Goto items",    nowait = true },
        { "(",  function() pcmd("cprev", "clast") end,       desc = "Goto previous", nowait = true },
        { ")",  function() pcmd("cnext", "cfirst") end,      desc = "Goto previous", nowait = true },
        { "qr", function() cmd.cexpr("[]") end,              desc = "Remove items" },
        { "qq", "<cmd>silent cfirst<CR>zv<cmd>wincmd p<CR>", desc = "Goto 1st",      ft = "qf" },
        { "Q",  "<cmd>silent clast<CR>zv<cmd>wincmd p<CR>",  desc = "Goto last",     ft = "qf" },
        { -- `spc-spc-q` TOGGLE QF WINDOW,
                "<leader>q",
                function()
                        local quickfix_win_open = fn.getqflist({ winid = true }).winid ~= 0
                        cmd(quickfix_win_open and "cclose" or "copen")
                end,
                desc = "Toggle quickfix window",
        },
}
K.Yank       = {
        { "<C-y>", ":%y<CR>", desc = "Yank all", silent = true },
        { -- STICKY
                "y",
                function()
                        b.preYankCursor = api.nvim_win_get_cursor(0)
                        return "y"
                end,
                mode = { n, x },
                expr = true,
        },
        { -- STICKY
                "Y",
                function()
                        b.preYankCursor = api.nvim_win_get_cursor(0)
                        return "y$"
                end,
                expr   = true,
                unique = false,
        },
}
K.Regclean   = {
        -- { "d", '"_d', mode  = { n, x } },
        { "x", '"_x', mode = { n, x } },
        { "c", '"_c', mode = { n, x } },
        { "C", '"_C' },
        { "p", "P",   mode = x },
        { -- `dd` DONT SAVE EMPTY LINES
                "dd",
                function()
                        local line_empty = vim.trim(api.nvim_get_current_line()) == ""
                        return (line_empty and '"_dd' or "dd")
                end,
                expr = true,
        },
}
K.Paste      = {
        { "p", "]p", desc = "Paste & indent" },
        { -- STICKY PASTE AT EOL
                "<C-p>",
                function()
                        local cur_line = api.nvim_get_current_line():gsub("%s*$", "")
                        local reg      = vim.trim(fn.getreg("+"))
                        api.nvim_set_current_line(cur_line .. " " .. reg)
                end,
                desc = "Sticky paste at EoL",
        },
        { -- PASTE CHARWISE
                "<C-v>",
                function()
                        local reg = vim.trim(fn.getreg("+")):gsub("\n%s*$", "\n")
                        fn.setreg("+", reg, "v")
                        return "<C-g>u<C-r><C-o>+"
                end,
                desc = "Paste charwise",
                mode = i,
                expr = true,
        },
}

do -- YANKRING
        _G.smartMap({ "<M-p>", '"1p', desc = "Paste from yankring" })

        api.nvim_create_autocmd("TextYankPost", {
                desc     = "User: Yankring",
                callback = function()
                        if vim.v.event.operator ~= "y" then
                                return
                        end
                        for a = 9, 1, -1 do
                                fn.setreg(tostring(a), fn.getreg(tostring(a - 1)))
                        end
                end,
        })
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
                   _G.smartMap({ "i" .. remap, "i" .. original, desc = "inner " .. label, mode = { o, x } })
                   _G.smartMap({ "a" .. remap, "a" .. original, desc = "outer " .. label, mode = { o, x } })
           end)

K.Special = {
        { "J",        "2j",    mode = o },
        { "d<Space>", '"_daw', desc = "delete word", mode = n },
}

do -- COMMENT
        K.Comments = {
                { "q",   "gc",                                        desc = "Comment operator",           mode = { n, x }, remap = true },
                { "qq",  "gcc",                                       desc = "Comment line",               remap = true },
                { "u",   "gc",                                        desc = "Multiline comment",          mode = o,        remap = true },
                { "guu", "guu" },

                { "qw",  function() com.commentHr("replaceMode") end, desc = "Horizontal Divider + Label", dotmap = true },
                { "qe",  function() com.commentHr() end,              desc = "Horizontal Divider",         dotmap = true },
                { "qy",  function() com.duplicateLineAsComment() end, desc = "Duplicate Line as Comment",  dotmap = true },
                { "Q",   function() com.addComment("eol") end,        desc = "Append Comment",             dotmap = true },
                { "qo",  function() com.addComment("below") end,      desc = "Comment Below",              dotmap = true },
                { "qO",  function() com.addComment("above") end,      desc = "Comment Above",              dotmap = true },
                { "dQ",  "<cmd>DeleteComments<CR>",                   desc = "Delete All Comments" },
        }
        com.setupReplaceModeHelpersForComments()
end

K.Insert  = {
        {
                "i",
                function()
                        local line_empty = vim.trim(api.nvim_get_current_line()) == ""
                        return line_empty and '"_cc' or "i"
                end,
                desc = "indented i on empty line",
                expr = true,
        },
}
K.Visual  = {
        { "<C-v>", "ggVG",  desc = "select all" },
        { "V",     "j",     desc = "repeated `V` selects more lines", mode = x },
        { "v",     "<C-v>", desc = "`vv` starts visual block",        mode = x },
}
K.Cmdline = {
        { "<C-a>",     "<C-b>", desc = "Goto start of cmdline", mode = c },
        { "<M-Left>",  "<C-b>", desc = "Goto start of cmdline", mode = c },
        { "<M-Right>", "<C-e>", desc = "Goto end of cmdline",   mode = c },
        { -- `C-v` PASTE CMDLINE
                "<C-v>",
                function()
                        fn.setreg("+", vim.trim(fn.getreg("+")))
                        return "<C-r>+"
                end,
                desc = "Cmdline Paste",
                mode = c,
                expr = true,
        },
        { -- `M-c` TANK CMDLINE
                "<M-c>",
                function()
                        local cmdline = fn.getcmdline()
                        if cmdline == "" then return vim.notify("Nothing to copy.", levels.WARN) end
                        fn.setreg("+", cmdline)
                        vim.notify(cmdline, nil, { title = "Copied", icon = "󰅍" })
                end,
                desc = "Yank cmdline",
                mode = c,
        },
        { -- `BS` DISABLE BS IN EMPTY CMDLINE
                "<BS>",
                function()
                        if fn.getcmdline() ~= "" then return "<BS>" end
                end,
                desc   = "disable <BS> when cmdline is empty",
                mode   = c,
                expr   = true,
                unique = false,
        },
}
K.Splits  = {
        { "<c-l>",  function() return spltis("vertical") end,   mode = c, expr = true },
        { "<c-j>",  function() return spltis("horizontal") end, mode = c, expr = true },
        { "<c-CR>", function() return spltis("tab") end,        mode = c, expr = true },
}
K.Inspect = {
        { "<leader>ii",        cmd.Inspect,                                     desc = "Inspect at cursor" },
        { "<leader>it",        ts.inspect_tree,                                 desc = "TS tree" },
        { "<leader>iq",        ts.query.edit,                                   desc = "TS query" },
        { "<leader>in",        eval.nodeAtCursor,                               desc = "Node at cursor" },
        { "<leader>ia",        eval.inspectNodeAncestors,                       desc = "Node ancestors" },
        { "<leader>iL",        function() cmd.edit(lsp.log.get_filename()) end, desc = "LSP log" },
        { "<leader>il",        eval.lspCapabilities,                            desc = "LSP capabilities" },
        { "<leader>ib",        eval.bufferInfo,                                 desc = "Buffer info" },
        { "<leader>ie",        eval.evalNvimLua,                                desc = "Eval",             mode = { n, x } },
        { "<leader><leader>x", eval.runFile,                                    desc = "Run file" },
        { -- `spc-y-e` YANK LAST EX COMMAND
                "<leader>ye",
                function()
                        local command    = vim.trim(fn.getreg(":"))
                        local last_excmd = command:gsub("^lua ", ""):gsub("^= ?", "")
                        if last_excmd == "" then return vim.notify("Nothing to copy", levels.TRACE) end
                        local syntax = vim.startswith(command, "lua") and "lua" or "vim"
                        vim.notify(last_excmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
                        fn.setreg("+", last_excmd)
                end,
                desc = "Yank last ex-cmd",
        },
}
K.Eval    = {
        { -- `spc-i-d` NEXT DIAGNOSTIC
                "<leader>id",
                function()
                        vim.notify(vim.inspect(diag.get_next()), nil, { ft = "lua" })
                end,
                desc = "Next diagnostic",
        },
        { -- `spc-E` EVLA LUA EXPRESSION
                "<leader>iE",
                function()
                        local selection = fn.mode() == "n" and "" or fn.getregion(fn.getpos("."), fn.getpos("v"))[1]
                        return ":lua  = " .. selection
                end,
                desc = "Eval lua expr",
                mode = { n, x },
                expr = true,
        },
}
K.Windows = {
        { "<M-Space>", "<C-w>w",                    desc = "Cycle windows",       mode = { n, v, i } },
        { "<M-m>",     "<cmd>vsplit<CR>",           desc = "Split altfile",       mode = { n, x, i } },
        { "<M-n>",     "<cmd>vertical split #<CR>", desc = "Split altfile",       mode = { n, x, i } },
        { "<C-n>",     "<cmd>messages<CR>",         desc = "Notification History" },
        { "<M-W>",     "<cmd>only<CR>",             desc = "Close other windows", mode = { n, x, i } },
}
K.Bufiles = {
        { "<M-r>", cmd.edit, desc = "Reload buffer" },
        { -- `M-w` DELETE WINDOW/BUFFER
                "<M-w>",
                function()
                        cmd("silent! update")
                        local win_closed = pcall(cmd.close)
                        if win_closed then
                                return
                        end
                        local buf_count = #fn.getbufinfo({ buflisted = 1 })
                        if buf_count == 1 then
                                return vim.notify("Only one buffer open.", levels.TRACE)
                        end
                        cmd.bdelete()
                end,
                desc = "Close window/buffer",
                mode = { n, i, x },
        },
        { -- `H` PREVIOUS BUFFER
                "H",
                function()
                        if bo.buftype ~= "" then return end
                        cmd.bprevious()
                end,
                desc = "Prev Buffer",
        },
        { -- `L` NEXT BUFFER
                "L",
                function()
                        if bo.buftype ~= "" then return end
                        cmd.bnext()
                end,
                desc = "Next Buffer",
        },
}

do -- MACRO
        local reg        = "r"
        local toggle_key = "0"

        fn.setreg(reg, "")

        K.Macro = {
                { toggle_key, function() nano.startOrStopRecording(toggle_key, reg) end, desc = "Start/stop recording" },
                { "9",        function() nano.playRecording(reg) end,                    desc = "Play recording" },
        }
end

K.Refatoring = {
        { "<leader>fd",     ":global //d<Left><Left>", desc = "delete matching lines" },
        { "<LocalLeader>n", lsp.buf.rename,            desc = "LSP rename" },
        { "<LocalLeader>m", nano.camelSnakeLspRename,  desc = "LSP rename: camel/snake", dotmap = true },
}
K.Options    = {
        { "<leader>oc",        Toggle.concealLvl, desc = "Toggle Conceal" },
        { "<leader>o<leader>", Toggle.all,        desc = "Toggle UI" },
}

vim
           .iter(K)
           :each(function(_, group)
                   vim
                              .iter(group)
                              :each(function(map)
                                      _G.smartMap(map)
                              end)
           end)
