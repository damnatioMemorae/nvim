return {
        "saghen/blink.cmp",
        event        = { "InsertEnter", "CmdlineEnter" },
        build        = "cargo build --release",
        dependencies = {
                { "niuiic/blink-cmp-rg.nvim" },
                {
                        "L3MON4D3/LuaSnip",
                        dependencies = {
                                "rafamadriz/friendly-snippets",
                                config = function()
                                        require("luasnip.loaders.from_vscode").lazy_load()
                                end,
                        },
                },
        },
        opts         = {
                snippets   = { preset = "luasnip" },
                completion = {
                        keyword       = { range = "full" },
                        accept        = { auto_brackets = { enabled = true } },
                        documentation = {
                                auto_show          = true,
                                auto_show_delay_ms = 200,
                                window             = {
                                        border    = Border.borderStyle,
                                        scrollbar = false,
                                },
                        },
                        trigger       = {
                                prefetch_on_insert                   = true,
                                show_in_snippet                      = false,
                                show_on_backspace                    = false,
                                show_on_backspace_in_keyword         = false,
                                show_on_backspace_after_accept       = false,
                                show_on_backspace_after_insert_enter = false,
                                show_on_insert                       = false,
                                show_on_accept_on_trigger_character  = false,
                                show_on_blocked_trigger_characters   = {},
                        },
                        list          = {
                                selection = { preselect = false, auto_insert = false },
                                cycle     = { from_bottom = true, from_top = true },
                        },
                        menu          = {
                                max_height         = 40,
                                border             = Border.borderEmpty,
                                winblend           = Config.blend,
                                scrolloff          = 4,
                                scrollbar          = false,
                                direction_priority = { "s", "n" },
                                auto_show          = true,
                                draw               = {
                                        gap        = 1,
                                        align_to   = "label",
                                        treesitter = { "lsp" },
                                        columns    = {
                                                { "kind_icon",   gap = 0 },
                                                { "label",       gap = 0 },
                                                { "source_name", gap = 0 },
                                                { "kind",        gap = 0 },
                                        },
                                        components = {
                                                kind_icon   = {
                                                        ellipsis = false,
                                                        text     = function(ctx)
                                                                if ctx.source_id == "cmdline" then return end
                                                                return ctx.kind_icon
                                                        end,
                                                },
                                                label       = {
                                                        ellipsis = true,
                                                        text     = function(ctx)
                                                                return ctx.label
                                                                -- .. ctx.label_detail
                                                                -- .. (#ctx.label_description > 0 and " " .. ctx.label_description or "")
                                                        end,
                                                        -- highlight = function(ctx)
                                                        --         local hls = {
                                                        --                 { 0, #ctx.label_description, group = "BlinkCmpLabelDescription" },
                                                        --                 { 0, #ctx.label,             group = "BlinkCmpLabelDescription" },
                                                        --         }
                                                        --
                                                        --         -- local total_length = (#ctx.label + #ctx.label_detail)
                                                        --         --            + (#ctx.label_description > 0 and #ctx.label_description + 1 or 0)
                                                        --         -- local hls          = {
                                                        --         --         { 0,          #ctx.label,   group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel" },
                                                        --         --         { #ctx.label, total_length, group = "BlinkCmpLabelDetail" },
                                                        --         -- }
                                                        --         -- for _, idx in ipairs(ctx.label_matched_indices) do
                                                        --         --         table.insert(hls,
                                                        --         --                      {
                                                        --         --                              idx,
                                                        --         --                              idx + 1,
                                                        --         --                              group =
                                                        --         --                              "BlinkCmpLabelMatch",
                                                        --         --                      })
                                                        --         -- end
                                                        --
                                                        --         return hls
                                                        -- end,
                                                },
                                                source_name = {
                                                        text = function(ctx)
                                                                if ctx.source_id == "cmdline" then return end
                                                                return ctx.source_name:sub(1, 4)
                                                        end,
                                                },
                                        },
                                },
                        },
                },
                fuzzy      = {
                        implementation    = "prefer_rust_with_warning",
                        max_typos         = 3,
                        frecency          = {
                                enabled = true,
                                path    = vim.fn.stdpath("state") .. "/blink/cmp/frecency.dat",
                        },
                        use_proximity     = true,
                        sorts             = { "exact", "score", "sort_text" },
                        prebuilt_binaries = {
                                download                = false,
                                ignore_version_mismatch = false,
                                force_version           = "1.*",
                        },
                },
                cmdline    = {
                        keymap     = { preset = "inherit" },
                        sources    = function()
                                local type = vim.fn.getcmdtype()
                                if type == "/" or type == "?" then return { "buffer" } end
                                if type == ":" or type == "@" then return { "cmdline" } end
                                return {}
                        end,
                        completion = {
                                trigger = {
                                        show_on_blocked_trigger_characters   = {},
                                        show_on_x_blocked_trigger_characters = {},
                                },
                                list    = { selection = { preselect = false, auto_insert = false } },
                                menu    = { auto_show = true },
                        },
                },
                sources    = {
                        default            = { "lsp", "snippets", "path", "buffer" },
                        per_filetype       = { ["rip-substitute"] = { "ripgrep", "buffer" } },
                        min_keyword_length = 0,
                        providers          = {
                                lsp      = {
                                        name         = "LSP",
                                        module       = "blink.cmp.sources.lsp",
                                        opts         = { tailwind_color_icon = "██" },
                                        -- max_items    = 40,
                                        score_offset = 160,
                                        fallbacks    = {},
                                        async        = false,
                                        timeout_ms   = 500,
                                        enabled      = function()
                                                if vim.bo.ft ~= "lua" then return true end
                                                local col = vim.api.nvim_win_get_cursor(0)[2]
                                                local chars_before = vim.api.nvim_get_current_line():sub(col - 2, col)
                                                local luadoc_but_not_comment = not chars_before:find("^%-%-?$")
                                                           and not chars_before:find("%s%-%-?")
                                                return luadoc_but_not_comment
                                        end,
                                        override     = {
                                                get_trigger_characters = function(self)
                                                        local trigger_characters = self:get_trigger_characters()
                                                        vim.list_extend(trigger_characters, { "\n", "\t", " " })
                                                        return trigger_characters
                                                end,
                                        },
                                },
                                snippets = {
                                        name         = "Snip",
                                        score_offset = -1,
                                        opts         = {
                                                -- clipboard_register    = "+",
                                                show_autosnippets     = true,
                                                use_show_condition    = true,
                                                use_label_description = true,
                                        },
                                },
                                path     = {
                                        name         = "Path",
                                        module       = "blink.cmp.sources.path",
                                        score_offset = 260,
                                        opts         = {
                                                trailing_slash               = true,
                                                label_trailing_slash         = true,
                                                show_hidden_files_by_default = true,
                                                get_cwd                      = vim.uv.cwd,
                                        },
                                },
                                buffer   = {
                                        name         = "Buf",
                                        score_offset = -7,
                                        max_items    = 8,
                                        opts         = { get_bufnrs = vim.api.nvim_list_bufs },
                                        --[[
                                        get_bufnrs   = function()
                                                local last_xmins       = 15
                                                local all_open_buffers = vim.fn.getbufinfo{ buflisted = 1, bufloaded = 1 }
                                                local recent_bufs      = vim.iter(all_open_buffers)
                                                           :filter(function(buf)
                                                                   local recently_used = os.time() - buf.lastused <
                                                                              (60 * last_xmins)
                                                                   local non_special = vim.bo[buf.bufnr].buftype == ""
                                                                   return recently_used and non_special
                                                           end)
                                                           :map(function(buf) return buf.bufnr end)
                                                           :totable()
                                                return recent_bufs
                                        end,
                                        --]]
                                },
                                cmdline  = { module = "blink.cmp.sources.cmdline" },
                                omni     = {
                                        name         = "Omni",
                                        module       = "blink.cmp.sources.complete_func",
                                        score_offset = 60,
                                        opts         = { disable_omnifunc = { "v:lua.vim.lsp.omnifunc" } },
                                },
                                ripgrep  = {
                                        module       = "blink-cmp-rg",
                                        name         = "RG",
                                        score_offset = 10,
                                        max_items    = 4,
                                        opts         = {
                                                prefix_min_len = 3,
                                                get_command    = function(context, prefix) ---@diagnostic disable-line: unused-local
                                                        return {
                                                                "rg",
                                                                "--no-config",
                                                                "--json",
                                                                "--word-regexp",
                                                                "--smart-case",
                                                                "--",
                                                                prefix .. "[\\w_-]+",
                                                                vim.fs.root(0, ".git") or vim.fn.getcwd(),
                                                        }
                                                end,
                                                get_prefix     = function(context)
                                                        return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or
                                                                   ""
                                                end,
                                        },
                                },
                        },
                },
                keymap     = {
                        preset        = "none",
                        ["<A-j>"]     = { "scroll_signature_down", "scroll_documentation_down", "fallback" },
                        ["<A-k>"]     = { "scroll_signature_up", "scroll_documentation_up", "fallback" },
                        ["<C-j>"]     = { "select_next", "fallback" },
                        ["<C-k>"]     = { "select_prev", "fallback" },
                        ["<C-Down>"]  = { "select_next", "fallback" },
                        ["<C-Up>"]    = { "select_prev", "fallback" },
                        ["<Down>"]    = { "select_next", "fallback" },
                        ["<Up>"]      = { "select_prev", "fallback" },
                        ["<C-c>"]     = { function(cmp) if cmp.is_menu_visible() then cmp.hide() else cmp.show() end end },
                        ["<C-l>"]     = { "snippet_forward", "fallback" },
                        ["<C-h>"]     = { "snippet_backward", "fallback" },
                        ["<C-s>"]     = { "show_signature", "hide_signature", "fallback" },
                        ["<Tab>"]     = { "snippet_forward", "select_next", "fallback" },
                        ["<S-Tab>"]   = { "snippet_backward", "select_prev", "fallback" },
                        ["<CR>"]      = { "accept", "fallback" },
                        ["<C-Space>"] = {
                                function(cmp)
                                        if cmp.is_menu_visible() then
                                                cmp.accept()
                                                cmp.hide()
                                        else
                                                cmp.show()
                                        end
                                end,
                        },
                },
                appearance = {
                        nerd_font_variant = "normal",
                        kind_icons        = Icons.Kinds,
                },
                signature  = {
                        enabled = true,
                        trigger = { enabled = false, show_on_keyword = true, show_on_insert = false },
                        window  = { direction_priority = { "s", "n" }, scrollbar = false, show_documentation = false },
                },
        },
        opts_extend  = { "sources.default", "sources.compat", "sources.completion.enabled_provider" },
        config       = function(_, opts)
                require("blink-cmp").setup(opts)

                local hl  = vim.api.nvim_set_hl
                local cmp = "BlinkCmp"

                hl(0, cmp .. "LabelDescription",    { link = "Comment" })
                hl(0, cmp .. "LabelDetail",         { link = "Comment" })
                hl(0, cmp .. "LabelMatch",          { link = "Visual" })
                hl(0, cmp .. "Menu",                { link = "Pmenu" })
                hl(0, cmp .. "MenuBorder",          { link = "Pmenu" })
                hl(0, cmp .. "MenuSelection",       { link = "pmenuSel" })
                hl(0, cmp .. "Doc",                 { link = "NormalFloat" })
                hl(0, cmp .. "DocBorder",           { link = "BlinkCmpDoc" })
                hl(0, cmp .. "DocSeparator",        { link = "BlinkCmpDoc" })
                hl(0, cmp .. "SignatureHelp",       { link = "BlinkCmpDoc" })
                hl(0, cmp .. "SignatureHelpBorder", { link = "BlinkCmpDoc" })
                hl(0, cmp .. "Source",              { link = "Comment" })
                hl(0, cmp .. "ScrollBarThumb",      { link = "PmenuThumb" })
                hl(0, cmp .. "ScrollBarGutter",     { link = "PmenuSbar" })
        end,
}
