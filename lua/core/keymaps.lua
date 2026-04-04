---@diagnostic disable: unused-local

local utils  = require("core.utils")
local nano   = require("functions.nano-plugins")
local eval   = require("functions.inspect-and-eval")
local map    = utils.uniqueKeymap
local prefix = Config.prefix

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
local opts  = { silent = true }

----META----------------------------------------------------------------------------------------------------------------

map(nx, prefix .. "k", "<cmd>help!<CR>", { desc = "󰝰 Help" })

map(n, "ZZ", "<cmd>qa<cr>", { desc = " Quit", silent = true })

local plugin_dir = vim.fn.stdpath("data") --[[@as string]]
map(n, "<leader>pd", function() vim.ui.open(plugin_dir) end, { desc = "󰝰 Plugin dir", silent = true })

map("n", "<C-,>", function()
            local path_of_this_lua_file = debug.getinfo(1, "S").source:gsub("^@", "")
            vim.cmd.edit(path_of_this_lua_file)
    end, { desc = "󰌌 Edit keybindings", unique = false })

----NAVIGATION----------------------------------------------------------------------------------------------------------

map(n, "_", "0")

map(nx, "{", "{zz", opts)
map(nx, "}", "}zz", opts)
map(nx, "(", "{zz", opts)
map(nx, ")", "}zz", opts)

-- j/k should on wrapped lines
map(nx, "j", "gj")
map(nx, "k", "gk")

-- make HJKL behave like hjkl but with bigger distance
map(x, "J", "6gj")
map(x, "K", "6gk")

-- Better scroll
map(n, "<C-d>", "<C-d>zz", opts)
map(n, "<C-u>", "<C-u>zz", opts)
map(n, "<C-f>", "<C-f>zz", opts)
map(n, "<C-b>", "<C-b>zz", opts)

-- Search
-- map(x,  "/",     fuzzySearch,                { desc = " Fuzzy search" })
map(x,  "\\",    "<Esc>/\\%V",               { desc = " Search in sel" })
map(n,  "n",     "nzz",                      { desc = "Search next", silent = true })
map(n,  "N",     "Nzz",                      { desc = "Search previous", silent = true })
map(ni, "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Escape and Clear hlsearch", silent = true })

-- Open first URL in file
map(n, "<A-x>", function()
            local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
            local url = text:match([[%l%l%l-://[^%s)"'`]+]])

            if url then
                    vim.ui.open(url)
            else
                    vim.notify("No URL found in file.", vim.log.levels.WARN)
            end
    end, { desc = " Open first URL in file", silent = true })

--[[ make `fF` use `nN` instead of `;,`
map(n, "f", function() nano.fF("f") end, { desc = "f", silent = true })
map(n, "F", function() nano.fF("F") end, { desc = "F", silent = true })
--]]

----EDITING-------------------------------------------------------------------------------------------------------------

-- Undo
map(n, "u",           "<cmd>silent undo<CR>zz",                       { desc = "󰜊 Silent undo", silent = true })
map(n, "U",           "<cmd>silent redo<CR>zz",                       { desc = "󰛒 Silent redo", silent = true })
map(n, "<leader>uu",  ":earlier ",                                    { desc = "󰜊 Undo to earlier", silent = true })
map(n, "<leader>ur",  function() vim.cmd.later(vim.o.undolevels) end, { desc = "󰛒 Redo all", silent = true })

-- Duplicate
map(n, "<C-w>", function() nano.smartDuplicate() end, { desc = "󰲢 Duplicate line", nowait = true, silent = true })

-- Toggles
map(n, "~", "v~",                                   { desc = "󰬴 Toggle char case (w/o moving)", silent = true })
map(n, "<", function() nano.toggleWordCasing() end, { desc = "󰬴 Toggle lower/Title case", silent = true })
map(n, ">", function() nano.camelSnakeToggle() end, { desc = "󰬴 Toggle camelCase and snake_case", silent = true })

-- Append to EoL
local trail_chars = { ",", ")", ";", ".", '"', "'", " \\", " {", "?" }
for _, chars in pairs(trail_chars) do
        map("n", "<leader>" .. vim.trim(chars), function()
                local updated_line = vim.api.nvim_get_current_line() .. chars
                vim.api.nvim_set_current_line(updated_line)
        end)
end

map("i", "<A-t>", function() require("functions.auto-template-str").insertTemplateStr() end,
    { desc = "󰅳 Insert template string" })

-- Repeatable edit
map("n", "<leader>j", '*N"_cgn', { desc = "󰆿 Repeatable edit (cword)" })
map("x", "<leader>j", function()
            assert(vim.fn.mode() == "v", "Only visual (character) mode.")
            local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
            vim.fn.setreg("/", "\\V" .. vim.fn.escape(selection, [[/\]]))
            return '<Esc>"_cgn'
    end, { desc = "󰆿 Repeatable edit (selection)", expr = true })

-- Whitespace
map(n, "<A-CR>", "O<Esc>j", { desc = " blank above", silent = true })
map(n, "<CR>",   "o<Esc>k", { desc = " blank below", silent = true })

-- Merging
map(n, "m", "J",                    { desc = "󰽜 Merge line up", silent = true })
map(n, "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down", silent = true }) -- `:move` preserves marks

-- Last line
map(n, "G", "Gzz", { desc = "Goto last line", silent = true })

-- Make file executable
map(n, "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable", silent = true })

-- Backspace in INSERT mode
map({ "i", "c" }, "<C-d>", "<Backspace>", { desc = "Delete", silent = true })

-- Save file
vim.keymap.del(i, "<C-s>")
map(n, "<C-s>", function() vim.cmd.write() end, { desc = "Save File", silent = true })

----SURROUND------------------------------------------------------------------------------------------------------------

map(n, "<A-`>", [[wBi`<Esc>ea`<Esc>b]],     { desc = " Inline Code cword", silent = true })
map(x, "<A-`>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline Code selection", silent = true })
map(i, "<A-`>", "``<Left>",                 { desc = " Inline Code", silent = true })

----QUICKFIX------------------------------------------------------------------------------------------------------------

map("n", "<leader><leader>q", function()
            local quickfix_win_open = vim.fn.getqflist({ winid = true }).winid ~= 0
            vim.cmd(quickfix_win_open and "cclose" or "copen")
    end, { desc = " Toggle quickfix window" })

--[[FOLDS---------------------------------------------------------------------------------------------------------------

map(nxvo, "<A-,>",       "zm^",    { desc = "Fold more", silent = true })
map(nxvo, "<A-.>",       "zr^",    { desc = "Reduce fold", silent = true })
map(nxvo, "<A-C-Left>",  "zM^",    { desc = "Close all folds", silent = true })
map(nxvo, "<A-C-Right>", "zR^",    { desc = "Open all folds", silent = true })
map(nxvo, "<A-Left>",    "zc^",    { desc = "Close current fold", silent = true })
map(nxvo, "<A-Right>",   "zo^",    { desc = "Open current fold", silent = true })
map(nxvo, "<A-Down>",    "zj^",    { desc = "Goto next fold", silent = true })
map(nxvo, "<A-Up>",      "zk^zz",  { desc = "Goto prev fold", silent = true })
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
        map({ "o", "x" }, "i" .. remap, "i" .. original, { desc = icon .. " inner " .. label })
        map({ "o", "x" }, "a" .. remap, "a" .. original, { desc = icon .. " outer " .. label })
end

-- Special remaps
map(o, "J",         "2j")
map(n, "<C-Space>", '"_ciw', { desc = "󰬞 change word", silent = true })
map(x, "<C-Space>", '"_c',   { desc = "󰒅 change selection", silent = true })
map(n, "<A-Space>", '"_daw', { desc = "󰬞 delete word", silent = true })
-- map(x, "<A-Space>", '"_d',   { desc = "󰬞 delete selection", silent = true })

----COMMENTS------------------------------------------------------------------------------------------------------------

map(nx, "q",  "zzgc",  { desc = "󰆈 Comment operator", remap = true, silent = true })
map(n,  "qq", "gcczz", { desc = "󰆈 Comment line", remap = true, silent = true })

do
        map(o, "u",   "gc",  { desc = "󰆈 Multiline comment", remap = true })
        map(n, "guu", "guu") -- prevent `omap u` above from overwriting `guu`
end

do
        local comment = require("functions.comment")
        map(n, "qw", function() comment.commentHr("replaceMode") end, { desc = "󰆈 Horizontal Divider + Label" })
        map(n, "qy", function() comment.duplicateLineAsComment() end, { desc = "󰆈 Duplicate Line as Comment" })
        map(n, "Q",  function() comment.addComment("eol") end,        { desc = "󰆈 Append Comment" })
        map(n, "qo", function() comment.addComment("below") end,      { desc = "󰆈 Comment Below" })
        map(n, "qO", function() comment.addComment("above") end,      { desc = "󰆈 Comment Above" })
        map(n, "dQ", function()
                    vim.cmd(("g/%s/d"):format(vim.fn.escape(vim.fn.substitute(vim.o.commentstring, "%s", "", "g"),
                                                            "/.*[]~")))
            end, { desc = "󰆈  Delete Comments" })
        comment.setupReplaceModeHelpersForComments()
end

----LSP-----------------------------------------------------------------------------------------------------------------

map(n, "<A-d>", function()
            vim.diagnostic.jump({ count = 1, float = false })
            vim.cmd.normal("zz")
    end, { desc = "■ Diagnostic Next" })
map(n, "<A-D>", function()
            vim.diagnostic.jump({ count = -1, float = false })
            vim.cmd.normal("zz")
    end, { desc = "■ Diagnostic Prev" })

map(n, "K", vim.lsp.buf.hover,          { desc = "󰏪 Hover Documentation", unique = false })
map(n, "J", vim.lsp.buf.signature_help, { desc = "󰏪 Signature Help" })

map(n, prefix .. "f", "gF",                    { desc = "Goto File", silent = true })
map(n, prefix .. "q", vim.lsp.buf.code_action, { desc = "󱠀 Code Action Picker" })

map("n", "<A-j>", function() nano.scrollLspOrOtherWin(5) end,  { desc = "↓ Scroll other win" })
map("n", "<A-K>", function() nano.scrollLspOrOtherWin(-5) end, { desc = "↑ Scroll other win" })

map(n, "<leader>k", function()
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
map(n, prefix .. "D", vim.lsp.buf.declaration,    { desc = " Goto Declaration" })
map(n, prefix .. "d", vim.lsp.buf.definition,     { desc = " Goto Definition" })
map(n, prefix .. "i", vim.lsp.buf.implementation, { desc = " Goto Implementation" })
map(n, prefix .. "r", vim.lsp.buf.references,     { desc = " Goto Implementation" })
map(n, prefix .. "I", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
map(n, prefix .. "c", vim.lsp.buf.code_action,    { desc = "󱠀 Code Action" })
map(n, prefix .. "F", vim.lsp.buf.format,         { desc = "LSP Format" })
--]]

----MODES---------------------------------------------------------------------------------------------------------------

-- INSERT
map(n, "i", function()
            local line_empty = vim.trim(vim.api.nvim_get_current_line()) == ""
            return line_empty and '"_cc' or "i"
    end, { expr = true, desc = "indented i on empty line", silent = true })

-- VISUAL
map(n, "<C-v>", "ggVG",  { desc = "select all", silent = true })
map(x, "V",     "j",     { desc = "repeated `V` selects more lines", silent = true })
map(x, "v",     "<C-v>", { desc = "`vv` starts visual block", silent = true })

-- CMDLINE
map("c", "<C-v>", function()
            vim.fn.setreg("+", vim.trim(vim.fn.getreg("+")))
            return "<C-r>+"
    end, { expr = true, desc = " Paste" })

map("c", "<A-c>", function()
            local cmdline = vim.fn.getcmdline()

            if cmdline == "" then
                    return vim.notify("Nothing to copy.", vim.log.levels.WARN)
            end

            vim.fn.setreg("+", cmdline)
            vim.notify(cmdline, nil, { title = "Copied", icon = "󰅍" })
    end, { desc = "󰅍 Yank cmdline" })

map("c", "<BS>", function()
            if vim.fn.getcmdline() ~= "" then
                    return "<BS>"
            end
    end, { expr = true, desc = "disable <BS> when cmdline is empty" })

map("c", "<C-a>",     "<C-b>", { desc = "Goto start of cmdline" })
map("c", "<A-Left>",  "<C-b>", { desc = "Goto start of cmdline" })
map("c", "<A-Right>", "<C-e>", { desc = "Goto end of cmdline" })

----INSPECT & EVAL------------------------------------------------------------------------------------------------------

map(n, "<leader>ii", vim.cmd.Inspect,             { desc = " Inspect at cursor" })
map(n, "<leader>it", vim.treesitter.inspect_tree, { desc = " TS tree" })
map(n, "<leader>iq", vim.treesitter.query.edit,   { desc = " TS query" })

map(n, "<leader>in", function() eval.nodeAtCursor() end,         { desc = " Node at cursor" })
map(n, "<leader>ia", function() eval.inspectNodeAncestors() end, { desc = " Node ancestors" })

map(n,  "<leader>ib",        function() eval.bufferInfo() end,      { desc = "󰽙 Buffer info" })
map(n,  "<leader>il",        function() eval.lspCapabilities() end, { desc = "󱈄 LSP capabilities" })
map(nx, "<leader>ie",        function() eval.evalNvimLua() end,     { desc = " Eval" })
map(n,  "<leader><leader>x", function() eval.runFile() end,         { desc = "󰜎 Run file" })

map(n, "<leader>id", function()
            local diag = vim.diagnostic.get_next()
            vim.notify(vim.inspect(diag), nil, { ft = "lua" })
    end, { desc = "󰋽 Next diagnostic" })

map(nx, "<leader>E", function()
            local selection = vim.fn.mode() == "n" and "" or vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
            return ":lua = " .. selection
    end, { expr = true, desc = "󰢱 Eval lua expr" })

map(n, "<leader>ye", function()
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

-- Split
map(n, "<A-->",      "<C-W>szz", { desc = "Split Window Below", silent = true })
map(n, "<A-Bslash>", "<C-W>vzz", { desc = "Split Window Right", silent = true })

-- Delete window/buffer
map(nix, "<A-w>", function()
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

map(n, "<A-r>", vim.cmd.edit,         { desc = "󰽙 Reload buffer", silent = true })
map(n, "H",     "<cmd>bprevious<cr>", { desc = "Prev Buffer", silent = true })
map(n, "L",     "<cmd>bnext<cr>",     { desc = "Next Buffer", silent = true })

----MACROS--------------------------------------------------------------------------------------------------------------

--[[
do
        local reg       = "r"
        local toggleKey = "0"
        map("n",
            toggleKey,
            function() nano.startOrStopRecording(toggleKey, reg) end,
            { desc = "󰃽 Start/stop recording",silent = true })
        -- stylua: ignore
        map(n, "c0", function() nano.editMacro(reg) end,
            { desc = "󰃽 Edit recording",silent = true })
        map(n, "9", "@" .. reg, { desc = "󰃽 Play recording",silent = true })
end
]]

----REFACTORING---------------------------------------------------------------------------------------------------------

map(n, "<leader>fd", ":global //d<Left><Left>", { desc = " delete matching lines" })

map(n, prefix .. "n", vim.lsp.buf.rename,                        { desc = "󰑕 LSP rename" })
map(n, prefix .. "m", function() nano.camelSnakeLspRename() end, { desc = "󰑕 LSP rename: camel/snake" })

map(nx, "<leader>qq", function()
            local line         = vim.api.nvim_get_current_line()
            local updated_line = line:gsub("[\"']", function(q) return (q == [["]] and [[']] or [["]]) end)
            vim.api.nvim_set_current_line(updated_line)
    end, { desc = " Switch quotes in line", silent = true })

---@param use "spaces"|"tabs"
local function retabber(use)
        vim.bo.expandtab  = use == "spaces"
        vim.bo.shiftwidth = 4
        vim.bo.tabstop    = 4
        vim.cmd.retab{ bang = true }
        vim.notify("Now using " .. use)
end
map(n, "<leader>f<Tab>",   function() retabber("tabs") end,   { desc = "󰌒 Use Tabs", silent = true })
map(n, "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use Spaces", silent = true })

----OPTION TOGGLING-----------------------------------------------------------------------------------------------------

local loaded, _ = pcall(require, "snacks")

if loaded then
        Snacks.toggle.option("relativenumber", { name = " Relative Line Number", global = true }):map("<leader>or")
        Snacks.toggle.option("number", { name = " Line Number", global = true }):map("<leader>on")
        Snacks.toggle.option("wrap", { name = "󰖶 Wrap", global = true }):map("<leader>ow")
        Snacks.toggle.treesitter({ name = " Treesitter Highlight" }):map("<leader>ot")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                   :map("<leader>oc")
end

map("n", "<leader>ol", function()
            local clients = vim.lsp.get_clients{ bufnr = 0 }
            local names   = vim.tbl_map(function(client) return client.name end, clients)
            local list    = "- " .. table.concat(names, "\n- ")
            vim.notify(list, nil, { title = "Restarting LSPs" })
            vim.lsp.enable(names, false)
            vim.lsp.enable(names, true)
    end, { desc = "󰑓 LSP restart" })

----RELOAD PLUGINS------------------------------------------------------------------------------------------------------

map(n, "<leader>lr", function()
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
    end, { desc = "Reload plugin", silent = true })
