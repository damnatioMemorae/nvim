local mode = { "n", "x" }
function cmd()
        vim.cmd.normal("^zz")
end

return {
        "kevinhwang91/nvim-ufo",
        lazy         = false,
        dependencies = "kevinhwang91/promise-async",
        keys         = {
                { "<leader>if", function() require("ufo").inspect() end, cmd(), desc = " Fold Info" },
                { -- 0
                        "<A-0>",
                        function()
                                require("ufo").closeFoldsWith(0)
                                cmd()
                        end,
                        mode = mode,
                        desc = " Close L0 Folds",
                },
                { -- 1
                        "<A-1>",
                        function()
                                require("ufo").closeFoldsWith(1)
                                cmd()
                        end,
                        mode = mode,
                        desc = "d Close L1 Folds",
                },
                { -- 2
                        "<A-2>",
                        function()
                                require("ufo").closeFoldsWith(2)
                                cmd()
                        end,
                        mode = mode,
                        desc = " Close L2 Folds",
                },
                { -- 3
                        "<A-3>",
                        function()
                                require("ufo").closeFoldsWith(3)
                                cmd()
                        end,
                        mode = mode,
                        desc = " Close L3 Folds",
                },
                { -- 4
                        "<A-4>",
                        function()
                                require("ufo").closeFoldsWith(4)
                                cmd()
                        end,
                        mode = mode,
                        desc = " Close L4 Folds",
                },
                { -- 5
                        "<A-5>",
                        function()
                                require("ufo").closeFoldsWith(5)
                                cmd()
                        end,
                        mode = mode,
                        desc = " Close L5 Folds",
                },
                { -- 6
                        "<A-6>",
                        function()
                                require("ufo").closeFoldsWith(6)
                                cmd()
                        end,
                        mode = mode,
                        desc = " Close L5 Folds",
                },
                { -- CLOSE ALL FOLDS
                        "<A-H>",
                        "zM^zz",
                        mode = "n",
                        desc = " Close All Folds",
                },
                { -- OPEN ALL FOLDS
                        "<A-L>",
                        "zR^zz",
                        mode = "n",
                        desc = " Open All Folds",
                },
                { -- CLOSE FOLD
                        "<A-Left>",
                        "zc^zz",
                        mode = "n",
                        desc = "Close Fold",
                },
                { -- OPEN FOLD
                        "<A-Right>",
                        "zo^zz",
                        mode = "n",
                        desc = "Open Fold",
                },
                { -- FOLD MORE
                        "<A-,>",
                        "zm^zz",
                        mode = "n",
                        desc = "Close Fold",
                },
                { -- REDUCE FOLD
                        "<A-.>",
                        "zr^zz",
                        mode = "n",
                        desc = "Close Fold",
                },
                { -- GOTO PREVIOUS FOLD START
                        "<A-Up>",
                        function()
                                require("ufo").goPreviousStartFold()
                                cmd()
                        end,
                        mode = mode,
                        desc = " Goto Previous Fold",
                },
                { -- GOTO NEXT FOLD
                        "<A-Down>",
                        "zj^zz",
                        mode = mode,
                        desc = "Goto Next Fold",
                },
                { -- FOLD PREVIEW
                        "<A-p>",
                        function()
                                local winid = require("ufo").peekFoldedLinesUnderCursor()
                                if not winid then vim.lsp.buf.hover() end
                                cmd()
                        end,
                        desc = " Fold Preview",
                },
        },
        init         = function()
                vim.opt.foldcolumn     = "0"
                vim.opt.foldlevel      = 99
                vim.opt.foldlevelstart = 99
                vim.opt.foldenable     = true
        end,
        opts         = {
                open_fold_hl_timeout    = 0,
                close_fold_kinds_for_ft = {
                        cpp      = { "comment" },
                        c        = { "comment" },
                        default  = { "comment" },
                        json     = { "array" },
                        -- lua      = { "comment" },
                        lua      = {},
                        markdown = {},
                        python   = { "imports", "comment" },
                        sh       = { "imports", "comment" },
                        toml     = { "imports", "comment" },
                        zsh      = { "if_statement", "for_statement", "function_definition" },
                },
                preview                 = {
                        win_config = {
                                border       = Border.borderStyle,
                                winblend     = 0,
                                winhighlight = "NormalFloat:NormalFloat",
                        },
                },
                provider_selector       = function(_bufnr, ft, _buftype)
                        local lspWithOutFolding = { "markdown", "zsh", "bash", "css", "json" }
                        if vim.tbl_contains(lspWithOutFolding, ft) then
                                return { "treesitter", "indent" }
                        end
                        return { "treesitter", "indent" }
                end,
                fold_virt_text_handler  = function()
                        vim.wo.foldtext = [[
                                substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend))
                        ]]
                end,
        },
}
