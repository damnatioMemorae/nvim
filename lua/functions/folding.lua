local api = vim.api

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local levels = {}

vim.api.nvim_create_autocmd("BufLeave", {
        callback = function(args)
                levels[args.buf] = vim.wo.foldlevel
        end,
})

vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(args)
                vim.wo.foldlevel = levels[args.buf] or 0
        end,
})

---- TEXT ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function _G.foldText()
        local start  = vim.fn.getline(vim.v.foldstart)
        local indent = start:match("^%s*") or ""
        local _icon  = Icon.Misc.folded

        local first = start
                   :gsub("^%s*", "")
                   :gsub("\t", string.rep(" ", vim.o.tabstop))

        local _last  = vim.fn.trim(vim.fn.getline(vim.v.foldend)) .. " "
        local _lines = vim.v.foldend - vim.v.foldstart + 1

        local content = { first .. " ... ", "FoldText" }
        local chunks  = { { indent }, content }

        if indent ~= "" then
                chunks = { { indent }, content }
        end

        return chunks
end

vim.o.foldtext = "v:lua.foldText()"

local range = { 0, 9 }

---- OPERATIONS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function getMaxFoldLvl()
        return vim
                   .iter(ipairs(vim.fn.range(1, api.nvim_buf_line_count(0))))
                   :map(function(lnum)
                           return vim.fn.foldlevel(lnum)
                   end)
                   :fold(0, math.max)
end

local function setFoldLvl(lvl)
        if lvl >= range[1] and lvl <= range[2] then
                vim.wo.foldlevel = lvl
        end
end

local function reduceFoldLvl()
        local lvl = tonumber(vim.wo.foldlevel) or 0

        if lvl > 0 then
                vim.wo.foldlevel = lvl - 1
        end
end

local function increaseFoldLvl()
        local lvl = tonumber(vim.wo.foldlevel) or 0

        if lvl < getMaxFoldLvl() then
                vim.wo.foldlevel = lvl + 1
        end
end

local function closeTopLvl()
        vim.cmd.normal({ "zR", bang = true })
        vim.cmd("%foldclose")
end

local function openTopLvl()
        vim.cmd.normal({ "zM", bang = true })
        vim.cmd("%foldopen")
end

---- MOVEMENT ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param winid number
---@param f fun(): any
---@return any
local function winCall(winid, f)
        if winid == 0 or winid == api.nvim_get_current_win() then
                return f()
        else
                return api.nvim_win_call(winid, f)
        end
end

---@param winid number
---@return table
local function saveView(winid)
        return winCall(winid, vim.fn.winsaveview)
end

---@param winid number
---@param lnum number
---@return number
local function foldClosed(winid, lnum)
        return winCall(winid, function()
                return vim.fn.foldclosed(lnum)
        end)
end

---@param winid number
---@param view table
local function restView(winid, view)
        winCall(winid, function()
                vim.fn.winrestview(view)
        end)
end

local function getCurLnum()
        return api.nvim_win_get_cursor(0)[1]
end

local function gotoPrevFold()
        local cnt      = vim.v.count1
        local view     = saveView(0)
        local cur_lnum = getCurLnum()
        vim.cmd("norm! m`")
        local prev_lnum
        local prev_lnum_list = {}

        while cnt > 0 do
                vim.cmd([[keepj norm! zk]])
                local t_lnum = getCurLnum()
                vim.cmd([[keepj norm! [z]])
                if t_lnum == getCurLnum() then
                        local fold_start_lnum = foldClosed(0, t_lnum)
                        if fold_start_lnum > 0 then
                                vim.cmd(("keepj norm! %dgg"):format(fold_start_lnum))
                        end
                end
                local next_lnum = getCurLnum()
                while cur_lnum > next_lnum do
                        t_lnum = next_lnum
                        table.insert(prev_lnum_list, next_lnum)
                        vim.cmd([[keepj norm! zj]])
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
                        vim.cmd(("keepj norm! %dgg"):format(cur_lnum))
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
                vim.cmd(("norm! %dgg_"):format(prev_lnum))
        end
end

local map = _G.smartMap

map({ "<A-C-Left>", "zM", desc = "Folds close all" })
map({ "<A-C-Right>", "zR", desc = "Folds open all" })
map({ "<A-Left>", "zc^", desc = "Fold close" })
map({ "<A-Right>", "zo^", desc = "Fold open" })
map({ "<A-Down>", "zj^", desc = "Fold next" })
map({ "<A-Up>", gotoPrevFold, desc = "Fold prev" })
map({ "<A-z>", closeTopLvl, desc = "Close toplevel folds" })
map({ "<A-Z>", openTopLvl, desc = "Open toplevel folds" })
map({ "zv", "zv", desc = "Open tocursor" })

map({ "<A-,>", reduceFoldLvl, desc = "Reduce Fold" })
map({ "<A-.>", increaseFoldLvl, desc = "Increase Fold" })

vim
           .iter({ "1", "2", "3", "4", "5", "6", "7", "8", "9" })
           :each(function(key)
                   map({ "<A-" .. key .. ">", function() setFoldLvl(tonumber(key) - 1) end })
           end)
