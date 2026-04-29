---@diagnostic disable: unused-local

local utils  = require("core.utils")
local nano   = require("functions.nano-plugins")
local eval   = require("functions.inspect-and-eval")
local keymap = utils.uniqueKeymap
local prefix = "<LocalLeader>"

local n, i, c, v, o, x, t = "n", "i", "c", "v", "o", "x", "t"

local ni    = { "n", "i" }
local nx    = { "n", "x" }
local nc    = { "n", "c" }
local nv    = { "n", "v" }
local no    = { "n", "o" }
local nix   = { "n", "i", "x" }
local nic   = { "n", "i", "c" }
local niv   = { "n", "i", "v" }
local nio   = { "n", "i", "o" }
local nxvo  = { "n", "x", "c", "v", "o" }
local nxcvo = { "n", "x", "c", "v", "o" }

----META----------------------------------------------------------------------------------------------------------------

keymap(nx, prefix .. "k", "<cmd>help!<CR>", { desc = "󰝰 Help" })

keymap(n, "<leader>R", "<cmd>rest<CR>", { desc = "Restart TUI" })

keymap(n, "ZZ", "<cmd>qa<cr>", { desc = " Quit" })

local plugin_dir = vim.fn.stdpath("data") --[[@as string]]
keymap(n, "<leader>pd", function() vim.ui.open(plugin_dir) end, { desc = "󰝰 Plugin dir" })

keymap(n, "<C-,>", function()
               local path_of_this_lua_file = debug.getinfo(1, "S").source:gsub("^@", "")
               vim.cmd.edit(path_of_this_lua_file)
       end, { desc = "󰌌 Edit keybindings", unique = false })

----NAVIGATION----------------------------------------------------------------------------------------------------------

keymap(n, "_", "0")

keymap(nx, "{", "{zz", { silent = true })
keymap(nx, "}", "}zz", { silent = true })
keymap(nx, "(", "{zz", { silent = true })
keymap(nx, ")", "}zz", { silent = true })

-- j/k should on wrapped lines
keymap(nx, "j", "gj")
keymap(nx, "k", "gk")

-- make HJKL behave like hjkl but with bigger distance
keymap(x, "J", "6gj")
keymap(x, "K", "6gk")

-- Better scroll
keymap(n, "<C-d>", "<C-d>zz", { silent = true })
keymap(n, "<C-u>", "<C-u>zz", { silent = true })
keymap(n, "<C-f>", "<C-f>zz", { silent = true })
keymap(n, "<C-b>", "<C-b>zz", { silent = true })

-- Search
-- map(x,  "/",     fuzzySearch,                { desc = " Fuzzy search" })
keymap(x,  "\\",    "<Esc>/\\%V",               { desc = " Search in sel" })
keymap(n,  "n",     "nzz",                      { desc = "Search next" })
keymap(n,  "N",     "Nzz",                      { desc = "Search previous" })
keymap(ni, "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Escape and Clear hlsearch", silent = true })

-- Open first URL in file
keymap(n, "<A-x>", function()
               local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
               local url = text:match([[%l%l%l-://[^%s)"'`]+]])

               if url then
                       vim.ui.open(url)
               else
                       vim.notify("No URL found in file.", vim.log.levels.WARN)
               end
       end, { desc = " Open first URL in file" })

--[[ make `fF` use `nN` instead of `;,`
map(n, "f", function() nano.fF("f") end, { desc = "f" })
map(n, "F", function() nano.fF("F") end, { desc = "F" })
--]]

----EDITING-------------------------------------------------------------------------------------------------------------

-- Undo
keymap(n, "<LocalLeader>u", "<cmd>Undotree<CR>",                            { desc = "󰜊 Uncotree" })
keymap(n, "u",              "<cmd>silent undo<CR>",                       { desc = "󰜊 Silent undo" })
keymap(n, "U",              "<cmd>silent redo<CR>",                       { desc = "󰛒 Silent redo" })
keymap(n, "<leader>uu",     ":earlier ",                                    { desc = "󰜊 Undo to earlier" })
keymap(n, "<leader>ur",     function() vim.cmd.later(vim.o.undolevels) end, { desc = "󰛒 Redo all" })

-- Duplicate line
keymap(n, "<C-w>", function() nano.smartDuplicate() end, { desc = "󰲢 Duplicate line", nowait = true })

-- Toggles
keymap(n, "~", "v~",                                   { desc = "󰬴 Toggle char case (w/o moving)" })
keymap(n, "<", function() nano.toggleWordCasing() end, { desc = "󰬴 Toggle lower/Title case" })
keymap(n, ">", function() nano.camelSnakeToggle() end, { desc = "󰬴 Toggle camelCase and snake_case" })

-- Append to EoL
local trail_chars = { ",", ")", ";", ".", '"', "'", " \\", " {", "?" }
for _, chars in pairs(trail_chars) do
        keymap("n", "<leader>" .. vim.trim(chars), function()
                -- local updated_line = vim.api.nvim_get_current_line() .. chars
                -- vim.api.nvim_set_current_line(updated_line)
                vim.cmd("normal A" .. chars)
                vim.cmd("normal ^")
        end)
end

keymap(i, "<A-t>", function() require("functions.auto-template-str").insertTemplateStr() end,
       { desc = "󰅳 Insert template string" })

-- Repeatable edit
keymap(n, "<leader>j", '*N"_cgn', { desc = "󰆿 Repeatable edit (cword)", silent = true })
keymap(x, "<leader>j", function()
               assert(vim.fn.mode() == "v", "Only visual (character) mode.")
               local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
               vim.fn.setreg("/", "\\V" .. vim.fn.escape(selection, [[/\]]))
               return '<Esc>"_cgn'
       end, { desc = "󰆿 Repeatable edit (selection)", expr = true })

-- Whitespace
keymap(n, "<A-CR>", "O<Esc>j^", { desc = " blank above" })
keymap(n, "<CR>",   "o<Esc>k^", { desc = " blank below" })

-- Merging
keymap(n, "m", "J",                    { desc = "󰽜 Merge line up" })
keymap(n, "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down" }) -- `:move` preserves marks

-- Last line
keymap(n, "G", "Gzz", { desc = "Goto last line" })

-- Make file executable
-- keymap(n, "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable" })

-- Backspace in INSERT mode
keymap({ "i", "c" }, "<C-d>", "<Backspace>", { desc = "Delete" })

-- Save file
keymap(n, "<C-s>", function() vim.cmd.write() end, { desc = "Save File" })

----SURROUND------------------------------------------------------------------------------------------------------------

keymap(i, "<",     "<>",                       { desc = " Inline Code cword" })
keymap(n, "<A-`>", [[wBi`<Esc>ea`<Esc>b]],     { desc = " Inline Code cword" })
keymap(x, "<A-`>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline Code selection" })
keymap(i, "<A-`>", "``<Left>",                 { desc = " Inline Code" })

----QUICKFIX------------------------------------------------------------------------------------------------------------

keymap(n, "<leader><leader>q", function()
               local quickfix_win_open = vim.fn.getqflist({ winid = true }).winid ~= 0
               vim.cmd(quickfix_win_open and "cclose" or "copen")
       end, { desc = " Toggle quickfix window" })

--[[FOLDS---------------------------------------------------------------------------------------------------------------

keymap(nxvo, "<A-,>",       "zm^",    { desc = "Fold more", })
keymap(nxvo, "<A-.>",       "zr^",    { desc = "Reduce fold", })
keymap(nxvo, "<A-C-Left>",  "zM^",    { desc = "Close all folds", })
keymap(nxvo, "<A-C-Right>", "zR^",    { desc = "Open all folds", })
keymap(nxvo, "<A-Left>",    "zc^",    { desc = "Close current fold", })
keymap(nxvo, "<A-Right>",   "zo^",    { desc = "Open current fold", })
keymap(nxvo, "<A-Down>",    "zj^",    { desc = "Goto next fold", })
keymap(nxvo, "<A-Up>",      "zk^zz",  { desc = "Goto prev fold", })
--]]

----TEXTOBJECTS---------------------------------------------------------------------------------------------------------

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
        keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = icon .. " inner " .. label })
        keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = icon .. " outer " .. label })
end

-- Special remaps
keymap(o, "J",         "2j")
keymap(n, "<C-Space>", '"_ciw', { desc = "󰬞 change word" })
keymap(x, "<C-Space>", '"_c',   { desc = "󰒅 change selection" })
keymap(n, "<A-Space>", '"_daw', { desc = "󰬞 delete word" })
-- map(x, "<A-Space>", '"_d',   { desc = "󰬞 delete selection" })

----COMMENTS------------------------------------------------------------------------------------------------------------

keymap(nx, "q",  "zzgc",  { desc = "󰆈 Comment operator", remap = true })
keymap(n,  "qq", "gcczz", { desc = "󰆈 Comment line", remap = true })

do
        keymap(o, "u",   "gc",  { desc = "󰆈 Multiline comment", remap = true })
        keymap(n, "guu", "guu") -- prevent `omap u` above from overwriting `guu`
end

do
        local comment = require("functions.comment")
        keymap(n, "qw", function() comment.commentHr("replaceMode") end, { desc = "󰆈 Horizontal Divider + Label" })
        keymap(n, "qy", function() comment.duplicateLineAsComment() end, { desc = "󰆈 Duplicate Line as Comment" })
        keymap(n, "Q",  function() comment.addComment("eol") end,        { desc = "󰆈 Append Comment" })
        keymap(n, "qo", function() comment.addComment("below") end,      { desc = "󰆈 Comment Below" })
        keymap(n, "qO", function() comment.addComment("above") end,      { desc = "󰆈 Comment Above" })
        keymap(n, "dQ", function()
                       vim.cmd(("g/%s/d"):format(vim.fn.escape(vim.fn.substitute(vim.o.commentstring, "%s", "", "g"),
                                                               "/.*[]~")))
               end, { desc = "󰆈  Delete Comments" })
        comment.setupReplaceModeHelpersForComments()
end

----LSP-----------------------------------------------------------------------------------------------------------------

keymap(nx, "<A-d>", function()
               vim.diagnostic.jump({ count = 1, float = false })
               vim.cmd.normal("zz")
       end, { desc = "■ Diagnostic Next" })
keymap(nx, "<A-D>", function()
               vim.diagnostic.jump({ count = -1, float = false })
               vim.cmd.normal("zz")
       end, { desc = "■ Diagnostic Prev" })

keymap(n, "K", vim.lsp.buf.hover,          { desc = "󰏪 Hover Documentation", unique = false })
keymap(n, "J", vim.lsp.buf.signature_help, { desc = "󰏪 Signature Help" })

keymap(n, prefix .. "f", "gF",  { desc = "LSP Goto File" })
keymap(n, prefix .. "t", "grt", { desc = "LSP Type Definition" })
-- keymap(n, prefix .. "x", "grt",                   { desc = "LSP Type Definition" })
keymap(n, prefix .. "q", vim.lsp.buf.code_action, { desc = "LSP Code Action Picker" })

keymap(n, "<A-j>", function() nano.scrollLspOrOtherWin(5) end,  { desc = "↓ Scroll other win" })
keymap(n, "<A-K>", function() nano.scrollLspOrOtherWin(-5) end, { desc = "↑ Scroll other win" })

-- vim.keymap.del("n", "<C-s>")
-- keymap(i, "<C-s>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

keymap(n, "<leader>k", function()
               vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })

               vim.api.nvim_create_autocmd("CursorMoved", {
                       group    = vim.api.nvim_create_augroup("line-diagnostics", { clear = true }),
                       callback = function()
                               vim.diagnostic.config({ virtual_lines = false, virtual_text = false })
                               return true
                       end,
               })
       end, { desc = "■ Diagnostic Lines" })

--[[ GOTO
keymap(n, prefix .. "D", vim.lsp.buf.declaration,    { desc = " Goto Declaration" })
keymap(n, prefix .. "d", vim.lsp.buf.definition,     { desc = " Goto Definition" })
keymap(n, prefix .. "i", vim.lsp.buf.implementation, { desc = " Goto Implementation" })
keymap(n, prefix .. "r", vim.lsp.buf.references,     { desc = " Goto Implementation" })
keymap(n, prefix .. "I", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
keymap(n, prefix .. "c", vim.lsp.buf.code_action,    { desc = "󱠀 Code Action" })
keymap(n, prefix .. "F", vim.lsp.buf.format,         { desc = "LSP Format" })
--]]

----MODES---------------------------------------------------------------------------------------------------------------

-- INSERT
keymap(n, "i", function()
               local line_empty = vim.trim(vim.api.nvim_get_current_line()) == ""
               return line_empty and '"_cc' or "i"
       end, { expr = true, desc = "indented i on empty line" })

-- VISUAL
keymap(n, "<C-v>", "ggVG",  { desc = "select all" })
keymap(x, "V",     "j",     { desc = "repeated `V` selects more lines" })
keymap(x, "v",     "<C-v>", { desc = "`vv` starts visual block" })

-- CMDLINE
keymap(c, "<C-v>", function()
               vim.fn.setreg("+", vim.trim(vim.fn.getreg("+")))
               return "<C-r>+"
       end, { expr = true, desc = " Paste" })

keymap(c, "<A-c>", function()
               local cmdline = vim.fn.getcmdline()

               if cmdline == "" then
                       return vim.notify("Nothing to copy.", vim.log.levels.WARN)
               end

               vim.fn.setreg("+", cmdline)
               vim.notify(cmdline, nil, { title = "Copied", icon = "󰅍" })
       end, { desc = "󰅍 Yank cmdline" })

keymap(c, "<BS>", function()
               if vim.fn.getcmdline() ~= "" then
                       return "<BS>"
               end
       end, { expr = true, desc = "disable <BS> when cmdline is empty" })

keymap(c, "<C-a>",     "<C-b>", { desc = "Goto start of cmdline" })
keymap(c, "<A-Left>",  "<C-b>", { desc = "Goto start of cmdline" })
keymap(c, "<A-Right>", "<C-e>", { desc = "Goto end of cmdline" })

----INSPECT & EVAL------------------------------------------------------------------------------------------------------

keymap(n, "<leader>ii", vim.cmd.Inspect,             { desc = " Inspect at cursor" })
keymap(n, "<leader>it", vim.treesitter.inspect_tree, { desc = " TS tree" })
keymap(n, "<leader>iq", vim.treesitter.query.edit,   { desc = " TS query" })

keymap(n, "<leader>in", function() eval.nodeAtCursor() end,         { desc = " Node at cursor" })
keymap(n, "<leader>ia", function() eval.inspectNodeAncestors() end, { desc = " Node ancestors" })

keymap(n,  "<leader>ib",        function() eval.bufferInfo() end,      { desc = "󰽙 Buffer info" })
keymap(n,  "<leader>il",        function() eval.lspCapabilities() end, { desc = "󱈄 LSP capabilities" })
keymap(nx, "<leader>ie",        function() eval.evalNvimLua() end,     { desc = " Eval" })
keymap(n,  "<leader><leader>x", function() eval.runFile() end,         { desc = "󰜎 Run file" })

keymap(n, "<leader>id", function()
               local diag = vim.diagnostic.get_next()
               vim.notify(vim.inspect(diag), nil, { ft = "lua" })
       end, { desc = "󰋽 Next diagnostic" })

keymap(nx, "<leader>E", function()
               local selection = vim.fn.mode() == "n" and "" or
                          vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
               return ":lua = " .. selection
       end, { expr = true, desc = "󰢱 Eval lua expr" })

keymap(n, "<leader>ye", function()
               local cmd        = vim.trim(vim.fn.getreg(":"))
               local last_excmd = cmd:gsub("^lua ", ""):gsub("^= ?", "")

               if last_excmd == "" then
                       return vim.notify("Nothing to copy", vim.log.levels.TRACE)
               end

               local syntax = vim.startswith(cmd, "lua") and "lua" or "vim"
               vim.notify(last_excmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
               vim.fn.setreg("+", last_excmd)
       end, { desc = " Yank last ex-cmd" })

----WINDOWS & BUFFERS---------------------------------------------------------------------------------------------------

keymap(n, "<C-n>", "<cmd>messages<CR>", { desc = "Notification History" })

-- Split
keymap(n, "<A-->",      "<C-W>szz", { desc = "Split Window Below" })
keymap(n, "<A-Bslash>", "<C-W>vzz", { desc = "Split Window Right" })

-- Delete window/buffer
keymap(nix, "<A-w>", function()
               vim.cmd("silent! update")

               local win_closed = pcall(vim.cmd.close)
               if win_closed then
                       return
               end

               local buf_count = #vim.fn.getbufinfo{ buflisted = 1 }
               if buf_count == 1 then
                       return vim.notify("Only one buffer open.", vim.log.levels.TRACE)
               end

               vim.cmd.bdelete()
       end, { desc = "󰽙 Close window/buffer" })

keymap(n, "<A-r>", vim.cmd.edit,         { desc = "Reload buffer" })
keymap(n, "H",     "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap(n, "L",     "<cmd>bnext<cr>",     { desc = "Next Buffer" })

--[[MACROS--------------------------------------------------------------------------------------------------------------

do
        local reg        = "r"
        local toggle_key = "0"

        vim.fn.setreg(reg, "")
        map("n", toggle_key, function() nano.startOrStopRecording(toggle_key, reg) end, { desc = "Start/stop recording" })
        map("n", "9",        function() nano.playRecording(reg) end,                    { desc = "Play recording" })
end
--]]

----REFACTORING---------------------------------------------------------------------------------------------------------

keymap(n, "<leader>fd", ":global //d<Left><Left>", { desc = " delete matching lines" })

keymap(n, prefix .. "n", vim.lsp.buf.rename,                        { desc = "LSP rename" })
keymap(n, prefix .. "m", function() nano.camelSnakeLspRename() end, { desc = "LSP rename: camel/snake" })

keymap(nx, "<leader>qq", function()
               local line         = vim.api.nvim_get_current_line()
               local updated_line = line:gsub("[\"']", function(q) return (q == [["]] and [[']] or [["]]) end)
               vim.api.nvim_set_current_line(updated_line)
       end, { desc = " Switch quotes in line" })

---@param use "spaces"|"tabs"
local function retabber(use)
        vim.bo.expandtab  = use == "spaces"
        vim.bo.shiftwidth = 4
        vim.bo.tabstop    = 4
        vim.cmd.retab{ bang = true }
        vim.notify("Now using " .. use)
end
keymap(n, "<leader>f<Tab>",   function() retabber("tabs") end,   { desc = "󰌒 Use Tabs" })
keymap(n, "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use Spaces" })

----OPTION TOGGLING-----------------------------------------------------------------------------------------------------

keymap(n, "<leader>ol", function()
               local clients = vim.lsp.get_clients{ bufnr = 0 }
               local names   = vim.tbl_map(function(client) return client.name end, clients)
               local list    = "- " .. table.concat(names, "\n- ")
               vim.notify(list, nil, { title = "Restarting LSPs" })
               vim.lsp.enable(names, false)
               vim.lsp.enable(names, true)
       end, { desc = "󰑓 LSP restart" })

keymap(n, "<leader>oc", function() Toggle.concealLvl() end, { desc = "󰈉 Conceal" })

----RELOAD PLUGINS------------------------------------------------------------------------------------------------------

keymap(n, "<leader>lr", function()
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
       end, { desc = "Reload plugin" })
