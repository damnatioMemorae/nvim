return {
        cmd          = { "vscode-css-language-server", "--stdio" },
        filetypes    = { "css", "scss", "less" },
        init_options = { provideFormatter = false },
        root_markers = { "package.json", ".git" },
        settings     = {
                scss = { validate = true },
                less = { validate = true },
                css = {
                        validate = true,
                        lint = {
                                vendorPrefix        = "ignore",
                                duplicateProperties = "warning",
                                zeroUnits           = "warning",
                        },
                },
        },
}
