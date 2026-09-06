local misc   = Icon.Misc
local arrows = Icon.Arrows

---- UI ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

optq -- G
"g"
    { "backdrop", 60 }
    { "blend", 0 }
    { "winblend", 0 }
    { "conceal", true }

optq -- O
"o"
    { "laststatus", 3 }
    { "statusline", "%v:lua.statusline()" }
    { "cmdheight", 0 }
    { "cmdwinheight", 20 }
    { "showcmd", false }
    { "showcmdloc", "last" }
    { "number", true }
    { "relativenumber", true }
    { "pumheight", 20 }
    { "ruler", false }
    { "winborder", Border.Default.None }
    { "cursorline", true }
    { "conceallevel", 2 }
    { "hlsearch", false }
    { "smoothscroll", true }
    { "termguicolors", true }
    { "winminwidth", 5 }
    { "inccommand", "split" }
    { "pumblend", 0 }
    { "shortmess", "tF" .. "TIcC" .. "as" .. "WoO" .. "Sl" }
    { "incsearch", true }
    { "scrolloff", 99 }
    { "showmode", false }
    { "sidescrolloff", 4 }
    { "splitbelow", true }
    { "splitright", true }
    { "foldmarker", "[[[,]]]" }

optq -- OPT
"opt"
    { "guicursor", { "n-v-c-sm:block-Cursor", "i-ci-ve:ver25-Cursor", "r-cr-o:hor20-Cursor", "a:blinkwait500-blinkoff500-blinkon500" } }
    { "fillchars", {
            fold      = " ",
            vert      = "│",
            eob       = " ",
            foldclose = arrows.close,
            foldopen  = arrows.open,
            foldsep   = "│",
            foldinner = " ",
            diff      = "╱",
    } }
    { "listchars", {
            nbsp       = "_",
            precedes   = misc.ellipsis,
            extends    = misc.ellipsis,
            multispace = " ",
            lead       = " ",
            trail      = " ",
            tab        = "  ",
    } }

---- EDITOR --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

optq -- G
"g"
    { "projectsDir", vim.env.HOME .. "/deeznuts/" }
    { "localRepos", vim.fs.normalize "$HOME/deeznuts/" }
    { "codeLens", true }
    { "inlayHints", true }
    { "indentLines", true }

optq -- O
"o"
-- { "formatoptions", "jcoql" }
    { "autoread", true }
    { "makeprg", "" }
    { "backup", false }
    { "swapfile", false }
    { "writebackup", false }
    { "clipboard", "unnamedplus" }
    { "completeopt", "fuzzy,menu,menuone,noselect" }
    { "ignorecase", true }
    { "nrformats", "bin,hex,blank,unsigned" }
    { "smartcase", true }
    { "startofline", false }
    { "autowriteall", false }
    { "autowrite", false }
    { "confirm", true }
    { "exrc", true }
    { "grepformat", "%f:%l:%c:%m" }
    { "hidden", true }
    { "jumpoptions", "stack" }
    { "linebreak", false }
    { "list", true }
-- { "messagesopt", "history:500" }
    { "mouse", "a" }
    { "mousemoveevent", true }
    { "shell", "zsh" }
    { "termsync", false }
    { "timeoutlen", 500 }
    { "undofile", true }
    { "undolevels", 10000 }
    { "whichwrap", "<>[]hl" }
    { "wildmenu", true }
    { "wildmode", "noselect:longest" }
    { "wildoptions", "exacttext,fuzzy,pum" }
    { "wrap", false }
    { "wrapmargin", 120 }
    { "bufhidden", "wipe" }
    { "updatetime", 400 }
    { "redrawtime", 400 }

optq -- OPT
"opt"
-- { "formatoptions", vim.opt.formatoptions:remove { "c", "r", "o" } }
    { "iskeyword", vim.opt.iskeyword:append "@,48-57,_,-,192-255" }
    { "sessionoptions", { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" } }

---- SPELL ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

optq -- OPT
"opt"
    { "spell", false }
    { "spelllang", "en_us" }
    { "spelloptions", "noplainbuffer" }

---- TABSPACE ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

optq -- O
"o"
    { "autoindent", true }
    { "shiftround", true }
    { "shiftwidth", 8 }
    { "tabstop", 2 }
    { "smartindent", true }
    { "breakindent", true }
    { "copyindent", true }
    { "expandtab", true }
    { "textwidth", 120 }
