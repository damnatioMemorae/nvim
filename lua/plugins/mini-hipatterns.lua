local words = {
        ["colors.ivory"]     = "#dce0e8",
        ["colors.spark"]     = "#add8e6",
        ["colors.rosewater"] = "#f5e0dc",
        ["colors.flamingo"]  = "#f2cdcd",
        ["colors.pink"]      = "#f5c2e7",
        ["colors.mauve"]     = "#cba6f7",
        ["colors.red"]       = "#f38ba8",
        ["colors.maroon"]    = "#eba0ac",
        ["colors.peach"]     = "#fab387",
        ["colors.yellow"]    = "#f9e2af",
        ["colors.green"]     = "#a6e3a1",
        ["colors.teal"]      = "#94e2d5",
        ["colors.sky"]       = "#89dceb",
        ["colors.sapphire"]  = "#74c7ec",
        ["colors.blue"]      = "#89b4fa",
        ["colors.lavender"]  = "#b4befe",
        ["colors.text"]      = "#cdd6f4",
        ["colors.subtext1"]  = "#bac2de",
        ["colors.subtext0"]  = "#a6adc8",
        ["colors.overlay2"]  = "#9399b2",
        ["colors.overlay1"]  = "#7f849c",
        ["colors.overlay0"]  = "#6c7086",
        ["colors.surface2"]  = "#585b70",
        ["colors.surface1"]  = "#45475a",
        ["colors.surface0"]  = "#313244",
        ["colors.base"]      = "#1e1e2e",
        ["colors.mantle"]    = "#14141f",
        ["colors.crust1"]    = "#11111b",
        ["colors.crust0"]    = "#0e0e16",
}

local theme   = vim.g.colors_name
local module  = "colors." .. theme
local cache   = {}
local globals = { vim = vim }

local function reset()
        local colors   = require("colors." .. theme).colors
        globals.colors = colors
        globals.c      = colors
end

local function hlGroup(name, buf)
        return vim.api.nvim_buf_get_name(buf):find("kinds") and "LspKinds" .. name or name
end


local function reload()
        for k in pairs(package.loaded) do
                if k:find("^" .. module) then
                        package.loaded[k] = nil
                end
        end
        cache = {}
        require(module)
        reset()
        local colorscheme = vim.g.colors_name or theme
        colorscheme = colorscheme:find(colorscheme) and colorscheme or colorscheme
        vim.cmd.colorscheme(colorscheme)
        local hi = require("mini.hipatterns")
        for _, buf in ipairs(require("mini.hipatterns").get_enabled_buffers()) do
                hi.update(buf)
        end
end

vim.api.nvim_create_autocmd("User", {
        pattern  = "VeryLazy",
        group    = vim.api.nvim_create_augroup("colorscheme_dev", { clear = true }),
        callback = vim.schedule_wrap(reload),
})
vim.api.nvim_create_autocmd("BufWritePost", {
        group    = vim.api.nvim_create_augroup("colorscheme_dev", { clear = true }),
        pattern  = "*/lua/" .. module .. "/**.lua",
        callback = vim.schedule_wrap(reload),
})

return {
        "nvim-mini/mini.hipatterns",
        version = false,
        event   = "BufReadPre",
        opts    = function(_, opts)
                local hi = require("mini.hipatterns")

                opts.highlighters = opts.highlighters or {}

                local function wordColorGroup(_, match)
                        local hex = words[match]
                        if hex == nil then return nil end
                        return hi.compute_hex_color_group(hex, "bg")
                end

                local highlighters = {
                        hex_color  = hi.gen_highlighter.hex_color({ priority = 2000 }),
                        word_color = { pattern = "%f[%w]()%S+()%f[%W]", group = wordColorGroup },
                        hl_group   = {
                                pattern      = function(buf)
                                        return vim.api.nvim_buf_get_name(buf):find("lua/" .. module) and
                                                   '^%s*%[?"?()[%w%.@]+()"?%]?%s*='
                                end,
                                group        = function(buf, match)
                                        local api   = vim.api
                                        local get   = api.nvim_get_hl
                                        local group = hlGroup(match, buf)

                                        if group then
                                                if cache[group] == nil then
                                                        cache[group] = false
                                                        local hl = get(0, { name = group, link = false, create = false })
                                                        if not vim.tbl_isempty(hl) then
                                                                hl.fg = hl.fg or
                                                                           get(0, { name = "Normal", link = false }).fg
                                                                cache[group] = true
                                                                api.nvim_set_hl(0, group .. "Dev", hl)
                                                        end
                                                end
                                                return cache[group] and group .. "Dev" or nil
                                        end
                                end,
                                extmark_opts = { priority = 2000 },
                        },
                        hl_color   = {
                                patter = {
                                        "%f[%w]()c%.[%w_%.]+()%f[%W]",
                                        "%f[%w]()colors%.[%w_%.]+()%f[%W]",
                                        "%f[%w]()vim%.g%.terminal_color_%d+()%f[%W]",
                                },
                                group  = function(_, match)
                                        local parts = vim.split(match, ".", { plain = true })
                                        local color = vim.tbl_get(globals, unpack(parts))
                                        return type(color) == "string" and hi.compute_hex_color_group(color, "bg")
                                end,
                        },
                }

                opts.highlighters = vim.tbl_extend("keep", opts.highlighters or {}, highlighters)

                local groups = {
                        { "Note",  "@comment.note" },
                        { "Todo",  "@comment.todo" },
                        { "Hack",  "@comment.hack" },
                        { "Fixme", "@comment.error" },
                }
                vim.iter(groups):each(function(group)
                        vim.api.nvim_set_hl(0, "MiniHipatterns" .. group[1], { link = group[2] })
                end)
        end,
}
