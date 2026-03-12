local M = {}

local lsp    = vim.lsp
local bo     = vim.bo
local cmd    = vim.cmd
local api    = vim.api
local fn     = vim.fn
local notify = vim.notify
------------------------------------------------------------------------------------------------------------------------

function M.bufferInfo()
        local pseudoTilde = "∼"

        local clients     = lsp.get_clients{ bufnr = 0 }
        local longestName = vim.iter(clients)
                   :fold(0, function(acc, client) return math.max(acc, #client.name) end)
        local lsps        = vim.tbl_map(function(client)
                                                local pad = (" "):rep(math.min(longestName - #client.name)) .. " "
                                                local root = client.root_dir and
                                                           client.root_dir:gsub("/Users/%w+", pseudoTilde)
                                                           or "*Single file mode*"
                                                return ("[%s]%s%s"):format(client.name, pad, root)
                                        end, clients)

        local indentType   = bo.expandtab and "spaces" or "tabs"
        local indentAmount = bo.expandtab and bo.tabstop or bo.shiftwidth

        local out = {
                "[bufnr]     " .. api.nvim_get_current_buf(),
                "[winid]     " .. api.nvim_get_current_win(),
                "[filetype]  " .. (bo.filetype == "" and '""' or bo.filetype),
                "[buftype]   " .. (bo.buftype == "" and '""' or bo.buftype),
                ("[indent]    %s (%s)"):format(indentType, indentAmount),
                "[cwd]       " .. (vim.uv.cwd() or "nil"):gsub("/Users/%w+", pseudoTilde),
                "",
        }
        if #lsps > 0 then
                vim.list_extend(out, { "**Attached LSPs with root**", unpack(lsps) })
        else
                vim.list_extend(out, { "*No LSPs attached.*" })
        end
        local opts = { title = "Inspect buffer", icon = "󰽙", timeout = 10000 }
        notify(table.concat(out, "\n"), vim.log.levels.DEBUG, opts)
end

function M.nodeAtCursor()
        local config = { hlDuration = 1500, hlGroup = "Search", maxChildren = 4 }

        local ok, node = pcall(vim.treesitter.get_node)
        if not (ok and node) then
                notify("No node under cursor", vim.log.levels.DEBUG, { icon = "" })
                return
        end

        local parent = node:parent() and node:parent():type() or "."
        local tree   = { parent, "└── " .. node:type() }
        for childIdx = 1, config.maxChildren do
                local child = node:child(childIdx)
                if not child then break end
                table.insert(tree, ("      ├── %s"):format(child:type()))
        end
        tree[#tree] = tree[#tree]:gsub("├", "└")
        local msg   = table.concat(tree, "\n")
        notify(msg, vim.log.levels.DEBUG, { icon = "", title = "Node at cursor" })

        local startRow, startCol = node:start()
        local endRow, endCol     = node:end_()
        local ns                 = api.nvim_create_namespace("node-highlight")
        if startRow == endRow then
                api.nvim_buf_add_highlight(0, ns, config.hlGroup, startRow, startCol, endCol)
        else
                api.nvim_buf_add_highlight(0, ns, config.hlGroup, startRow, startCol, -1)
                local lnum = startRow + 1
                while lnum < endRow do
                        api.nvim_buf_add_highlight(0, ns, config.hlGroup, lnum, 0, -1)
                        lnum = lnum + 1
                end
                api.nvim_buf_add_highlight(0, ns, config.hlGroup, endRow, 0, endCol)
        end
        vim.defer_fn(function() api.nvim_buf_clear_namespace(0, ns, 0, -1) end, config.hlDuration)

        vim.defer_fn(function()
                             local countNs = api.nvim_create_namespace("searchCounter")
                             api.nvim_buf_clear_namespace(0, countNs, 0, -1)
                     end, 1)
end

function M.lspCapabilities()
        local clients = lsp.get_clients{ bufnr = 0 }
        if #clients == 0 then
                notify("No LSPs attached.", vim.log.levels.WARN, { icon = "󱈄" })
                return
        end
        vim.ui.select(clients, {
                              prompt      = "󱈄 Select LSP:",
                              kind        = "plain",
                              format_item = function(client) return client.name end,
                      }, function(client)
                              if not client then return end
                              local info   = {
                                      capabilities        = client.capabilities,
                                      server_capabilities = client.server_capabilities,
                                      config              = client.config,
                              }
                              local opts   = { icon = "󱈄", title = client.name .. " capabilities", ft = "lua" }
                              local header = "-- for a full view, open in notification history\n"
                              local text   = header .. vim.inspect(info)
                              notify(text, vim.log.levels.DEBUG, opts)
                      end)
end

function M.evalNvimLua()
        local function eval(input)
                if not input or input == "" then return end
                local out  = fn.luaeval(input)
                local opts = { title = "Eval", icon = "", ft = "lua" }
                notify(vim.inspect(out), vim.log.levels.DEBUG, opts)
        end

        if fn.mode() == "n" then
                vim.ui.input({ prompt = " Eval: ", win = { ft = "lua" } }, eval)
        else
                cmd.normal{ '"zy', bang = true }
                eval(fn.getreg("z"))
        end
end

function M.runFile()
        cmd("silent update")
        local hasShebang = api.nvim_buf_get_lines(0, 0, 1, false)[1]:find("^#!")
        local filepath   = api.nvim_buf_get_name(0)
        if bo.filetype == "lua" and filepath:find("nvim") then
                cmd.source()
                -- elseif bo.filetype == "lua" and fn.finddir("love2d", nil, nil) then
                --         cmd("! love Game")
        elseif hasShebang then
                cmd("! chmod +x %")
                cmd("! %")
        else
                notify("File has no shebang.", vim.log.levels.WARN, { title = "Run", icon = "󰜎" })
        end

        if bo.filetype == "sh" and filepath:find("nvim") then
                cmd.source()
        elseif hasShebang then
                cmd("! chmod +x %")
                cmd("! ./%")
        else
                notify("File has no shebang.", vim.log.levels.WARN, { title = "Run", icon = "󰜎" })
        end
end

function M.inspectNodeAncestors()
        local node = vim.treesitter.get_node()
        if not node then return vim.notify("No node under cursor.", vim.log.levels.WARN) end
        local ancestors = {}
        while node do
                table.insert(ancestors, 1, node:type())
                node = node:parent()
        end
        local out = "↑ " .. table.concat(ancestors, "\n| ")
        vim.notify(out, nil, { title = "Node ancestors" })
end

------------------------------------------------------------------------------------------------------------------------
return M
