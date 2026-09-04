local b   = vim.b
local bo  = vim.bo
local fn  = vim.fn
local ui  = vim.ui
local ts  = vim.ts
local api = vim.api
local cmd = vim.cmd
local log = vim.log
local lsp = vim.lsp
local opt = vim.opt
local net = vim.net

local levels = log.levels

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param startWrap string|"mdlink"
---@param endWrap? string
function M.wrap(startWrap, endWrap)
        if not endWrap then endWrap = startWrap end
        local mode = fn.mode()
        if mode == "V" then
                vim.notify("Visual line mode not supported", levels.WARN)
                return
        end
        local row, col     = unpack(api.nvim_win_get_cursor(0))
        -- local row, col     = unpack(vim.pos.cursor(0))
        local use_big_word = startWrap == "`"

        -- determine text
        local text = ""
        if mode == "n" then
                local cursor_char = api.nvim_get_current_line():sub(col + 1, col + 1)
                if not cursor_char:find "%w" and not use_big_word then
                        vim.notify("String under cursor is not a word or number.", levels.WARN)
                        return
                end
                text = startWrap == "`" and fn.expand "<cWORD>" or fn.expand "<cword>"
        elseif mode == "v" then
                cmd.normal { '"zy', bang = true }
                text = fn.getreg "z"
        end

        -- wrap text
        local insert = startWrap .. text .. endWrap
        local clipboard_url
        if startWrap == "mdlink" then
                local clipb   = fn.getreg "+"
                clipboard_url = clipb:match "^#[%w-]+$"        -- heading-link
                    or clipb:match [[^%l%l%l+://[^%s)%]}"'`>]+]] -- url
                    or ""
                insert        = ("[%s](%s)"):format(text, clipboard_url)
        end

        -- normal mode: check whether to undo instead
        local prev_opt    = opt.iskeyword:get()
        local should_undo = false
        if mode == "n" then
                opt.iskeyword:append { startWrap:sub(1, 1), endWrap:sub(1, 1) }
                local cword = use_big_word and fn.expand "<cWORD>" or fn.expand "<cword>"
                should_undo = (not use_big_word and cword == insert)
                    or (use_big_word and vim.startswith(insert, startWrap:rep(2)))
                if should_undo then insert = use_big_word and text:sub(2, -2) or text end
        end

        -- insert
        if mode == "n" then
                local word_arg = startWrap == "`" and "W" or "w"
                cmd.normal { '"_ci' .. word_arg .. insert, bang = true }
                opt.iskeyword = prev_opt
        elseif mode == "v" then
                cmd.normal { "gv", bang = true } -- re-select, since yank put us in normal mode
                cmd.normal { '"_c' .. insert, bang = true }
        elseif mode == "i" then
                local cur_line = api.nvim_get_current_line()
                local new_line = cur_line:sub(1, col) .. insert .. cur_line:sub(col + 1)
                api.nvim_set_current_line(new_line)
        end

        -- cursor movement
        if startWrap == "mdlink" then
                api.nvim_win_set_cursor(0, { row, col + 1 })
                if clipboard_url == "" and text ~= "" then cmd.normal { "f)", bang = true } end
        else
                local offset = should_undo and - #startWrap or #startWrap
                api.nvim_win_set_cursor(0, { row, col + offset })
        end
        if text == "" or clipboard_url == "" then cmd.startinsert() end
end

---@param key "o"|"O"|"<CR>"
function M.autoBullet(key)
        assert(
                key == "o" or key == "O" or key == "<CR>",
                "`autoBullet()` only accepts `o`, `O`, or `<CR>`"
        )
        local row, col          = unpack(api.nvim_win_get_cursor(0))
        -- local row, col          = unpack(vim.pos.cursor(0))
        local indent, continued = "", ""
        local ln                = row
        repeat
                local line = api.nvim_buf_get_lines(0, ln - 1, ln, false)[1]
                ln         = ln - 1
                if ln == 0 then break end
                indent           = line:match "^%s*"
                local task       = line:match "^%s*([-*+] %[[x ]%] )"
                local list       = not task and line:match "^%s*([-*+] )"
                local blockquote = line:match "^%s*(>+ )"
                local num        = line:match "^%s*(%d+%. )"
                continued        = list or task or num or blockquote or ""
                if num then continued = num:gsub("%d+", function(n) return tostring(tonumber(n) + 1) end) end
        until continued ~= "" or indent == "" -- loop to consider bullets on hard-wrapped lines
        if continued ~= "" then continued = indent .. continued end

        local line       = api.nvim_get_current_line()
        local empty_list = ((continued ~= "") and vim.trim(indent .. continued) == vim.trim(line))
            or line:match "^%s*%d+%. $"
        if key == "o" or key == "O" then
                if key == "O" then row = row - 1 end
                api.nvim_buf_set_lines(0, row, row, false, { continued })
                api.nvim_win_set_cursor(0, { row + 1, 1 })
                cmd.startinsert { bang = true } -- bang -> insert at EoL
        elseif key == "<CR>" and empty_list then
                api.nvim_set_current_line ""
        elseif key == "<CR>" and not empty_list then
                local before_cur, after_cur = line:sub(1, col), line:sub(col + 1)
                if vim.startswith(after_cur, continued) then continued = "" end -- cursor before list markers
                local next_line = continued .. after_cur
                api.nvim_buf_set_lines(0, row - 1, row, false, { before_cur, next_line })
                api.nvim_win_set_cursor(0, { row + 1, #continued })
        end
end

function M.followMdlinkOrWikilink()
        local mdlink_pattern   = "%[.-]%((.-)%)"
        local wikilink_pattern = "%[%[.-]]"
        local url_pattern      = [[%l+://[^%s)%]}"'`>]+]]
        local row, col         = unpack(api.nvim_win_get_cursor(0))
        -- local row, col         = unpack(vim.pos.cursor(0))
        local mdlink, wikilink, url
        local ln               = row
        local line             = api.nvim_get_current_line()

        -- look in current line
        local idx = 0
        col       = col + 1
        while true do
                local partial_line  = line:sub(idx)
                local _, mdlink_end = partial_line:find(mdlink_pattern)
                local _, wiki_end   = partial_line:find(wikilink_pattern)
                local _, url_end    = partial_line:find(url_pattern)
                if     mdlink_end
                and    (col <= idx + mdlink_end)
                and    (mdlink_end < (wiki_end or math.huge))
                and    (mdlink_end < (url_end or math.huge))
                then
                        mdlink = partial_line:match(mdlink_pattern)
                        break
                elseif wiki_end and (col <= idx + wiki_end) and (wiki_end < (url_end or math.huge)) then
                        wikilink = partial_line:match(wikilink_pattern)
                        break
                elseif url_end and (col <= idx + url_end) then
                        url = partial_line:match(url_pattern)
                        break
                end
                if not (mdlink_end or wiki_end or url_end) then break end -- no link found in line
                idx = idx + math.min(mdlink_end or math.huge, wiki_end or math.huge, url_end or math.huge)
        end

        -- look forward in upcoming lines
        local max_forward = 10
        local total_lines = api.nvim_buf_line_count(0)
        while not (mdlink or wikilink or url) do
                ln = ln + 1
                if ln > total_lines or ln > row + max_forward then
                        local msg = ("Could not find URL, mdlink, or wikilink within %d lines."):format(max_forward)
                        vim.notify(msg, levels.WARN)
                        return
                end
                line               = api.nvim_buf_get_lines(0, ln - 1, ln, false)[1]
                local mdlink_start = line:find(mdlink_pattern)
                local wiki_start   = line:find(wikilink_pattern)
                local url_start    = line:find(url_pattern)
                local closest      =
                    math.min(mdlink_start or math.huge, wiki_start or math.huge, url_start or math.huge)
                if closest == mdlink_start then mdlink = line:match(mdlink_pattern) end
                if closest == wiki_start then wikilink = line:match(wikilink_pattern) end
                if closest == url_start then url = line:match(url_pattern) end
        end

        if mdlink or url then
                local is_file_link = not url and not vim.startswith(mdlink, "http")
                if is_file_link then return cmd.edit(vim.uri_decode(mdlink)) end

                -- move cursor to start of mdlink or url
                local target_col = mdlink and line:find(mdlink_pattern) or line:find(url_pattern)
                api.nvim_win_set_cursor(0, { ln, target_col - 1 })
                ui.open(mdlink or url)
        elseif wikilink then
                -- `vim.lsp.buf.definition` requires that cursor is on the link
                local target_col = line:find(wikilink, nil, true)
                api.nvim_win_set_cursor(0, { ln, target_col - 1 })
                local has_definition_provider =
                    lsp.get_clients { bufnr = 0, method = "textDocument/definition" }[1]
                assert(has_definition_provider, "No LSP client supporting `textDocument/definition` found.")
                lsp.buf.definition() -- requires marksman, zk, or markdown-oxide
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param type "list"|"task"
function M.cycle(type)
        local lnum, col = unpack(api.nvim_win_get_cursor(0))
        -- local lnum, col = unpack(vim.pos.cursor(0))
        local cur_line  = api.nvim_get_current_line()
        local updated

        if type == "list" then
                updated = cur_line:gsub("^(%s*)([%d.*+-]+ )", function(indent, list)
                        local is_task = cur_line:find "^%s*[*+-] %[[ x-]%] "
                        if is_task then return indent .. list end
                        if list:find "[*+-] " then return indent .. "1. " end -- bullet -> number
                        if list:find "%d+%. " then return indent end          -- number -> none
                        return indent ..
                            list -- edge cases caught by initial pattern, like `1-1` at start of line
                end)
                if updated == cur_line then -- none/heading/task -> bullet
                        updated = cur_line
                            :gsub("^(%s*)[*+-] %[[ x-]%] ", "%1") -- remove task
                            :gsub("^#+ ", "")                   -- remove heading
                            :gsub("^(%s*)(.*)", "%1- %2")       -- add bullet
                end
        elseif type == "task" then
                updated = cur_line:gsub("^%s*[*+-] %[[ x-]%] ", function(task)
                        return task:gsub("%[[ x-]%]", {
                                ["[ ]"] = "[x]",
                                ["[x]"] = "[-]",
                                ["[-]"] = "[ ]", -- `- [-]` is a pending task (set via render-markdown.nvim)
                        })
                end)
                if updated == cur_line then -- none/bullet/number -> task
                        updated = cur_line
                            :gsub("^(%s*)%d+%. ", "%1")     -- remove number
                            :gsub("^(%s*)[*+-] ", "%1")     -- remove bullet
                            :gsub("^(%s*)(.*)", "%1- [ ] %2") -- add open task
                end
        else
                error(("Unknown type for `.cycle()`: `%s`"):format(type))
        end

        api.nvim_set_current_line(updated)
        local diff = #updated - #cur_line
        api.nvim_win_set_cursor(0, { lnum, math.max(1, col + diff) })
end

function M.codeBlockFromClipboard()
        assert(bo.ft == "markdown", "Only for Markdown files.")
        -- dedent clipboard content
        local code     = fn.getreg "+":gsub("%s*$", ""):gsub("^%s*\n", "") -- trim, but not 1st indent
        local dedented = vim.text.indent(0, code)
        local lines    = vim.split(dedented, "\n")

        -- insert
        local row = api.nvim_win_get_cursor(0)[1]
        -- local row = vim.pos.cursor(0)[1]
        table.insert(lines, 1,     "```")
        table.insert(lines, "```")
        api.nvim_buf_set_lines(0, row - 1, row, false, lines)
        api.nvim_win_set_cursor(0, { row, 1 })
        cmd.startinsert { bang = true }
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param url string
---@return string placeholder
---@async
local function getTitleForUrl(url)
        b.fetch_count     = (b.fetch_count or 0) + 1
        local placeholder = " fetching title #" .. b.fetch_count
        local bufnr       = api.nvim_get_current_buf()

        net.request(
                url,
                {},
                vim.schedule_wrap(function(err, out)
                        if err then return vim.notify(err, levels.ERROR) end
                        local title = vim.trim(out.body:match "<title.->(.-)</title>" or "")
                        title       = title -- cleanup
                            :gsub("[\n\r]+", " ")
                            :gsub("  +", " ")
                            :gsub("^GitHub %- ", "")
                            :gsub(" · GitHub$", "")
                            :gsub("&amp;", "&")
                            :gsub("&#x27;", "'")
                            :gsub("&#039;t", "'")
                            :gsub("%[", "\\[") -- escape for mdlink `[]()`
                            :gsub("%]", "\\]")
                        if title == "" then vim.notify "No title found." end

                        local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
                        local row, col
                        for lnum, line in ipairs(lines) do
                                col = line:find(placeholder, nil, true)
                                row = lnum
                                if col then break end
                        end
                        assert(col, "Placeholder not found, it has likely been changed.")
                        local updated_line = lines[row]:gsub(vim.pesc(placeholder), vim.pesc(title))
                        api.nvim_buf_set_lines(bufnr, row - 1, row, false, { updated_line })
                        if title == "" and api.nvim_get_current_buf() == bufnr then
                                api.nvim_win_set_cursor(0, { row, col - 1 })
                                cmd.startinsert()
                        end
                end)
        )

        return placeholder
end

function M.addTitleToUrl()
        assert(bo.ft == "markdown", "Only for Markdown files.")

        local line = api.nvim_get_current_line()
        local url  = line:match [[<?%l+://%S+>?]]
        if vim.endswith(url, ")") then return vim.notify "Already Markdown link." end
        local inner_url   = url:gsub(">$", ""):gsub("^<", "") -- bare URL enclosed in `<>` due to MD034
        local placeholder = getTitleForUrl(inner_url)
        if not placeholder then return end

        local url_start, url_end = line:find(url, nil, true) -- `find` has literal search, `gsub` does not
        local updated_line       = line:sub(1, url_start - 1)
            .. ("[%s](%s)"):format(placeholder, inner_url)
            .. line:sub(url_end + 1)
        api.nvim_set_current_line(updated_line)
end

---updates any url in the register to a mdlink if in a Markdown buffer
---@param reg '"'|"+"|string
---@return nil
function M.addTitleToUrlIfMarkdown(reg)
        -- GUARD silently instead of assert, since it could be used for all paste commands
        if bo.ft ~= "markdown" or bo.buftype ~= "" then return end

        local node = ts.get_node()
        if node and node:type() == "code_fence_content" then return end
        if node and node:type() == "html_block" then return end
        local col               = api.nvim_win_get_cursor(0)[2]
        -- local col               = vim.pos.cursor(0)[2]
        local char_under_cursor = api.nvim_get_current_line():sub(col + 1, col + 1)
        if char_under_cursor:find "[()<>]" then return end -- inserting into mdlink / bare link

        local clipb = fn.getreg(reg)
        local url   = clipb:match "^%l+://%S+$" -- not ending with `)` to not match mdlinks
        if not url then return end

        local placeholder = getTitleForUrl(url)
        local mdlink      = ("[%s](%s)"):format(placeholder, url)
        fn.setreg(reg, mdlink)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
