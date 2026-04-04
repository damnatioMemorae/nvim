-- local util = require("lspconfig.util")

return {
        cmd          = {
                vim.fn.executable("OmniSharp") == 1 and "OmniSharp" or "omnisharp",
                "-z",
                "--hostPID",
                tostring(vim.fn.getpid()),
                "DotNet:enablePackageRestore=false",
                "--encoding",
                "utf-8",
                "--languageserver",
        },
        filetypes    = { "cs", "vb" },
        -- root_dir     = function(bufnr, on_dir)
        --         local fname = vim.api.nvim_buf_get_name(bufnr)
        --         on_dir(
        --                 util.root_pattern"*.sln" (fname)
        --                 or util.root_pattern"*.csproj" (fname)
        --                 or util.root_pattern"omnisharp.json" (fname)
        --                 or util.root_pattern"function.json" (fname)
        --         )
        -- end,
        init_options = {},
        capabilities = { workspace = { workspaceFolders = false } },
        settings     = {
                FormattingOptions       = { EnableEditorConfigSupport = true, OrganizeImports = nil },
                MsBuild                 = { LoadProjectsOnDemand = nil },
                RenameOptions           = { RenameInComments = nil, RenameOverloads = nil, RenameInStrings = nil },
                Sdk                     = { IncludePrereleases = true },
                RoslynExtensionsOptions = {
                        EnableAnalyzersSupport     = nil,
                        EnableImportCompletion     = nil,
                        AnalyzeOpenDocumentsOnly   = nil,
                        EnableDecompilationSupport = nil,
                },
        },
}
