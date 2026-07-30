local prefix = "s"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "echasnovski/mini.surround",
        version = false,
        event   = "BufReadPost",
        opts    = {
                custom_surroundings    = nil,
                highlight_duration     = 1000,
                n_lines                = 80,
                silent                 = true,
                search_method          = "next",
                respect_selection_type = true,
                mappings               = {
                        add            = prefix .. "s",
                        delete         = prefix .. "d",
                        find           = prefix .. "f",
                        find_left      = prefix .. "F",
                        highlight      = prefix .. "h",
                        replace        = prefix .. "r",
                        update_n_lines = prefix .. "n",

                        suffix_last = "h",
                        suffix_next = "l",
                },
        },
}
