return {
        cmd       = { "haskell-language-server-wrapper", "--lsp" },
        filetypes = { "haskell", "lhaskell" },
        settings  = {
                haskell = {
                        formattingProvider      = "fourmolu",
                        cabalFormattingProvider = "cabalfmt",
                },
        },
}
