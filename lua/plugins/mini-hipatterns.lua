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
        ["colors.mantle0"]   = "#191927",
        ["colors.mantle1"]   = "#14141f",
        ["colors.crust1"]    = "#11111b",
        ["colors.crust0"]    = "#0e0e16",

        ["colors.teal_transparent"]   = "#273741",
        ["colors.sky_transparent"]    = "#29383c",
        ["colors.green_transparent"]  = "#2c3932",
        ["colors.yellow_transparent"] = "#3d3835",
        ["colors.red_transparent"]    = "#3c2733",
}

return {
        "nvim-mini/mini.hipatterns",
        version = false,
        event   = "BufReadPost",
        opts    = function(_, opts)
                local hi = require("mini.hipatterns")

                opts.highlighters = opts.highlighters or {}

                local function notInTsCapture(capture, groupFn)
                        return function(bufId, match, data)
                                local caps = vim.treesitter.get_captures_at_pos(bufId, data.line - 1, data.from_col - 1)
                                for _, c in ipairs(caps) do
                                        if c.capture == capture then
                                                return groupFn(bufId, match, data)
                                        end
                                end

                                return nil
                        end
                end

                local function getHighlight(cb)
                        return function(_, match)
                                return hi.compute_hex_color_group(cb(match), "bg")
                        end
                end

                local function getHexLong(match)
                        return match
                end

                local function wordColorGroup(_, match)
                        local hex = words[match]
                        if hex == nil then return nil end
                        return hi.compute_hex_color_group(hex, "bg")
                end

                local function inComment(bufnr, row, col)
                        local ok, captures = pcall(vim.treesitter.get_captures_at_pos, bufnr, row, col)
                        if not ok then
                                return false
                        end

                        for _, cap in ipairs(captures or {}) do
                                if cap.capture:match("comment") then
                                        return true
                                end
                        end

                        return false
                end

                local function hlComKeyword(_words, hl)
                        local keywords = {}

                        for _, word in ipairs(_words) do
                                keywords[word] = true
                        end

                        return {
                                pattern = "()%u+:()",
                                group   = function(bufnr, match, data)
                                        if not inComment(bufnr, data.line - 1, data.from_col) then
                                                return nil
                                        end

                                        if keywords[match:sub(1, -2)] then
                                                return hl or "Todo"
                                        end
                                end,
                        }
                end

                local highlighters = {
                        code       = {
                                pattern = "`[^`]+`",
                                group   = function(bufnr, _match, data)
                                        if not inComment(bufnr, data.line, data.from_col) then
                                                return nil
                                        end
                                        return "MiniHipatternsCode"
                                end,
                        },
                        fixme      = hlComKeyword({ "FIXME", "BUG", "ERROR" }, "MiniHipatternsFixme"),
                        hack       = hlComKeyword({ "HACK", "WARNING", "WARN", "FIX" }, "MiniHipatternsHack"),
                        todo       = hlComKeyword({ "TODO", "WIP" }, "MiniHipatternsTodo"),
                        hint       = hlComKeyword({ "HINT", "DONE" }, "MiniHipatternsHint"),
                        note       = hlComKeyword({ "NOTE", "XXX", "INFO", "DOCS", "PERF", "TEST" }, "MiniHipatternsNote"),
                        -- url        = { pattern = "https?://%S+", group = "MiniHipatternsUrl" },
                        hex_color  = { pattern = "#%x%x%x%x%x%x%f[%X]", group = getHighlight(getHexLong) },
                        word_color = { pattern = "%f[%w]()%S+()%f[%W]", group = wordColorGroup },
                }

                opts.highlighters = vim.tbl_extend("keep", opts.highlighters or {}, highlighters)

                _G.linq
                "MiniHipatterns"
                           { "Fixme", "@comment.error" }
                           { "Hack", "@comment.warning" }
                           { "Todo", "@comment.todo" }
                           { "Hint", "@comment.hint" }
                           { "Note", "@comment.note" }
                           { "Code", "@comment.code" }
                           { "Url", "@comment.url" }
        end,
}
