return {
        cmd          = { "pylyzer", "--server" },
        filetypes    = { "python" },
        root_markers = {
                ".venv",
                "setup.py",
                "tox.ini",
                "requirements.txt",
                "Pipfile",
                "pyproject.toml",
                ".git",
        },
        settings     = {
                python = {
                        diagnostics     = true,
                        inlayHints      = true,
                        smartCompletion = true,
                        checkOnType     = false,
                },
        },
        cmd_env      = {
                ERG_PATH = vim.env.ERG_PATH or vim.fs.joinpath(vim.uv.os_homedir(), ".erg"),
        },
}
