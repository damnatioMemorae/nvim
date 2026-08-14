local o   = vim.o
local v   = vim.v
local fn  = vim.fn
local wo  = vim.wo
local api = vim.api
local cmd = vim.cmd

local _levels = {}

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

---- TEXT ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function _G.foldText()
        local start  = fn.getline(v.foldstart)
        local indent = start:match "^%s*" or ""
        local first  = start
          :gsub("^%s*", "")
          :gsub("\t", string.rep(" ", o.tabstop))

        local content = { first .. " ... ", "FoldText" }

        return match(indent) {
                [""] = { { indent }, content },
                _    = { { indent }, content },
        }
end

o.foldtext = "v:lua.foldText()"

---- OPERATIONS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local range = { 0, 9 }

local function getMaxFoldLvl()
        return vim
          .iter(ipairs(fn.range(1, api.nvim_buf_line_count(0))))
          :map(function(lnum) return fn.foldlevel(lnum) end)
          :fold(0, math.max)
end

local function setFoldLvl(lvl)
        guard { lvl >= range[1], function() wo.foldlevel = lvl end,
                lvl <= range[1], function() wo.foldlevel = lvl end,
        }
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

---- MOVEMENT ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param winid number
---@param f fun(): any
---@return any
local function winCall(winid, f)
        return match(winid) {
                [api.nvim_get_current_win()] = function() return f() end,
                [0]                          = function() return f() end,
                _                            = function() return api.nvim_win_call(winid, f) end,
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
        return winCall(winid, function()
                return fn.foldclosed(lnum)
        end)
end

---@param winid number
---@param view table
local function restView(winid, view)
        winCall(winid, function()
                fn.winrestview(view)
        end)
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

local mode = { "n", "x", "o" }
keyq { "<S-Left>", "zM", mode = mode, desc = "Folds close all" }
keyq { "<S-Right>", "zR", mode = mode, desc = "Folds open all" }
keyq { "<Left>", "zc^", mode = mode, desc = "Fold close" }
keyq { "<Right>", "zo^", mode = mode, desc = "Fold open" }
keyq { "<Down>", "zj^", mode = mode, desc = "Fold next" }
keyq { "<Up>", gotoPrevFold, mode = mode, desc = "Fold prev" }
keyq { "<M-z>", closeTopLvl, mode = mode, desc = "Close toplevel folds" }
keyq { "<M-Z>", openTopLvl, mode = mode, desc = "Open toplevel folds" }
keyq { "zv", "zv", desc = "Open tocursor" }

keyq { "<M-,>", reduceFoldLvl, desc = "Reduce Fold" }
keyq { "<M-.>", increaseFoldLvl, desc = "Increase Fold" }

keyq { "<Esc>", "<Esc>zv", mode = "i", unique = false }

vim
  .iter { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
  :each(function(key)
          keyq { "<M-" .. key .. ">", function() setFoldLvl(tonumber(key) - 1) end }
  end)
