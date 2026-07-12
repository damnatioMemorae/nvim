return {
        "nvim-mini/mini.operators",
        enabled = false,
        version = false,
        event   = "BufReadPre",
        opts    = {
                evaluate = { prefix = "" },
                replace  = { prefix = "", reindent_linewise = true },
                exchange = { prefix = "sx", reindent_linewise = true },
                sort     = { prefix = "sy" },
                -- multiply = { prefix = "w" },
        },
}
