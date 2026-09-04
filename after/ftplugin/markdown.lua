local opt_l = vim.opt_local

local function md(_)
        return function(__)
                return function() return require "functions.md-tools"[_](__) end
        end
end
---- OPTIONS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

opt_l.shiftwidth     = 8
opt_l.tabstop        = 8
opt_l.commentstring  = "<!-- %s -->" -- add spaces
opt_l.number         = false
opt_l.relativenumber = false
opt_l.signcolumn     = "no"
opt_l.colorcolumn    = ""
opt_l.statuscolumn   = ""

-- so two trailing spaces are highlighted, but not a single trailing space
opt_l.listchars:remove "trail"
opt_l.listchars:append { multispace = "·" }
opt_l.conceallevel  = 2
opt_l.concealcursor = "n"

-- hard-wrap when typing beyond `textwidth`
vim.schedule(function() opt_l.formatoptions:append "t" end)

---- ABBREVIATIONS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

abbr "->" "→"

---- KEYMAPS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

bufq { "<leader>cu", md "addTitleToUrl" (), desc = "Add title to URL" }

bufq { "o", md "autoBullet" "o", desc = "Auto-bullet o" }
bufq { "O", md "autoBullet" "O", desc = "Auto-bullet O" }
bufq { "<CR>", md "autoBullet" "<CR>", mode = "i", desc = "Auto-bullet <CR>" }

-- bufq { "<C-Down>", "]]", desc = "Next heading", remap = true, silent = true }
-- bufq { "<C-Up>", "[[", desc = "Prev heading", remap = true, silent = true }

local mode = { "n", "x", "i" }
bufq { "<M-t>", md "cycle" "list", desc = "Cyclelist types", mode = mode }
bufq { "<C-a>", md "cycle" "task", desc = "Cycle  task states", mode = mode }
bufq { "<M-u>", md "wrap" "link", desc = "Link", mode = mode }
bufq { "<M-s>", md "wrap" "**", desc = "Bold", mode = mode }
bufq { "<M-i>", md "wrap" "_", desc = "Italic", mode = mode }
bufq { "<M-e>", md "wrap" "`", desc = "Inline code", mode = mode }
