local M = {}

----SCRATCH BUFFER------------------------------------------------------------------------------------------------------

vim.api.nvim_create_user_command("Scratch", function()
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

----DELETE COMMENTS-----------------------------------------------------------------------------------------------------

vim.api.nvim_create_user_command("RemoveComments", function()
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

----LSP CAPABILITIES----------------------------------------------------------------------------------------------------

vim.api.nvim_create_user_command("LspCapabilities", function(ctx)
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

------------------------------------------------------------------------------------------------------------------------
return M
