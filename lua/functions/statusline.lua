local status_line_gap = 2

local function getMode()
        local mode = vim.api.nvim_get_mode().mode

        local groups = {
                ["n"]  = "n",
                ["i"]  = "i",
                ["v"]  = "v",
                ["V"]  = "v",
                [""]  = "v",
                ["c"]  = "c",
                ["s"]  = "s",
                ["S"]  = "s",
                ["x"]  = "x",
                [""]  = "s",
                ["R"]  = "r",
                ["r"]  = "p",
                ["rm"] = "m",
                ["Rv"] = "v",
                ["r?"] = "c",
                ["!"]  = "s",
                ["t"]  = "t",
        }

        local group = groups[mode] or "unknown"

        return " " .. group:upper()
end

local function getBranch()
        if vim.fn.isdirectory(".git") == 0 then
                return "--"
        else
                local branch = vim.fn.systemlist("git branch --show-current")[1]
                branch       = branch:match("%w+")

                return (branch and branch ~= "") and (" " .. branch) or ""
        end
end

local function getDiff()
        if vim.fn.isdirectory(".git") == 0 then
                return ""
        else
                local file = vim.fn.expand("%:p")
                if file == "" then
                        return ""
                end

                local cmd    = "git show --shortstat -- " .. vim.fn.shellescape(file)
                local output = vim.fn.systemlist(cmd)

                if vim.v.shell_error ~= 0 or #output == 0 then
                        return "+0 ~0 -0"
                end

                local added, removed = output[1]:match("(%d+)%s+(%d+)")
                added                = tonumber(added) or 0
                removed              = tonumber(removed) or 0

                local changed = math.min(added, removed)
                -- return string.format("+%d ~%d -%d", added, changed, removed)
                return "%#DiffAdd#+" .. added .. " %#DiffChange#~" .. changed .. " %#DiffDelete#-" .. removed
        end
end

local function getModified()
        local saved = vim.bo.modified and "*" or ""

        if vim.bo.filetype == "TelescopePrompt" then
                saved = ""
        end

        return saved
end

local function getDiagnostic(severity)
        if not rawget(vim, "lsp") then
                return 0
        end

        local count = vim.diagnostic.count(0, { severity = severity })[severity]

        if count == nil then
                return 0
        end

        if count == 0 then
                return ""
        end

        return count
end

---@param tag?   string
---@param value? any
---@param noGap? boolean
local function getComponent(tag, value, noGap)
        if value == "" then
                return ""
        end

        return "%#" .. tag .. "#" .. value .. string.rep(" ", status_line_gap * (noGap and 0 or 1))
end

local function componentSeparator()
        return "%="
end

function _G.statusline()
        local severity = vim.diagnostic.severity

        return table.concat({
                -- getComponent("StatusMode", getMode()),
                getComponent("Title", getBranch()),
                getComponent("Title", getDiff()),
                componentSeparator(),
                getComponent("StatusSaved", getModified()),
                getComponent("DiagnosticSignError", getDiagnostic(severity.ERROR)),
                getComponent("DiagnosticSignWarn", getDiagnostic(severity.WARN)),
                getComponent("DiagnosticSignHint", getDiagnostic(severity.HINT)),
        })
end
