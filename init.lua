-- if vim.env.PROF then
--               local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
--               vim.opt.rtp:append(snacks)
--               require("snacks.profiler").startup({
--                 startup = {
--                   event = "CmdlineEnter",
--                   after = true
--                 },
--               })
--       end

require "utils.meta" ()

req
""
    "globals"
    "functions"
    "core"
