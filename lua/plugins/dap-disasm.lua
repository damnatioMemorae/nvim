return {
        "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
        config = function()
                require("dap-disasm").setup({
                        dapui_register   = true,
                        dapview_register = true,
                })
        end,
}
