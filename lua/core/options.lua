local opt = vim.opt
local o   = vim.o

------------------------------------------------------------------------------------------------------------------------
-- GENERAL

vim.schedule(function()
        o.clipboard = "unnamedplus"
end)

vim.cmd("filetype plugin indent on")
if vim.fn.exists("syntax_on") ~= 1 then
        vim.cmd("syntax enable")
end

opt.whichwrap:append("<>[]hl")
opt.iskeyword:append("@,48-57,_,-,192-255")
opt.spelloptions:append("noplainbuffer")

o.undofile      = true
o.undolevels    = 10000
o.swapfile      = false
o.backup        = false
o.writebackup   = false
o.spell         = false
o.spelllang     = "en_us"
o.splitright    = true
o.splitbelow    = true
o.cursorline    = true
o.signcolumn    = "yes"
o.wrap          = false
o.breakindent   = true
o.report        = 9901
o.autowrite     = false
o.autowriteall  = false
o.jumpoptions   = "view"
o.startofline   = true
o.scrolloff     = 20
o.sidescrolloff = 4
o.shortmess     = "ltToOCFIc"
-- o.messagesopt   = { "wait:0", "history:1000" }
o.nrformats     = "bin,hex,blank"

-- o.statuscolumn  = "%s%l%C"

------------------------------------------------------------------------------------------------------------------------
-- EDITOR

o.textwidth     = 120
o.expandtab     = true
-- o.tabstop = 3
o.shiftwidth    = 8
o.shiftround    = true
o.smartindent   = true
o.autoindent    = true
o.breakindent   = true
o.copyindent    = true
o.concealcursor = "nv"
o.formatoptions = ""
o.exrc          = true

------------------------------------------------------------------------------------------------------------------------
-- FILETYPES

vim.filetype.add{
        extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
        filename  = {
                [".ignore"] = "gitignore",
        },
        pattern   = {
                [".*/kitty/.+%.conf"] = "kitty",
                [".*/hypr/.+%.conf"]  = "hyprlang",
        },
}

------------------------------------------------------------------------------------------------------------------------
-- SEARCH & CMDLINE

o.ignorecase = true
o.smartcase  = true
o.hlsearch   = false
o.inccommand = "split"
o.cmdheight  = 0

------------------------------------------------------------------------------------------------------------------------
-- INVISIBLE CHARS

o.foldtext     = "v:lua.custom_foldtext()"
o.list         = true
o.conceallevel = 2

opt.fillchars:append{
        fold      = " ",
        vert      = "▕",
        eob       = " ",
        foldclose = Icons.Arrows.close,
        foldopen  = Icons.Arrows.open,
        foldsep   = "│",
        diff      = "╱",
}
opt.listchars = {
        nbsp       = " ",
        precedes   = Icons.Misc.ellipsis,
        extends    = Icons.Misc.ellipsis,
        multispace = " ",
        lead       = " ",
        trail      = " ",
        tab        = "  ",
}

o.winborder        = "none"
o.mousemoveevent   = true
o.completeopt      = "menu,menuone,noselect"
o.confirm          = true
o.grepformat       = "%f:%l:%c:%m"
o.grepprg          = "rg --vimgrep"
o.inccommand       = "nosplit"
o.incsearch        = true
o.linebreak        = false
o.list             = true
o.mouse            = "a"
o.number           = true
o.pumblend         = 0
o.pumheight        = 20
o.relativenumber   = true
-- o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
o.showmode         = false
o.termguicolors    = true
o.termsync         = false
o.updatetime       = 200
o.virtualedit      = "block"
o.wildmode         = ""
o.winminwidth      = 5
o.wrapmargin       = 120
o.smoothscroll     = true
o.hidden           = true

---[[
vim.api.nvim_create_autocmd("BufEnter", {
        pattern  = "*",
        callback = function()
                for _, plugin in pairs({
                        "netrwFileHandler",
                        "getscript",
                        "getscriptPlugin",
                        "vimball",
                        "vimballPlugin",
                        "2html_plugin",
                        "logipat",
                        "rrhelper",
                        "spellfile_plugin",
                        "matchit",
                        "matchParen",
                }) do
                        vim.g["loaded_" .. plugin] = 1
                end
        end,
})
--]]

local function fold_virt_text(result, s, lnum, coloff)
        if not coloff then
                coloff = 0
        end
        local text = ""
        local hl
        for i = 1, #s do
                local char = s:sub(i, i)
                local hls  = vim.treesitter.get_captures_at_pos(0, lnum, coloff + i - 1)
                local _hl  = hls[#hls]
                if _hl then
                        -- local new_hl = "@" .. _hl.capture
                        local new_hl = "LspInlayHint"
                        if new_hl ~= hl then
                                table.insert(result, { text, hl })
                                text = ""
                                hl   = nil
                        end
                        text = text .. char
                        hl   = new_hl
                else
                        text = text .. char
                end
        end
        table.insert(result, { text, hl })
end

function _G.custom_foldtext()
        local start   = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", o.tabstop))
        local end_str = vim.fn.getline(vim.v.foldend + 1)
        local end_    = vim.trim(end_str)
        local result  = {}
        fold_virt_text(result, start, vim.v.foldstart - 1)
        -- table.insert(result, { "...", "Comment" })
        table.insert(result, { "...", "LspInlayHint" })
        fold_virt_text(result, end_, vim.v.foldend - 1, #(end_str:match("^(%s+)") or ""))
        return result
end
