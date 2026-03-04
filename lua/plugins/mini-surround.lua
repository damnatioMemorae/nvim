return {
        "echasnovski/mini.surround",
        version = false,
        event   = "VeryLazy",
        opts    = {
                custom_surroundings    = nil,
                highlight_duration     = 1000,
                n_lines                = 20,
                silent                 = true,
                search_method          = "cover_or_next",
                respect_selection_type = true,
                mappings               = {
                        add            = "ss",
                        delete         = "sd",
                        find           = "sf",
                        find_left      = "sF",
                        highlight      = "sh",
                        replace        = "sr",
                        update_n_lines = "sn",

                        suffix_last    = "h",
                        suffix_next    = "l",
                },
        },
}
