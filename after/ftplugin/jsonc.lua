local bo  = vim.bo
local fn  = vim.fn
local cmd = vim.cmd

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cmd.source(fn.stdpath "config" .. "/after/ftplugin/json.lua")
bo.commentstring = "// %s"
