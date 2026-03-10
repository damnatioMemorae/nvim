---@diagnostic disable: unused-local

local utils    = require("core.utils")
local comments = require("functions.comment")
local nano     = require("functions.nano-plugins")
local eval     = require("functions.inspect-and-eval")
local map      = utils.uniqueKeymap
local prefix   = Config.prefix


local n, i, c, v, o, x, t = "n", "i", "c", "v", "o", "x", "t"

local ni    = { n, i }
local nx    = { n, x }
local nc    = { n, c }
local nv    = { n, v }
local no    = { n, o }
local nix   = { n, i, x }
local nic   = { n, i, c }
local niv   = { n, i, v }
local nio   = { n, i, o }
local nxvo  = { n, x, c, v, o }
local nxcvo = { n, x, c, v, o }
local opts  = { silent = true }

local function cmd()
        vim.cmd.normal("^zz")
end

------------------------------------------------------------------------------------------------------------------------
-- META

map(n, "ZZ", "<cmd>qa<cr>", { desc = " Quit", silent = true })

local pluginDir = vim.fn.stdpath("data") --[[@as string]]
map(n, "<leader>pd", function() vim.ui.open(pluginDir) end, { desc = "󰝰 Plugin dir", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- NAVIGATION

map(n, "_", "0")

map(nx, "{", "{zz", opts)
map(nx, "}", "}zz", opts)
map(nx, "(", "{zz", opts)
map(nx, ")", "}zz", opts)

-- j/k should on wrapped lines
map(nx, "j", "gj")
map(nx, "k", "gk")

-- hjkl in INSERT mode
map(i, "<C-h>", "<Left>",  opts)
map(i, "<C-j>", "<Down>",  opts)
map(i, "<C-k>", "<Up>",    opts)
map(i, "<C-l>", "<Right>", opts)

-- Better scroll
map(n, "<C-d>", "<C-d>zz", opts)
map(n, "<C-u>", "<C-u>zz", opts)
map(n, "<C-f>", "<C-f>zz", opts)
map(n, "<C-b>", "<C-b>zz", opts)

-- Search
-- map(x,  "/",     fuzzySearch,                { desc = " Search in sel" })
map(x,  "-",     "<Esc>/\\%V",               { desc = " Search in sel" })
map(n,  "n",     "nzz",                      { desc = "Search next", silent = true })
map(n,  "N",     "Nzz",                      { desc = "Search previous", silent = true })
map(ni, "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Escape and Clear hlsearch", silent = true })

-- Goto matching parenthesis (`remap` needed to use builtin `MatchIt` plugin)
map(n, "gm", "%zz", { desc = "󰅪 Goto match", remap = true, silent = true })
map(n, "%",  "%zz", { desc = "󰅪 Goto match", remap = true, silent = true })

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

-- make `fF` use `nN` instead of `;,`
map(n, "f", function() nano.fF("f") end, { desc = "f", silent = true })
map(n, "F", function() nano.fF("F") end, { desc = "F", silent = true })

------------------------------------------------------------------------------------------------------------------------
---[[ FOLDS

map(nxvo, "<A-,>",       "zm", { desc = "Fold more", silent = true })
map(nxvo, "<A-.>",       "zr", { desc = "Reduce fold", silent = true })
map(nxvo, "<A-C-Left>",  "zM", { desc = "Close all folds", silent = true })
map(nxvo, "<A-C-Right>", "zR", { desc = "Open all folds", silent = true })
map(nxvo, "<A-Left>",    "zc", { desc = "Close current fold", silent = true })
map(nxvo, "<A-Right>",   "zo", { desc = "Open current fold", silent = true })
map(nxvo, "<A-Down>",    "zj", { desc = "Goto next fold", silent = true })
-- map(nxvo, "<A-Up>",      "zk^zz", { desc = "Goto prev fold", silent = true })
--]]

-- center Ctrl-o
map(n, "<C-o>", "<C-o>zz", opts)

------------------------------------------------------------------------------------------------------------------------
-- EDITING

-- Undo
map(n, "u",          "<cmd>silent undo<CR>zz",                       { desc = "󰜊 Silent undo", silent = true })
map(n, "U",          "<cmd>silent redo<CR>zz",                       { desc = "󰛒 Silent redo", silent = true })
map(n, "<leader>uu", ":earlier ",                                    { desc = "󰜊 Undo to earlier", silent = true })
map(n, "<leader>ur", function() vim.cmd.later(vim.o.undolevels) end, { desc = "󰛒 Redo all", silent = true })

-- Duplicate
map(n, "<C-w>", function() nano.smartDuplicate() end, { desc = "󰲢 Duplicate line", nowait = true, silent = true })

-- Toggles
map(n, "~", "v~",                                   { desc = "󰬴 Toggle char case (w/o moving)", silent = true })
map(n, "<", function() nano.toggleWordCasing() end, { desc = "󰬴 Toggle lower/Title case", silent = true })
map(n, ">", function() nano.camelSnakeToggle() end, { desc = "󰬴 Toggle camelCase and snake_case", silent = true })

-- Append to EoL
local trailChars = { ",", "\\", "[", "]", "{", "}", ")", ";", "." }
for _, key in pairs(trailChars) do
        local pad = key == "\\" and " " or ""
        map(n, "<leader>" .. key, ("mzA%s%s<Esc>`z"):format(pad, key), opts)
end

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
-- map(ni, "<C-s>", vim.cmd("write"), { desc = "Save File", silent = true })
map(n, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save File", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- SURROUND

map(n, "<A-`>", [[wBi`<Esc>ea`<Esc>b]],     { desc = " Inline Code cword", silent = true })
map(x, "<A-`>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline Code selection", silent = true })
map(i, "<A-`>", "``<Left>",                 { desc = " Inline Code", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- TEXTOBJECTS

local textobjRemaps = {
        { "c", "}", "", "curly" },
        { "r", "]", "󰅪", "rectangular" },
        { "m", "W", "󰬞", "WORD" },
        { "q", '"', "", "double" },
        { "z", "'", "", "single" },
        { "e", "`", "", "backtick" },
}
for _, value in pairs(textobjRemaps) do
        local remap, original, icon, label = unpack(value)
        map({ "o", "x" }, "i" .. remap, "i" .. original, { desc = icon .. " inner " .. label })
        map({ "o", "x" }, "a" .. remap, "a" .. original, { desc = icon .. " outer " .. label })
end

-- Special remaps
map(o, "J",         "2j")
map(n, "<C-Space>", '"_ciw', { desc = "󰬞 change word", silent = true })
map(x, "<C-Space>", '"_c',   { desc = "󰒅 change selection", silent = true })
map(n, "<A-Space>", '"_daw', { desc = "󰬞 delete word", silent = true })
map(x, "<A-Space>", '"_d',   { desc = "󰬞 delete selection", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- COMMENTS

map(nx, "q",  "^zzgc",  { desc = "󰆈 Comment operator", remap = true, silent = true })
map(n,  "qq", "gcc^zz", { desc = "󰆈 Comment line", remap = true, silent = true })

do
        map(o, "u",   "gc",  { desc = "󰆈 Multiline comment", remap = true })
        map(n, "guu", "guu") -- prevent `omap u` above from overwriting `guu`
end

map(n, "qw", function()
            comments.commentHr()
            cmd()
    end, { desc = "󰆈 Horizontal Divider", silent = true })
map(n, "qy", function()
            comments.duplicateLineAsComment()
            cmd()
    end, { desc = "󰆈 Duplicate Line as Comment", silent = true })
map(n, "Q", function()
            comments.addComment("eol")
            vim.cmd.normal("zz")
    end, { desc = "󰆈 Append Comment", silent = true })
map(n, "qo", function()
            comments.addComment("below")
            vim.cmd.normal("zz")
    end, { desc = "󰆈 Comment Below", silent = true })
map(n, "qO", function()
            comments.addComment("above")
            vim.cmd.normal("zz")
    end, { desc = "󰆈 Comment Above", silent = true })
map(n, "dQ", function()
            -- vim.cmd(("g/%s/d"):format(vim.fn.escape(vim.fn.substitute(vim.o.commentstring, "%s", "", "g"), "/.*[]~"),
            --                           cmd()))
            vim.cmd(("g/%s/d"):format(vim.fn.escape(vim.fn.substitute(vim.o.commentstring, "%s", "", "g"), "/.*[]~")))
    end, { desc = "󰆈  Delete Comments", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- LSP

map(n, "<A-d>", function()
            vim.diagnostic.jump({ count = 1, float = false })
            vim.cmd.normal("zz")
    end, { desc = "■ Diagnostic Next" })
map(n, "<A-D>", function()
            vim.diagnostic.jump({ count = -1, float = false })
            vim.cmd.normal("zz")
    end, { desc = "■ Diagnostic Prev" })

map(n, "K", vim.lsp.buf.hover,          { desc = "󰏪 Hover Documentation" })
map(n, "J", vim.lsp.buf.signature_help, { desc = "󰏪 Signature Help" })

map(n, prefix .. "f", "gF", { desc = "Goto File", silent = true })
-- map(n, prefix .. "q", vim.lsp.buf.code_action, { desc = "󱠀 Code Action Picker" })
map(n, prefix .. "q", function() require("tiny-code-action").code_action() end,
    { desc = "󱠀 Code Action Picker", remap = false, silent = true })
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

------------------------------------------------------------------------------------------------------------------------
-- INSERT MODE

map(n, "i", function()
            local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
            return (lineEmpty and [["_cc]] or "i")
    end, { expr = true, desc = "indented i on empty line", silent = true })

-- VISUAL MODE
map(n, "<C-v>", "ggVG",  { desc = "select all", silent = true })
map(x, "V",     "j",     { desc = "repeated `V` selects more lines", silent = true })
map(x, "v",     "<C-v>", { desc = "`vv` starts visual block", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- INSPECT & EVAL

map(n, "<leader>ih", vim.show_pos,                { desc = " Position at cursor", silent = true })
map(n, "<leader>it", vim.treesitter.inspect_tree, { desc = " TS tree", silent = true })
map(n, "<leader>iq", vim.treesitter.query.edit,   { desc = " TS query", silent = true })

map(n,  "<leader>il",        function() eval.lspCapabilities() end, { desc = "󱈄 LSP capabilities", silent = true })
map(n,  "<leader>in",        function() eval.nodeAtCursor() end,    { desc = " Node at cursor", silent = true })
map(n,  "<leader>ib",        function() eval.bufferInfo() end,      { desc = "󰽙 Buffer info", silent = true })
map(nx, "<leader>ie",        function() eval.evalNvimLua() end,     { desc = " Eval", silent = true })
map(n,  "<leader><leader>x", function() eval.runFile() end,         { desc = "󰜎 Run file", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- WINDOWS

-- Create split
map(n, "<A-w>",      "<C-W>czz", { desc = "Delete Window", silent = true })
map(n, "<A-->",      "<C-W>szz", { desc = "Split Window Below", silent = true })
map(n, "<A-Bslash>", "<C-W>vzz", { desc = "Split Window Right", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- BUFFERS & FILES

map(n, "<A-r>", vim.cmd.edit,         { desc = "󰽙 Reload buffer", silent = true })
map(n, "H",     "<cmd>bprevious<cr>", { desc = "Prev Buffer", silent = true })
map(n, "L",     "<cmd>bnext<cr>",     { desc = "Next Buffer", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- MACROS

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

------------------------------------------------------------------------------------------------------------------------
-- REFACTORING

map(n, "<leader>fd", ":global //d<Left><Left>", { desc = " delete matching lines", silent = true })

map(n, prefix .. "n", vim.lsp.buf.rename, { desc = "󰑕 LSP rename", silent = true })

map(n, prefix .. "m", function() nano.camelSnakeLspRename() end,
    { desc = "󰑕 LSP rename: camel/snake", silent = true })

map(nx, "<leader>qq", function()
            local line        = vim.api.nvim_get_current_line()
            local updatedLine = line:gsub("[\"']", function(q) return (q == [["]] and [[']] or [["]]) end)
            vim.api.nvim_set_current_line(updatedLine)
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

------------------------------------------------------------------------------------------------------------------------
-- OPTION TOGGLING

local loaded, _ = pcall(require, "snacks")

if loaded then
        Snacks.toggle.option("relativenumber", { name = " Relative Line Number", global = true }):map("<leader>or")
        Snacks.toggle.option("number", { name = " Line Number", global = true }):map("<leader>on")
        Snacks.toggle.option("wrap", { name = "󰖶 Wrap", global = true }):map("<leader>ow")
        Snacks.toggle.treesitter({ name = " Treesitter Highlight" }):map("<leader>ot")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                   :map("<leader>oc")
        Snacks.toggle.words():map("<leader>ol")
end

------------------------------------------------------------------------------------------------------------------------
-- RELOAD PLUGINS

map(n, "<leader>lr", function()
            local plugins      = require("lazy").plugins()
            local plugin_names = {}
            for _, plugin in ipairs(plugins) do
                    table.insert(plugin_names, plugin.name)
            end

            vim.ui.select(
                    plugin_names,
                    { title = "Reload plugin" },
                    function(selected)
                            require("lazy").reload({ plugins = { selected } })
                    end
            )
    end, { desc = "Reload plugin", silent = true })
