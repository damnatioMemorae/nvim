return {
        "altermo/ultimate-autopair.nvim",
        branch = "v0.6",
        event  = { "InsertEnter", "CmdlineEnter" },
        keys   = {
                { "<A-i>", "a{<CR>", mode = "n", desc = " Open new scope", remap = true },
                { "<A-i>", "{<CR>", mode = "i", desc = " Open new scope", remap = true },
        },
        opts   = {
                bs                    = { space = "balance", cmap = false },
                cr                    = { autoclose = true },
                tabout                = { enable = false, map = "<Nop>" },
                fastwarp              = { map = "<D-f>", rmap = "<D-F>", hopout = true, nocursormove = false, multiline = false },
                extensions            = { filetype = { nft = { "TelescopePrompt", "snacks_picker_input", "rip-substitute" } } },
                config_internal_pairs = {
                        { "'",   "'",   nft = { "markdown", "gitcommit" } },
                        { "```", "```", nft = { "markdown" } },
                        { '"',   '"',   nft = { "vim" } },
                        {
                                "`",
                                "`",
                                cond = function(_fn)
                                        local md_codeblock = vim.bo.ft == "markdown"
                                                   and vim.api.nvim_get_current_line():find("^[%s`]*$")
                                        return not md_codeblock
                                end,
                        },
                },

                { "**",   "**",   ft = { "markdown" } },
                { [[\"]], [[\"]], ft = { "zsh", "json", "applescript", "swift" } },
                { "<",    ">",    ft = { "vim" } },
                {
                        "<",
                        ">",
                        ft   = { "lua" },
                        cond = function(fn)
                                local in_lua_lua = vim.endswith(vim.api.nvim_buf_get_name(0), "/ftplugin/lua.lua")
                                return not in_lua_lua and fn.in_string()
                        end,
                },
        },
}
