return {
        "nvim-mini/mini.operators",
        version = false,
        event   = "BufReadPost",
        opts    = {
                evaluate = { prefix = "se" },
                exchange = { prefix = "sx", reindent_linewise = true },
                sort     = { prefix = "sy", reindent_linewise = true },
        },
}
