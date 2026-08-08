local b   = vim.b
local o   = vim.o
local fn  = vim.fn
local cmd = vim.cmd
local log = vim.log
local opt = vim.opt

local levels = log.levels

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

o.comments      = "://,f:/*,e:*/"
o.commentstring = "// %s"
o.suffixesadd   = ".odin"
cmd "compiler odin"

local function getOdinroot()
        if fn.executable "odin" == 0 then
                vim.notify("Couldn't find odin executable in PATH", levels.ERROR)
                return nil
        end

        local ps = vim.system({ "odin", "root" }, { text = true }):wait()
        if ps.code ~= 0 or ps.stdout == nil or ps.stdout == "" then
                vim.notify("Failed to retrieve ODINROOT with error: " .. ps.stderr, levels.ERROR)
                return nil
        end

        return ps.stdout:gsub("\n", "")
end

if b.odin_root == nil then b.odin_root = getOdinroot() end

if b.odin_root ~= nil then
        opt.path:append(b.odin_root .. "base")
        opt.path:append(b.odin_root .. "core")
        opt.path:append(b.odin_root .. "vendor")
        opt.path:append(b.odin_root .. "shared")
end
