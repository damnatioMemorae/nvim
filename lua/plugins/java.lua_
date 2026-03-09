return {
        "nvim-java/nvim-java",
        enabled = false,
        config  = function()
                require("java").setup({
                        checks = {
                        },
                        jdtls = {
                                version = "1.43.0",
                        },
                        lombok = {
                                enable  = true,
                                version = "1.18.40",
                        },
                        java_test = {
                                enable  = true,
                                version = "0.40.1",
                        },
                        java_debug_adapter = {
                                enable  = true,
                                version = "0.58.2",
                        },
                        spring_boot_tools = {
                                enable  = true,
                                version = "1.55.1",
                        },
                        jdk = {
                                auto_install = true,
                                version      = "17",
                        },
                        log = {
                                use_console   = true,
                                use_file      = true,
                                level         = "info",
                                log_file      = vim.fn.stdpath("state") .. "/nvim-java.log",
                                max_lines     = 1000,
                                show_location = true,
                        },
                })
        end,
}
