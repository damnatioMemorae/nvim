local fn         = vim.fn
local api        = vim.api
local diagnostic = vim.diagnostic

local qf_ns      = api.nvim_create_namespace "qflist-diagnostics"
local per_buffer = {}

auq "QuickFixCmdPre" {
        pattern  = "make",
        callback = function()
                for bufnr, _ in pairs(per_buffer) do
                        vim.diagnostic.reset(qf_ns, bufnr)
                end
                require "table.clear" (per_buffer)
        end,
}
auq "QuickFixCmdPost" {
        pattern  = "make",
        callback = function()
                local qf = fn.getqflist { all = true, open = false }
                if qf then
                        local dgs = diagnostic.fromqflist(qf.items)
                        for _, dg in ipairs(dgs) do
                                local bufnr = dg.bufnr
                                if per_buffer[bufnr] == nil then
                                        per_buffer[bufnr] = {}
                                end
                                per_buffer[bufnr][#per_buffer[bufnr] + 1] = dg
                        end
                        for bufnr, dgl in pairs(per_buffer) do
                                diagnostic.set(qf_ns, bufnr, dgl)
                        end
                end
        end,
}
