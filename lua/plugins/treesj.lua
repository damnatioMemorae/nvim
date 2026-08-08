local cmd = vim.cmd
local function toggle()
        require "treesj".toggle()
        cmd.normal "^"
end

return {
        "Wansmer/treesj",
        dependencies = "nvim-treesitter",
        keys         = { { "<LocalLeader>s", toggle, desc = "TreeSJ toggle split/join" } },
        opts         = {
                use_default_keymaps = false,
                check_syntax_error  = true,
                max_join_length     = math.huge,
                cursor_behavior     = "start",
                notify              = true,
                dot_repeat          = true,
        },
}
