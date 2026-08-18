vim.opt_local.makeprg = [[
waybar.lua restart bottom &
]]

auq "BufWritePost" {
        command = "silent make",
}
