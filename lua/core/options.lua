local misc   = Icon.Misc
local arrows = Icon.Arrows

local ui       = {
        o   = {
                laststatus    = 3,
                statusline    = "%v:lua.statusline()",
                cmdheight     = 0,
                showcmd       = false,
                showcmdloc    = "last",
                number        = true,
                pumheight     = 20,
                ruler         = false,
                winborder     = Border.Default.None,
                cursorline    = true,
                conceallevel  = 2,
                hlsearch      = false,
                smoothscroll  = true,
                termguicolors = true,
                winminwidth   = 5,
                inccommand    = "split",
                pumblend      = 0,
                shortmess     = "tF" .. "TIcC" .. "as" .. "WoO" .. "Sl",
                incsearch     = true,
                scrolloff     = 99,
                showmode      = false,
                sidescrolloff = 4,
                splitbelow    = true,
                splitright    = true,
                foldmarker    = "[[[,]]]",
        },
        opt = {
                guicursor = {
                        "n-v-c-sm:block-Cursor",
                        "i-ci-ve:ver25-Cursor",
                        "r-cr-o:hor20-Cursor",
                        "a:blinkwait500-blinkoff500-blinkon500",
                },
                fillchars = {
                        fold      = " ",
                        vert      = "│",
                        eob       = " ",
                        foldclose = arrows.close,
                        foldopen  = arrows.open,
                        foldsep   = "│",
                        foldinner =
                        " ",
                        diff      = "╱",
                },
                listchars = {
                        nbsp       = "_",
                        precedes   = misc.ellipsis,
                        extends    = misc.ellipsis,
                        multispace = " ",
                        lead       = " ",
                        trail      =
                        " ",
                        tab        = "  ",
                },
        },
}
local spell    = {
        opt = {
                spell        = false,
                spelllang    = "en_us",
                spelloptions = "noplainbuffer",
        },
}
local editor   = {
        o   = {
                backup         = false,
                swapfile       = false,
                writebackup    = false,
                clipboard      = "unnamedplus",
                completeopt    = "menu,menuone,noselect",
                ignorecase     = true,
                nrformats      = "bin,hex,blank,unsigned",
                smartcase      = true,
                startofline    = false,
                autowriteall   = false,
                autowrite      = false,
                confirm        = true,
                exrc           = true,
                grepformat     = "%f:%l:%c:%m",
                grepprg        = "rg --vimgrep",
                hidden         = true,
                jumpoptions    = "stack",
                linebreak      = false,
                list           = true,
                mouse          = "a",
                mousemoveevent = true,
                shell          = "zsh",
                termsync       = false,
                timeoutlen     = 500,
                undofile       = true,
                undolevels     = 10000,
                whichwrap      = "<>[]hl",
                wildmode       = "",
                wrap           = false,
                wrapmargin     = 120,
                updatetime     = 2000,
                redrawtime     = 2000,
        },
        opt = {
                formatoptions  = "",
                iskeyword      = vim.opt.iskeyword:append("@,48-57,_,-,192-255"),
                sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
        },
}
local tabspace = {
        o = {
                autoindent  = true,
                shiftround  = true,
                shiftwidth  = 8,
                tabstop     = 2,
                smartindent = true,
                breakindent = true,
                copyindent  = true,
                expandtab   = true,
                textwidth   = 120,
        },
}

---@type table<string, vim.Option>
return {
        ui       = ui,
        spell    = spell,
        editor   = editor,
        tabspace = tabspace,
}
