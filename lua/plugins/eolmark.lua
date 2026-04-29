return {
        "aidancz/eolmark.nvim",
        event  = "BufReadPre",
        config = function()
                require("eolmark").setup({
                        opts              = { virt_text = { { "󱞣", "Comment" } } },
                        excluded_buftypes = { ".+" },
                })
        end,
}
