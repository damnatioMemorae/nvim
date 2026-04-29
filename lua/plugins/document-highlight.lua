return {
        "akioweh/lsp-document-highlight.nvim",
        event = "BufReadPre",
        keys  = {
                {
                        "[[",
                        function()
                                require("lsp-document-highlight").jump(-vim.v.count1, true)
                        end,
                        desc = "Previous Reference",
                },
                {
                        "]]",
                        function()
                                require("lsp-document-highlight").jump(vim.v.count1, true)
                        end,
                        desc = "Next Reference",
                },
        },
        opts  = { throttle = 1000 },
}
