local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local command = vim.api.nvim_create_user_command

---- SCRATCH BUFFER ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

command("Scratch", function()
                vim.cmd"rightb 10new"
                local buf = vim.api.nvim_get_current_buf()
                for name, value in pairs{
                        filetype   = "scratch",
                        buftype    = "nofile",
                        bufhidden  = "wipe",
                        swapfile   = false,
                        modifiable = true,
                } do
                        vim.api.nvim_set_option_value(name, value, { buf = buf })
                end
        end, { desc = "Open a scratch buffer", nargs = 0 })

---- DELETE COMMENTS -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

command("RemoveComments", function()
                local ts         = vim.treesitter
                local bufnr      = vim.api.nvim_get_current_buf()
                local ft         = vim.bo[bufnr].filetype
                local lang       = ts.language.get_lang(ft) or ft
                local ok, parser = pcall(ts.get_parser, bufnr, lang)

                if not ok then
                        return vim.notify("No parser for " .. ft, vim.log.levels.WARN)
                end

                local tree   = parser:parse()[1]
                local root   = tree:root()
                local query  = ts.query.parse(lang, "(comment) @comment")
                local ranges = {}

                for _, node in query:iter_captures(root, bufnr, 0, -1) do
                        table.insert(ranges, { node:range() })
                end

                table.sort(ranges, function(a, b)
                        if a[1] == b[1] then return a[2] < b[2] end
                        return a[1] > b[1]
                end)

                for _, r in ipairs(ranges) do
                        vim.api.nvim_buf_set_text(bufnr, r[1], r[2], r[3], r[4], {})
                end
        end, {})

---- LSP CAPABILITIES ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

command("LspCapabilities", function(ctx)
                local client  = vim.lsp.get_clients({ name = ctx.args })[1]
                local new_buf = vim.api.nvim_create_buf(true, true)
                local info    = {
                        capabilities        = client.capabilities,
                        server_capabilities = client.server_capabilities,
                        config              = client.config,
                }

                vim.api.nvim_buf_set_lines(new_buf, 0, -1, false,
                                           vim.split(vim.inspect(info), "\n"))
                vim.api.nvim_buf_set_name(new_buf, client.name .. " capabilities")
                vim.bo[new_buf].filetype = "lua"
                vim.cmd.buffer(new_buf)
                vim.keymap.set("n",     "q", vim.cmd.bdelete, { buffer = new_buf })
        end, {
                nargs    = 1,
                complete = function()
                        return vim.iter(vim.lsp.get_clients{ bufnr = 0 })
                                   :map(function(client) return client.name end)
                                   :totable()
                end,
        })

---- RUN ON SAVE ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local current_job = nil
local function startTast(cmd, data)
        local old   = current_job
        current_job = vim.fn.jobstart(cmd, {
                stdout_buffered = false,
                on_stdout       = data,
                on_err          = data,
                on_exit         = function()
                        if current_job == old then
                                current_job = nil
                        end
                end,
        })
        if old then vim.fn.jobstop(old) end
end

local function attachToBuf(pattern, cmd)
        local width = 30
        local buf   = vim.api.nvim_create_buf(false, true)

        vim.cmd("vsplit")

        local win = vim.api.nvim_get_current_win()

        vim.api.nvim_win_set_buf(win, buf)
        vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.01 * width))
        vim.wo[win].number         = false
        vim.wo[win].relativenumber = false
        vim.wo[win].statuscolumn   = " "
        vim.api.nvim_create_autocmd("BufWritePost", {
                group    = vim.api.nvim_create_augroup("RunOnSave", { clear = true }),
                pattern  = pattern,
                callback = function()
                        local ns         = vim.api.nvim_create_namespace("AutoRunner")
                        local file       = vim.api.nvim_buf_get_name(0)
                        local root       = vim.fs.root(0, { ".git" }) or ""
                        local file_path  = vim.fs.relpath(root, file)
                        local line_count = vim.api.nvim_buf_line_count(buf)

                        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { file_path })
                        vim.api.nvim_buf_set_extmark(buf, ns, line_count, 0, { line_hl_group = "LspInlayHint" })
                        local append_data = function(_, data)
                                if data then
                                        vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                                end
                        end
                        startTast(cmd, append_data)
                end,
        })
end

command("AutoRun", function()
                local pattern = vim.fn.input("Pattern: ")
                local cmd     = vim.split(vim.fn.input("Command: "), " ")
                attachToBuf(pattern, cmd)
        end, {})

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
