return {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
                "nvim-lua/plenary.nvim",
                -- "nvim-neo-tree/neo-tree.nvim",
        },
        config = function(_, opts)
                local lfo = require("lsp-file-operations")
                lfo.setup(opts)
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities       = vim.tbl_extend("force", capabilities, lfo.default_capabilities)
        end,
}
