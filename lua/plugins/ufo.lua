local mode = { "n", "x", "o", "v" }

function cmd()
        vim.cmd.normal("^zz")
end

return {
        "kevinhwang91/nvim-ufo",
        lazy         = false,
        dependencies = "kevinhwang91/promise-async",
        keys         = {
                { "<leader>if", function() require("ufo").inspect() end, desc = " Fold Info" },
                { -- 0
                        "<A-0>",
                        function() require("ufo").closeFoldsWith(0) end,
                        mode = mode,
                        desc = " Close L0 Folds",
                },
                { -- 1
                        "<A-1>",
                        function() require("ufo").closeFoldsWith(1) end,
                        mode = mode,
                        desc = "d Close L1 Folds",
                },
                { -- 2
                        "<A-2>",
                        function() require("ufo").closeFoldsWith(2) end,
                        mode = mode,
                        desc = " Close L2 Folds",
                },
                { -- 3
                        "<A-3>",
                        function() require("ufo").closeFoldsWith(3) end,
                        mode = mode,
                        desc = " Close L3 Folds",
                },
                { -- 4
                        "<A-4>",
                        function() require("ufo").closeFoldsWith(4) end,
                        mode = mode,
                        desc = " Close L4 Folds",
                },
                { -- 5
                        "<A-5>",
                        function() require("ufo").closeFoldsWith(5) end,
                        mode = mode,
                        desc = " Close L5 Folds",
                },
                { -- 6
                        "<A-6>",
                        function() require("ufo").closeFoldsWith(6) end,
                        mode = mode,
                        desc = " Close L5 Folds",
                },
                { -- CLOSE ALL FOLDS
                        "<A-C-Left>",
                        function() require("ufo").closeAllFolds() end,
                        mode = mode,
                        desc = " Close L5 Folds",
                },
                { -- OPEN ALL FOLDS
                        "<A-C-Right>",
                        function() require("ufo").openAllFolds() end,
                        mode = mode,
                        desc = " Close L5 Folds",
                },
                { -- GOTO PREVIOUS FOLD START
                        "<A-Up>",
                        function() require("ufo").goPreviousStartFold() end,
                        mode = mode,
                        desc = " Goto Previous Fold",
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
