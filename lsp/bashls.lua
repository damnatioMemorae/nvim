return {
        cmd          = { "bash-language-server", "start" },
        filetypes    = { "bash", "sh", "zsh" },
        root_markers = { ".git" },
        settings     = {
                bashIde = {
                        includeAllWorkspaceSymbols = true,
                        globPattern                = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
                        shellcheckArguments        = "--shell=bash",
                },
        },
}
