local arr  = Icons.Arrows
local misc = Icons.Misc
local opt  = vim.opt

vim.g.mapleader      = " "
vim.g.maplocalleader = ","

---- FILETYPES ---------------------------------------------------------------------------------------------------------

vim.filetype.add{
        extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
        filename  = { [".ignore"] = "gitignore" },
        pattern   = { [".*/kitty/.+%.conf"] = "kitty", [".*/hypr/.+%.conf"] = "hyprlang" },
}

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
                }) do
                        vim.g["loaded_" .. plugin] = 1
                end
        end,
})

local cursor = {
        "n-v-c-sm:block-Cursor",
        "i-ci-ve:ver25-Cursor",
        "r-cr-o:hor20-Cursor",
        "a:blinkwait500-blinkoff500-blinkon500",
}

---- GENERAL -----------------------------------------------------------------------------------------------------------
opt.autowriteall   = false
opt.autowrite      = false
opt.cmdheight      = 0
opt.concealcursor  = "n"
opt.conceallevel   = 2
opt.confirm        = true
opt.exrc           = true
opt.formatoptions  = ""
opt.grepformat     = "%f:%l:%c:%m"
opt.grepprg        = "rg --vimgrep"
opt.hidden         = true
opt.jumpoptions    = "stack"
opt.linebreak      = false
opt.list           = true
opt.mouse          = "a"
opt.mousemoveevent = true
opt.ruler          = false
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shell          = "bash"
opt.spell          = false
opt.spelllang      = "en_us"
opt.spelloptions   = "noplainbuffer"
opt.startofline    = true
opt.termsync       = false
opt.timeoutlen     = 500
opt.undofile       = true
opt.undolevels     = 10000
opt.whichwrap      = "<>[]hl"
opt.wildmode       = ""
opt.winborder      = Border.borderStyleNone
opt.winminwidth    = 5
opt.wrap           = false
opt.wrapmargin     = 120
opt.updatetime     = 2000
opt.redrawtime     = 2000

---- BACKUP ------------------------------------------------------------------------------------------------------------
opt.backup      = false
opt.swapfile    = false
opt.writebackup = false

---- LAYOUT ------------------------------------------------------------------------------------------------------------
opt.inccommand    = "nosplit"
opt.incsearch     = true
opt.pumheight     = 20
opt.scrolloff     = 20
opt.showmode      = false
opt.sidescrolloff = 4
opt.splitbelow    = true
opt.splitright    = true

---- EDIT --------------------------------------------------------------------------------------------------------------
opt.clipboard   = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.ignorecase  = true
opt.iskeyword   = opt.iskeyword:append("@,48-57,_,-,192-255")
opt.smartcase   = true

---- FOLD --------------------------------------------------------------------------------------------------------------
opt.list = true

---- UI ----------------------------------------------------------------------------------------------------------------
opt.cursorline    = true
opt.guicursor     = table.concat(cursor, ",")
opt.hlsearch      = false
opt.inccommand    = "split"
opt.nrformats     = "bin,hex,blank,unsigned"
opt.number        = true
opt.pumblend      = 0
opt.rnu           = true
opt.shortmess     = "tF" .. "TIcC" .. "as" .. "WoO" .. "Sl"
opt.showbreak     = " 󰘍 "
opt.smoothscroll  = true
opt.termguicolors = true
opt.fillchars     = {
        fold      = " ",
        vert      = "│",
        eob       = " ",
        foldclose = arr.close,
        foldopen  = arr.open,
        foldsep   = "│",
        foldinner =
        " ",
        diff      = "╱",
}
opt.listchars     = {
        nbsp       = "_",
        precedes   = misc.ellipsis,
        extends    = misc.ellipsis,
        multispace = " ",
        lead       = " ",
        trail      =
        " ",
        tab        = "  ",
}

---- TABSPACE ----------------------------------------------------------------------------------------------------------
opt.autoindent  = true
opt.breakindent = true
opt.copyindent  = true
opt.expandtab   = true
opt.shiftround  = true
opt.shiftwidth  = 8
opt.smartindent = true
opt.tabstop     = 2
opt.textwidth   = 120
