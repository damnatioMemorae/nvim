return {
        "fredrikaverpil/godoc.nvim",
        version      = "*",
        ft           = "go",
        dependencies = { "ibhagwan/fzf-lua" },
        build        = "go install github.com/lotusirous/gostdsym/stdsym@latest",
        opts         = { window = { type = "vsplit" }, picker = { type = "fzf_lua" } },
}
