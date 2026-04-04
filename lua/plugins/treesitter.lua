-- local ensure_installed = { "all" }
local ensure_installed = {
        "all",
}

---@param node "inc" | "dec" | "next" | "prev"
local function incSelect(node)
        if node == "inc" then
                if vim.treesitter.get_parser(nil, nil, { error = false }) then
                        require("vim.treesitter._select").select_parent(vim.v.count1)
                else
                        vim.lsp.buf.selection_range(vim.v.count1)
                end
        elseif node == "dec" then
                if vim.treesitter.get_parser(nil, nil, { error = false }) then
                        require("vim.treesitter._select").select_child(vim.v.count1)
                else
                        vim.lsp.buf.selection_range(-vim.v.count1)
                end
        elseif node == "next" then
                require("vim.treesitter._select").select_next(vim.v.count1)
        elseif node == "prev" then
                require("vim.treesitter._select").select_prev(vim.v.count1)
        end
end

return {
        "nvim-treesitter/nvim-treesitter",
        lazy  = false,
        build = ":TSUpdate",
        init  = function()
                if vim.fn.executable("tree-sitter") == 1 then
                        vim.defer_fn(function() require("nvim-treesitter").install(ensure_installed) end, 2000)
                else
                        local msg = "`tree-sitter-cli` not found. Skipping auto-install of parsers."
                        vim.notify(msg, vim.log.levels.WARN, { title = "Treesitter" })
                end

                vim.api.nvim_create_autocmd("FileType", {
                        desc     = "User: enable treesitter highlighting",
                        callback = function(ctx)
                                local has_started                = pcall(vim.treesitter.start, ctx.buf)
                                local dont_use_treesitter_indent = { "zsh", "bash", "markdown", "javascript" }

                                if has_started and not vim.list_contains(dont_use_treesitter_indent, ctx.match) then
                                        vim.bo[ctx.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                                end
                        end,
                })

                vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
                        desc     = "User: highlights for the Treesitter `comments` parser",
                        callback = function()
                                vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
                                vim.api.nvim_set_hl(0, "@comment.bold",     { bold = true })
                        end,
                })

                -- `ts_query_ls`: use the custom directory set in the treesitter config
                -- local ts_dir = require("nvim-treesitter.config").get_install_dir("parser")
                -- vim.lsp.config("ts_query_ls", { init_options = { parser_install_directories = { ts_dir } } })

                vim.keymap.set("x",          "n", function() incSelect("next") end, { desc = "Select next node" })
                vim.keymap.set("x",          "N", function() incSelect("prev") end, { desc = "Select previous node" })
                vim.keymap.set({ "x", "o" }, "m", function() incSelect("inc") end,  { desc = "Select child node" })
                vim.keymap.set({ "x", "o" }, "M", function() incSelect("dec") end,  { desc = "Select parent node" })
        end,
        opts  = { install_dir = vim.fn.stdpath("data") .. "/treesitter" },
}
