return {
        "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
        lazy         = false,
        dependencies = "igorlfs/nvim-dap-view",
        config       = function()
                require("dap-disasm").setup({
                        dapview_register = true,
                })
        end,
}
