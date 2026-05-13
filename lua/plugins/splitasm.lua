local function file(mode)
        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), mode)
        return path
end

return {
        "NickTsaizer/splitasm.nvim",
        cmd    = { "SplitAsm", "SplitAsmOpen", "SplitAsmSetup", "SplitAsmConfig", "SplitAsmToggleSync" },
        opts   = {
                compiler_cmd      = "clang++ " .. file(":p") .. " -o " .. file(":r"),
                executable_path   = file(":r"),
                auto_sync         = true,
                clean_asm         = false,
                source_row_colors = false,
        },
        config = function(_, opts)
                require("splitasm").setup(opts)
        end,
}
