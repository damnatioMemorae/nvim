local o   = vim.o
local bo  = vim.bo
local fn  = vim.fn
local wo  = vim.wo
local ts  = vim.ts
local api = vim.api

local filetype = vim.filetype

local M = {};

---@param path string
---@return string
local function shortenPath(path)
        local sep    = string.sub(package.config, 1, 1);
        local as_raw = { "nvim$" };

        local function isRaw(str)
                for _, pattern in ipairs(as_raw) do
                        if string.match(str, pattern) then
                                return true;
                        end
                end

                return false;
        end

        local parts     = vim.split(path, sep, { trimempty = true });
        local shortened = {};

        for p, part in ipairs(parts) do
                if isRaw(part) or p == 1 or p == #parts then
                        table.insert(shortened, part);
                elseif string.match(part, "^%.") then
                        table.insert(shortened, fn.strcharpart(part, 0, 2));
                else
                        table.insert(shortened, fn.strcharpart(part, 0, 1));
                end
        end

        return table.concat(shortened, sep);
end

---@param a number
---@param b number
---@return string
local function rangeText(a, b)
        if a ~= b then
                return tostring(a) .. "-" .. tostring(b);
        else
                return tostring(a);
        end
end

---@param text string
---@param width integer
---@return string
local function center(text, width)
        local text_width    = fn.strdisplaywidth(text);
        local before, after = math.floor((width - text_width) / 2), math.ceil((width - text_width) / 2);

        return string.rep(" ", before) .. text .. string.rep(" ", after);
end

---@type "quickfix" | "location"
M.list = nil;

---@type integer
M.ns = api.nvim_create_namespace "quickfix";

---@type integer
M.buffer = nil;

---@type integer
M.winid = nil;

---@type boolean
M.should_decorate = true;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param data any
---@return string[]
function M.locText(data) ---@diagnostic disable-line
        local items = fn.getloclist(data.winid, { id = data.id, items = 0 }).items;
        local infos = {};

        local p_width, s_width = 0, 0;

        for i = data.start_idx, data.end_idx do
                local item = items[i];
                local buf  = item.bufnr;

                local name = fn.fnamemodify(api.nvim_buf_get_name(buf), ":~:.");
                name       = shortenPath(name);

                local row, col = rangeText(item.lnum, item.end_lnum), rangeText(item.col, item.end_col);

                p_width = math.max(p_width, fn.strdisplaywidth(name));
                s_width = math.max(s_width, fn.strdisplaywidth(row .. " col " .. col));

                if api.nvim_buf_is_loaded(buf) then
                        local ft = bo[buf].ft;

                        table.insert(infos, {
                                path     = name,
                                filetype = ft ~= "" and ft or nil,

                                row = row,
                                col = col,

                                text = item.text,
                        });
                else
                        local ft;

                        if string.match(M.last_command or "", "grep") then
                                -- Only add filetype for searches.
                                ft = filetype.match { filename = name };
                        end

                        table.insert(infos, {
                                path     = name,
                                filetype = ft ~= "" and ft or nil,

                                row = row,
                                col = col,

                                text = item.text,
                        });
                end
        end

        ---@type string[]
        local lines = {};

        for _, info in ipairs(infos) do
                local line = string.format(" %" .. p_width .. "s", info.path);
                line       = line .. " | ";

                line = line .. center(info.row .. " col " .. info.col, s_width);
                line = line .. " |";

                if info.filetype then
                        line = line .. string.format("<%s> %s", info.filetype, info.text);
                else
                        line = line .. " " .. info.text;
                end

                table.insert(lines, line);
        end

        return lines;
end

---@param data any
---@return string[]
function M.qfText(data)
        local items = fn.getqflist { id = data.id, items = 0 }.items;
        local infos = {};

        local p_width, s_width = 0, 0;

        for i = data.start_idx, data.end_idx do
                local item = items[i];
                local buf  = item.bufnr;

                local name = fn.fnamemodify(api.nvim_buf_get_name(buf), ":~:.");
                name       = shortenPath(name);

                local row, col = rangeText(item.lnum, item.end_lnum), rangeText(item.col, item.end_col);

                p_width = math.max(p_width, fn.strdisplaywidth(name));
                s_width = math.max(s_width, fn.strdisplaywidth(row .. " col " .. col));

                if api.nvim_buf_is_loaded(buf) then
                        local ft   = bo[buf].ft;
                        local line = api.nvim_buf_get_lines(buf, item.lnum - 1, item.lnum, false)[1];

                        table.insert(infos, {
                                path     = name,
                                filetype = ft ~= "" and ft or nil,

                                row = row,
                                col = col,

                                text = line,
                        });
                else
                        local ft;

                        if string.match(M.last_command or "", "grep") then
                                -- Only add filetype for searches.
                                ft = filetype.match { filename = name };
                        end

                        table.insert(infos, {
                                path     = name,
                                filetype = ft ~= "" and ft or nil,

                                row = row,
                                col = col,

                                text = item.text,
                        });
                end
        end

        ---@type string[]
        local lines = {};

        for _, info in ipairs(infos) do
                local line = string.format(" %" .. p_width .. "s", info.path);
                line       = line .. " | ";

                line = line .. center(info.row .. " col " .. info.col, s_width);
                line = line .. " |";

                if info.filetype then
                        line = line .. string.format("<%s> %s", info.filetype, info.text);
                else
                        line = line .. " " .. info.text;
                end

                table.insert(lines, line);
        end

        return lines;
end

---@param data any
---@return string[]
function M.text(data)
        if data.quickfix == 1 then
                M.list = "quickfix";
                return M.qfText(data);
        else
                M.list = "location";
                return M.locText(data);
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param name string
---@param tsNode table
---@param injectionLines string[]
function M.addDecor(name, tsNode, injectionLines)
        local line_count = api.nvim_buf_line_count(M.buffer);

        local callbacks = {
                qf_filename = function()
                        local text        = ts.get_node_text(tsNode, M.buffer, {});
                        local whitespaces = string.match(text, "^%s*");

                        local range = { tsNode:range() };

                        if not package.loaded["icons"] then
                                return;
                        end

                        local icon = package.loaded["icons"].get(
                                fn.fnamemodify(text, ":e"),
                                {
                                        "@comment",
                                        "DiagnosticError",
                                        "@constant",
                                        "DiagnosticWarn",
                                        "DiagnosticOk",
                                        "@function",
                                        "@property",
                                }
                        );

                        api.nvim_buf_set_extmark(M.buffer, M.ns, range[1], range[2] + #whitespaces, {
                                end_col = range[4],

                                virt_text_pos = "inline",
                                virt_text     = {
                                        { icon.icon, icon.hl },
                                },

                                hl_group = icon.hl,
                        });
                end,

                qf_separator = function()
                        local text        = ts.get_node_text(tsNode, M.buffer, {});
                        local whitespaces = string.match(text, "^%s*");

                        local range = { tsNode:range() };
                        local char  = "│";

                        if not tsNode:parent():next_sibling() and not tsNode:parent():prev_sibling() then
                                char = "◆";
                        elseif range[1] == 0 then
                                char = "╷";
                        elseif range[1] == line_count - 1 then
                                char = "╵";
                        end

                        api.nvim_buf_set_extmark(M.buffer, M.ns, range[1], range[2] + #whitespaces, {
                                end_col = range[4],
                                hl_mode = "combine",

                                virt_text_pos = "overlay",
                                virt_text     = { { char } },
                        });
                end,

                qf_content = function()
                        local text        = ts.get_node_text(tsNode, M.buffer, {});
                        local whitespaces = string.match(text, "^%s*");

                        local range = { tsNode:range() };

                        local kinds     = {
                                default = { "󱈤 ", "@function" },
                                loc     = { " ", "@conditional" },

                                w = { " ", "DiagnosticWarn" },
                                e = { "󰅙 ", "DiagnosticError" },
                                i = { "󰀨 ", "DiagnosticInfo" },
                                n = { "󰁨 ", "DiagnosticHint" },
                        };
                        local virt_text = kinds.default;

                        if M.list == "location" then
                                virt_text = kinds.loc;
                        else
                                local qflist = fn.getqflist();

                                if qflist[range[1] + 1] then
                                        local item = qflist[range[1] + 1];
                                        local type = string.lower(item.type or "");

                                        virt_text = kinds[type] or kinds.default;

                                        if item.text and item.text ~= "" and text ~= " " .. item.text then
                                                api.nvim_buf_set_extmark(M.buffer, M.ns, range[1],
                                                                         range[2], {
                                                                                 virt_lines = {
                                                                                         {
                                                                                                 { " ╰╴", "@comment" },
                                                                                                 { item.text, virt_text[2] },
                                                                                         },
                                                                                 },
                                                                         });
                                        elseif item.text and item.text ~= "" then
                                                virt_text = {
                                                        "󰵅 ", virt_text[2],
                                                };
                                        end
                                end
                        end

                        ---@type boolean Are there whitespace before this node?
                        local has_space = #whitespaces > 0;

                        api.nvim_buf_set_extmark(M.buffer, M.ns, range[1],
                                                 range[2] + (has_space and 1 or 0), {
                                                         virt_text_pos = "inline",
                                                         virt_text     = {
                                                                 { has_space and "" or " " },
                                                                 virt_text,
                                                         },
                                                 });

                        if vim.list_contains(injectionLines, range[1]) == false then
                                api.nvim_buf_set_extmark(M.buffer, M.ns, range[1],
                                                         range[2] + #whitespaces, {
                                                                 end_col  = range[4],
                                                                 hl_group = "@comment",
                                                         });
                        end
                end,
        };

        if callbacks[name] then
                local can_call, err = pcall(callbacks[name]);

                if can_call == false then
                        vim.print(err);
                end
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

M.setup = function()
        -- Custom quickfix text function.
        o.quickfixtextfunc = "{ item -> v:lua.require('functions.quickfix').text(item) }";

        auq "FileType" {
                pattern  = "qf",
                callback = function(event)
                        M.buffer = event.buf;


                        --- BUG, Quickfix menu doesn't update it's
                        --- tree-sitter highlighting.
                        --- So, we rewrite the entire buffer.
                        bo[M.buffer].modifiable = true;

                        local lines = api.nvim_buf_get_lines(M.buffer, 0, -1, false);
                        api.nvim_buf_set_lines(M.buffer, 0, -1, false, lines);

                        bo[M.buffer].modifiable = false;
                        bo[M.buffer].modified   = false;

                        local win = fn.win_findbuf(M.buffer)[1];
                        if win then
                                wo[win].conceallevel  = 3;
                                wo[win].concealcursor = "nc";


                                wo[win].number         = false;
                                wo[win].relativenumber = false;
                                wo[win].numberwidth    = 1;

                                wo[win].signcolumn = "no";
                                wo[win].foldcolumn = "0";
                        end
                end,
        };

        auq "QuickFixCmdPre" {
                callback = function(event)
                        M.last_command = event.match;
                end,
        };

        auq { "CursorMoved", "ModeChanged" } {
                callback = function()
                        local buf = api.nvim_get_current_buf();

                        if buf ~= M.buffer then
                                return;
                        end
                end,
        };

        api.nvim_create_user_command("QfToggleDecors", function()
                                             M.should_decorate = not M.should_decorate;
                                     end, {
                                             desc = "Allows toggling decorations of the quickfix list",
                                     });
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
