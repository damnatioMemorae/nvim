local o    = vim.o
local v    = vim.v
local fn   = vim.fn
local wo   = vim.wo
local api  = vim.api
local cmd  = vim.cmd
local iter = vim.iter

local T = require "utils.functional".matching.thunk

-- local _levels = {}
-- vim.api.nvim_create_autocmd("BufLeave", {
--         callback = function(args)
--                 _levels[args.buf] = vim.wo.foldlevel
--         end,
-- })
-- vim.api.nvim_create_autocmd("BufEnter", {
--         callback = function(args)
--                 vim.wo.foldlevel = _levels[args.buf] or 0
--         end,
-- })

_linq "LspInlayHint" "FoldText"

---- TEXT ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

o.foldtext = function()
        local start   = fn.getline(v.foldstart)
        local indent  = start:match "^%s*" or ""
        local first   = start
            :gsub("^%s*", "")
            :gsub("\t", string.rep(" ", o.tabstop))
        local content = { first .. " ... ", "FoldText" }
        return match(indent) {
                [""] = { { indent }, content },
                _    = { { indent }, content },
        }
end

---- OPERATIONS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local range = { 0, 9 }

local function getMaxFoldLvl()
        return iter(fn.range(1, api.nvim_buf_line_count(0)))
            :enumerate()
            :map(function(lnum) return fn.foldlevel(lnum) end)
            :fold(0, math.max)
end

local function setFoldLvl(lvl)
        return function()
                guard {
                        lvl >= range[1], function() wo.foldlevel = lvl end,
                        lvl <= range[1], function() wo.foldlevel = lvl end,
                }
        end
end

local function reduceFoldLvl()
        local lvl = tonumber(wo.foldlevel) or 0
        guard { lvl > 0, function() wo.foldlevel = lvl - 1 end }
end

local function increaseFoldLvl()
        local lvl = tonumber(wo.foldlevel) or 0
        guard { lvl < getMaxFoldLvl(), function() wo.foldlevel = lvl + 1 end }
end

local function closeTopLvl()
        cmd.normal { "zR", bang = true }
        cmd "%foldclose"
end

local function openTopLvl()
        cmd.normal { "zM", bang = true }
        cmd "%foldopen"
end

---- NAVIGATION ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param winid number
---@param f fun(): any
---@return any
local function winCall(winid, f)
        return match(winid) {
                [api.nvim_get_current_win()] = T(f),
                [0]                          = T(f),
                _                            = T(api.nvim_win_call, winid, f),
        }
end

---@param winid number
---@return table
local function saveView(winid)
        return winCall(winid, fn.winsaveview)
end

---@param winid number
---@param lnum number
---@return number
local function foldClosed(winid, lnum)
        return winCall(winid, function() return fn.foldclosed(lnum) end)
end

---@param winid number
---@param view table
local function restView(winid, view)
        winCall(winid, function() fn.winrestview(view) end)
end

---@return number
local function getCurLnum()
        return api.nvim_win_get_cursor(0)[1]
end

local function gotoPrevFold()
        local cnt      = v.count1
        local view     = saveView(0)
        local cur_lnum = getCurLnum()
        cmd "norm! m`"
        local prev_lnum
        local prev_lnum_list = {}
        while cnt > 0 do
                cmd [[keepj norm! zk]]
                local t_lnum = getCurLnum()
                cmd [[keepj norm! [z]]
                if t_lnum == getCurLnum() then
                        local fold_start_lnum = foldClosed(0, t_lnum)
                        if fold_start_lnum > 0 then
                                cmd(("keepj norm! %dgg"):format(fold_start_lnum))
                        end
                end
                local next_lnum = getCurLnum()
                while cur_lnum > next_lnum do
                        t_lnum = next_lnum
                        table.insert(prev_lnum_list, next_lnum)
                        cmd [[keepj norm! zj]]
                        next_lnum = getCurLnum()
                        if next_lnum == t_lnum then
                                break
                        end
                end
                if #prev_lnum_list == 0 then
                        break
                end
                if #prev_lnum_list < cnt then
                        cnt       = cnt - #prev_lnum_list
                        cur_lnum  = prev_lnum_list[1]
                        prev_lnum = cur_lnum
                        cmd(("keepj norm! %dgg"):format(cur_lnum))
                        prev_lnum_list = {}
                else
                        while cnt > 0 do
                                prev_lnum = table.remove(prev_lnum_list)
                                cnt       = cnt - 1
                        end
                end
        end
        restView(0, view)
        if prev_lnum then
                cmd(("norm! %dgg_"):format(prev_lnum))
        end
end

---- KEYMAP --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local nxo = { "n", "x", "o" }
kq
""
    { "<S-Left>", "zM", desc = "Folds close all", mode = nxo }
    { "<S-Right>", "zR", desc = "Folds open all", mode = nxo }
    { "<Left>", "zc^", desc = "Fold close", mode = nxo }
    { "<Right>", "zo^", desc = "Fold open", mode = nxo }
    { "<Down>", "zj^", desc = "Fold next", mode = nxo }
    { "<Up>", gotoPrevFold, desc = "Fold prev", mode = nxo }
    { "<M-Z>", reduceFoldLvl, desc = "Reduce Fold", mode = nxo }
    { "<M-z>", increaseFoldLvl, desc = "Increase Fold", mode = nxo }
    { "<Esc>", "<Esc>zv", mode = "i" }

iter { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
    :each(function(_) keymapq { "<M-" .. _ .. ">", setFoldLvl(tonumber(_) - 1) } end)
