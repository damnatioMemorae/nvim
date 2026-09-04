return {
        "nvim-mini/mini.ai",
        version = false,
        event   = "BufReadPost",
        opts    = {
                custom_textobjects = {
                        b = { "%b()", "^.().*().$" },
                        B = { "%(%(().-()%)%)", "%( %(().-()%) %)" },
                        c = { "%b{}", "^.().*().$" },
                        C = { "%{%{().-()%}%}", "%{ %{().-()%} %}" },
                        r = { "%b[]", "^.().*().$" },
                        R = { "%[%[().-()%]%]" },
                        t = { "%b<>", "^.().*().$" },
                },
                n_lines            = 50,
                search_method      = "cover_or_next",
                silent             = false,
                mappings           = {
                        around      = "a",
                        inside      = "i",
                        around_next = "an",
                        inside_next = "in",
                        around_last = "al",
                        inside_last = "il",
                },
        },
}
