local border = Border.Default.None

return {
        "ibhagwan/fzf-lua",
        enabled      = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys         = {
                { -- FILES
                        "<leader><leader>f",
                        function() require("fzf-lua").files() end,
                },
                { -- BUFFERS
                        "<leader><leader>b",
                        function() require("fzf-lua").buffers() end,
                },
                { -- GREP LIVE
                        "<leader><leader>w",
                        function() require("fzf-lua").live_grep() end,
                },
                { -- GREP WORDS
                        "<leader><leader>W",
                        function() require("fzf-lua").grep_cword() end,
                },
                { -- DIAGNOSTIC
                        "<leader><leader>d",
                        function() require("fzf-lua").diagnostics_document() end,
                },
                { -- DIAGNOSTIC WORKSPACE
                        "<leader><leader>D",
                        function() require("fzf-lua").diagnostics_workspace() end,
                },
                { -- KEYMAPS
                        "<leader><leader>k",
                        function() require("fzf-lua").keymaps() end,
                },
                { -- HIGHLIGHTS
                        "<leader><leader>h",
                        function() require("fzf-lua").highlights() end,
                },
                { -- HELP
                        "<leader><leader>H",
                        function() require("fzf-lua").helptags() end,
                },
                { -- MAN
                        "<leader><leader>m",
                        function() require("fzf-lua").manpages() end,
                },
                { -- MULTI
                        "<leader><leader><leader>",
                        function() require("fzf-lua").global() end,
                },
        },
        config       = function()
                local actions = require("fzf-lua").actions

                require("fzf-lua").setup({
                        winopts = {
                                height      = 0.7,
                                width       = 0.7,
                                row         = 0.5,
                                col         = 0.5,
                                title       = " ",
                                title_pos   = "left",
                                title_flags = false,
                                fullscreen  = false,
                                border      = border,
                                backdrop    = vim.g.backdrop,
                                preview     = {
                                        title      = false,
                                        title_pos  = "left",
                                        hidden     = true,
                                        scrollbar  = false,
                                        vertical   = "right:70%",
                                        horizontal = "right:70%",
                                        layout     = "vertical",
                                        border     = border,
                                        winopts    = {
                                                number         = false,
                                                relativenumber = false,
                                                cursorline     = false,
                                                signcolumn     = "no",
                                        },
                                },
                        },
                        keymap  = {
                                builtin    = {
                                        ["<C-p>"]    = "toggle-preview",
                                        ["<C-k>"]    = "preview-page-up",
                                        ["<C-j>"]    = "preview-page-down",
                                        ["<A-k>"]    = "preview-up",
                                        ["<A-j>"]    = "preview-down",
                                        ["<A-up>"]   = "preview-up",
                                        ["<A-down>"] = "preview-down",
                                },
                                fzf_colors = {
                                        true,
                                        ["fg"]      = { "fg", "Normal" },
                                        ["bg"]      = { "bg", "Normal" },
                                        ["hl"]      = { "fg", "Normal" },
                                        ["fg+"]     = { "fg", "Visual" },
                                        ["bg+"]     = { "bg", "Visual" },
                                        ["hl+"]     = { "fg", "Normal" },
                                        ["info"]    = { "fg", "Function" },
                                        ["prompt"]  = { "fg", "Special" },
                                        ["pointer"] = { "fg", "String" },
                                        ["marker"]  = { "fg", "Keyword" },
                                        ["spinner"] = { "fg", "Function" },
                                        ["header"]  = { "fg", "Special" },
                                },
                        },
                        files   = {
                                actions    = {
                                        ["enter"]  = actions.file_edit,
                                        ["ctrl-q"] = actions.file_set_to_qf,
                                        ["ctrl-l"] = actions.file_set_to_ll,
                                        ["ctrl-h"] = actions.toggle_hidden,
                                        ["ctrl-o"] = actions.toggle_ignore,
                                },
                                cwd_prompt = false,
                        },
                })
        end,
}
