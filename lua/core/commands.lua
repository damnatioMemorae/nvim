local o   = vim.o
local bo  = vim.bo
local fn  = vim.fn
local fs  = vim.fs
local ts  = vim.treesitter
local wo  = vim.wo
local api = vim.api
local cmd = vim.cmd
local log = vim.log
local lsp = vim.lsp

local levels = log.levels

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local command = api.nvim_create_user_command

---- SCRATCH BUFFER ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

command("Scratch", function()
                cmd "rightb 10new"
                local buf = api.nvim_get_current_buf()
                for name, value in pairs {
                        filetype   = "scratch",
                        buftype    = "nofile",
                        bufhidden  = "wipe",
                        swapfile   = false,
                        modifiable = true,
                } do
                        api.nvim_set_option_value(name, value, { buf = buf })
                end
        end, { desc = "Open a scratch buffer", nargs = 0 })

---- DELETE COMMENTS -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

command("DeleteComments", function()
                local bufnr      = api.nvim_get_current_buf()
                local ft         = bo[bufnr].filetype
                local lang       = ts.language.get_lang(ft) or ft
                local ok, parser = pcall(ts.get_parser, bufnr, lang)

                if not ok then
                        return vim.notify("No parser for " .. ft, levels.WARN)
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
                        api.nvim_buf_set_text(bufnr, r[1], r[2], r[3], r[4], {})
                end
        end, {})

---- LSP CAPABILITIES ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

command("LspCapabilities", function(ctx)
                local client  = lsp.get_clients { name = ctx.args }[1]
                local new_buf = api.nvim_create_buf(true, true)
                local info    = {
                        capabilities        = client.capabilities,
                        server_capabilities = client.server_capabilities,
                        config              = client.config,
                }

                api.nvim_buf_set_lines(new_buf, 0, -1, false,
                                       vim.split(vim.inspect(info), "\n"))
                api.nvim_buf_set_name(new_buf, client.name .. " capabilities")
                bo[new_buf].filetype = "lua"
                cmd.buffer(new_buf)
                keymapq { "n", "q", cmd.bdelete, buffer = new_buf }
        end, {
                nargs    = 1,
                complete = function()
                        return vim
                            .iter(lsp.get_clients { bufnr = 0 })
                            :map(function(client)
                                    return client.name
                            end)
                            :totable()
                end,
        })

---- RUN ON SAVE ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local current_job = nil
local function startTask(task, data)
        local old   = current_job
        current_job = fn.jobstart(task, {
                stdout_buffered = false,
                on_stdout       = data,
                on_err          = data,
                on_exit         = function()
                        if current_job == old then
                                current_job = nil
                        end
                end,
        })
        if old then fn.jobstop(old) end
end

local function attachToBuf(pattern, task)
        local width = 30
        local buf   = api.nvim_create_buf(false, true)

        cmd "vsplit"

        local win = api.nvim_get_current_win()

        api.nvim_win_set_buf(win, buf)
        api.nvim_win_set_width(win, math.floor(o.columns * 0.01 * width))
        wo[win].number         = false
        wo[win].relativenumber = false
        wo[win].statuscolumn   = " "
        auq "BufWritePost" {
                group    = api.nvim_create_augroup("RunOnSave", { clear = true }),
                pattern  = pattern,
                callback = function()
                        local ns         = api.nvim_create_namespace "AutoRunner"
                        local file       = api.nvim_buf_get_name(0)
                        local root       = fs.root(0, { ".git" }) or ""
                        local file_path  = fs.relpath(root, file)
                        local line_count = api.nvim_buf_line_count(buf)

                        api.nvim_buf_set_lines(buf, -1, -1, false, { file_path })
                        api.nvim_buf_set_extmark(buf, ns, line_count, 0, { line_hl_group = "LspInlayHint" })
                        local append_data = function(_, data)
                                if data then
                                        api.nvim_buf_set_lines(buf, -1, -1, false, data)
                                end
                        end
                        startTask(task, append_data)
                end,
        }
end

command("AutoRun", function()
                local pattern = fn.input "Pattern: "
                local task    = vim.split(fn.input "Command: ", " ")
                attachToBuf(pattern, task)
        end, {})

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
