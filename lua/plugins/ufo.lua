local mode = { "n", "x", "o", "v" }
local lvl  = vim.v.count

return {
        "kevinhwang91/nvim-ufo",
        -- lazy         = false,
        dependencies = "kevinhwang91/promise-async",
        keys         = {
                { "<leader>if", function() require("ufo").inspect() end, desc = "Fold Info" },

                { -- REDUCE FOLD
                        "<A-,>",
                        function()
                                if lvl >= 0 then
                                        lvl = lvl - 1
                                else
                                        lvl = 0
                                end
                                require("ufo").closeFoldsWith(lvl)
                        end,
                        mode = mode,
                        desc = "Reduce Fold",
                },
                { -- FOLD MORE
                        "<A-.>",
                        function()
                                lvl = lvl + 1
                                if lvl >= 0 then
                                        require("ufo").closeFoldsWith(lvl)
                                end
                        end,
                        mode = mode,
                        desc = "Reduce Fold",
                },
                { -- CLOSE ALL FOLDS
                        "<A-C-Left>",
                        function() require("ufo").closeAllFolds() end,
                        mode = mode,
                        desc = "Close All Folds",
                },
                { -- OPEN ALL FOLDS
                        "<A-C-Right>",
                        function() require("ufo").openAllFolds() end,
                        mode = mode,
                        desc = "Open All Folds",
                },
                { -- CLOSE FOLD
                        "<A-Left>",
                        function() vim.cmd.normal("zc^") end,
                        mode = mode,
                        desc = "Close current fold",
                },
                { -- OPEN FOLD
                        "<A-Right>",
                        function() vim.cmd.normal("zo^") end,
                        mode = mode,
                        desc = "Open current fold",
                },
                { -- GOTO NEXT FOLD
                        "<A-Down>",
                        function() vim.cmd.normal("zj^") end,
                        mode = mode,
                        desc = "Goto next fold",
                },
                { -- GOTO PREV START
                        "<A-Up>",
                        function() require("ufo").goPreviousStartFold() end,
                        mode = mode,
                        desc = "Goto Previous Fold",
                },

                { -- 0
                        "<A-0>",
                        function() require("ufo").closeFoldsWith(0) end,
                        mode = mode,
                        desc = "Close L0 Folds",
                },
                { -- 1
                        "<A-1>",
                        function() require("ufo").closeFoldsWith(1) end,
                        mode = mode,
                        desc = "Close L1 Folds",
                },
                { -- 2
                        "<A-2>",
                        function() require("ufo").closeFoldsWith(2) end,
                        mode = mode,
                        desc = "Close L2 Folds",
                },
                { -- 3
                        "<A-3>",
                        function() require("ufo").closeFoldsWith(3) end,
                        mode = mode,
                        desc = "Close L3 Folds",
                },
                { -- 4
                        "<A-4>",
                        function() require("ufo").closeFoldsWith(4) end,
                        mode = mode,
                        desc = "Close L4 Folds",
                },
                { -- 5
                        "<A-5>",
                        function() require("ufo").closeFoldsWith(5) end,
                        mode = mode,
                        desc = "Close L5 Folds",
                },
                { -- 6
                        "<A-6>",
                        function() require("ufo").closeFoldsWith(6) end,
                        mode = mode,
                        desc = "Close L6 Folds",
                },
                { -- 7
                        "<A-7>",
                        function() require("ufo").closeFoldsWith(7) end,
                        mode = mode,
                        desc = "Close L7 Folds",
                },
                { -- 8
                        "<A-8>",
                        function() require("ufo").closeFoldsWith(8) end,
                        mode = mode,
                        desc = "Close L8 Folds",
                },
                { -- 9
                        "<A-9>",
                        function() require("ufo").closeFoldsWith(9) end,
                        mode = mode,
                        desc = "Close L9 Folds",
                },

                { -- FOLD PREVIEW
                        "K",
                        function()
                                local winid = require("ufo").peekFoldedLinesUnderCursor()
                                if not winid then vim.lsp.buf.hover() end
                        end,
                        desc = "Fold Preview",
                },
        },
        init         = function()
                vim.opt.foldcolumn     = "0"
                vim.opt.foldlevel      = 99
                vim.opt.foldlevelstart = 99
                vim.opt.foldenable     = false
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
