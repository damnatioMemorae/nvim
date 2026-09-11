local b      = vim.b
local v      = vim.v
local bo     = vim.bo
local uv     = vim.uv
local fn     = vim.fn
local fs     = vim.fs
local api    = vim.api
local cmd    = vim.cmd
local iter   = vim.iter
local levels = vim.log.levels

local p = require "utils.functional".predicates

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
---- HELPERS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param path string
---@param oneOf string[]
---@return boolean
local function matchesOneOf(path, oneOf)
        return iter(oneOf):any(function(_) return path:find(_, nil, true) ~= nil end)
end

---@param msg string
---@param lvl? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, lvl)
        if not lvl then lvl = "info" end
        vim.notify(msg, levels[lvl:upper()], { title = "Magnet" })
end

---@param path string
---@return string
local function fmtPathForStatusbar(path)
        local current = fs.basename(api.nvim_buf_get_name(0))
        local name    = match(fs.basename(path)) {
                [current] = function(_) return fs.basename(fs.dirname(path)) .. "/" .. _ end,
                _         = function(_) return _ end,
        }
        local max     = 30
        return #name > max and vim.trim(name:sub(1, max)) .. "…" or name
end

---- GET FILES -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@return string?
local function getAltBuffer()
        local listed_bufs = fn.getbufinfo { buflisted = 1 }
        if listed_bufs == 1 then return end
        table.sort(listed_bufs, function(a, _) return a.lastused > _.lastused end)
        local alt_buf = iter(listed_bufs)
            :find(function(_)
                    local valid       = api.nvim_buf_is_valid(_.bufnr)
                    local non_special = bo[_.bufnr].buftype == "" and _.name ~= ""
                    local not_current = api.nvim_get_current_buf() ~= _.bufnr
                    return valid and non_special and not_current
            end)
        if not alt_buf then return end
        return alt_buf.name
end

---@return string?
local function getAltOldfile()
        iter(v.oldfiles)
            :map(function(_)
                    local exists    = uv.fs_stat(_) ~= nil
                    local ignored   = matchesOneOf(_, { "/COMMIT_EDITMSG", fn.stdpath "data" })
                    local same_file = _ == api.nvim_buf_get_name(0)
                    if exists and not ignored and not same_file then return _ end
            end)
end

---@return string?
---@return string?
local function getMostChangedFile()
        local git_root = vim.system { "git", "rev-parse", "--show-toplevel" }:wait()
        if git_root.code ~= 0 or not git_root.stdout then return nil, "Not in git repo." end
        local git_root_path   = vim.trim(git_root.stdout)
        local git_ls_response = vim.system { "git", "ls-files", "--others", "--exclude-standard" }:wait()
        local new_files       = git_ls_response ~= "" and vim.split(git_ls_response.stdout, "\n") or {}
        iter(new_files)
            :each(function(_)
                    vim.system { "git", "add", "--intent-to-add", "--", _ }:wait()
            end)
        local git_response  = vim.system { "git", "-C", git_root_path, "diff", "--numstat" }:wait()
        local changed_files = vim.split(git_response.stdout, "\n", { trimempty = true })
        if #changed_files == 0 then return nil, "No files with changes found." end
        local most_changed_file = iter(changed_files)
            :fold({}, function(_, __)
                    local lines_added, lines_deleted, rel_path = __:match "(%d+)%s+(%d+)%s+(.+)"
                    local is_binary                            = not (lines_added and lines_deleted and rel_path)
                    if is_binary then return _ end
                    rel_path           = rel_path:gsub("{.+ => (.+)}", "%1")
                    local abs_path     = fs.joinpath(git_root_path, rel_path)
                    local ignored      = matchesOneOf(abs_path, { "/info.plist", "/prefs.plist", "nvim-pack-lock.json" })
                    local file_deleted = uv.fs_stat(abs_path) == nil
                    if ignored or file_deleted then return _ end
                    local lines_changed = tonumber(lines_added) + tonumber(lines_deleted)
                    if lines_changed > (_.lines or 0) then
                            _.lines = lines_changed
                            _.path  = abs_path
                    end
                    return _
            end)
        return most_changed_file.path and most_changed_file.path, nil or nil,
            "No changed file that is not ignored, deleted, or binary." ---@diagnostic disable-line: redundant-return-value
end

---- GOTO ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.gotoAltFile()
        if bo.buftype ~= "" then return notify("Cannot do that in special buffer.", "warn") end
        match(getAltBuffer() or getAltOldfile()) {
                [p._nil] = function(_) cmd.edit(_) end,
                _        = function() notify("No alt-buffer or oldfile available.", "warn") end,
        }
end

function M.gotoMostChangedFile()
        local tgt, errmsg = getMostChangedFile()
        if errmsg then return notify(errmsg, "warn") end
        match(tgt) {
                [api.nvim_buf_get_name(0)] = function() notify("Already at the most changed file.", "trace") end,
                _                          = function(_) cmd.edit(_) end,
        }
end

---- STATUSBAR -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

auq { "BufEnter", "FocusGained" } {
        desc     = "Magnet: cache most changed file for statusbar",
        group    = api.nvim_create_augroup("MagnetStatusbar", { clear = true }),
        callback = function()
                vim.defer_fn(function() b.magnetMostChangedFile = getMostChangedFile() end, 10)
        end,
}

---@return  string
function M.mostChangedFileStatusbar()
        local tgt = b.magnetMostChangedFile
        if not tgt then return "" end
        match(tgt) {
                [api.nvim_buf_get_name(0)]            = function() return "" end,
                [{ getAltBuffer(), getAltOldfile() }] = function() return "" end,
        }
        return vim.trim(fmtPathForStatusbar(tgt))
end

---@return  string
function M.altFileStatusbar()
        local alt_buf  = getAltBuffer()
        local alt_file = alt_buf or getAltOldfile()
        if not alt_file then return "" end
        return vim.trim(fmtPathForStatusbar(alt_file))
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
