local md    = require("functions.md-tools")
local map   = _G.bufMap
local opt_l = vim.opt_local

if vim.bo[vim.api.nvim_get_current_buf()].buftype == "help" then
        vim.opt_local.colorcolumn  = ""
        vim.opt_local.statuscolumn = ""
        vim.cmd("wincmd L")
        return
end

---- OPTIONS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

vim.opt_local.shiftwidth = 8
vim.opt_local.tabstop    = 8
opt_l.commentstring      = "<!-- %s -->" -- add spaces

-- so two trailing spaces are highlighted, but not a single trailing space
opt_l.listchars:remove("trail")
opt_l.listchars:append({ multispace = "·" })
opt_l.conceallevel  = 2
opt_l.concealcursor = "n"

-- hard-wrap when typing beyond `textwidth`
vim.schedule(function() opt_l.formatoptions:append("t") end)

---- ABBREVIATIONS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_G.bufAbbr("->", "→")

---- ADD TITLE TO URL ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "p",
        function()
                md.addTitleToUrlIfMarkdown("+")
                return "]p"
        end,
        desc = "Paste (+ add title if URL)",
        expr = true,
})
map({ "<leader>cu", md.addTitleToUrl, desc = "Add title to URL" })

---- AUTO-BULLET ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "o", function() md.autoBullet("o") end, desc = "Auto-bullet o" })
map({ "O", function() md.autoBullet("O") end, desc = "Auto-bullet O" })
map({ "<CR>", function() md.autoBullet("<CR>") end, mode = "i", desc = "Auto-bullet <CR>" })

---- FORMATTING ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<A-t>", function() md.cycle("list") end, mode = { "n", "x", "i" }, desc = "Cycle list types", dotmap = true })
map({ "<C-a>", function() md.cycle("task") end, mode = { "n", "x", "i" }, desc = "Cycle task states" })
map({ "<A-u>", function() md.wrap("mdlink") end, mode = { "n", "x", "i" }, desc = "Link" })
map({ "<A-s>", function() md.wrap("**") end, mode = { "n", "x", "i" }, desc = "Bold" })
map({ "<A-i>", function() md.wrap("_") end, mode = { "n", "x", "i" }, desc = "Italic" })
map({ "<A-e>", function() md.wrap("`") end, mode = { "n", "x", "i" }, desc = "Inline code" })

---- HEADINGS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({ "<C-j>", "]]", desc = "Next heading", remap = true, silent = true })
map({ "<C-k>", "[[", desc = "Prev heading", remap = true, silent = true })
map({ "<C-Down>", "]]", desc = "Next heading", remap = true, silent = true })
map({ "<C-Up>", "[[", desc = "Prev heading", remap = true, silent = true })
