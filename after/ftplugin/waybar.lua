vim.o.makeprg = [[
waybar.lua restart bottom &
]]

auq "BufWritePost" {
        command = "silent! make",
}
