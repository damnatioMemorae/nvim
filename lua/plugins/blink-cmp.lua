return {
        "saghen/blink.cmp",
        event        = "InsertEnter",
        build        = "cargo build --release",
        dependencies = { "cushycush/quickshell-completions.nvim", "niuiic/blink-cmp-rg.nvim" },
        opts         = {
                -- snippets   = { preset = "luasnip" },
                cmdline    = { enabled = false },
                completion = {
                        keyword       = { range = "full" },
                        accept        = { auto_brackets = { enabled = true } },
                        documentation = {
                                auto_show          = true,
                                auto_show_delay_ms = 0,
                                window             = { border = Border.borderStyle, scrollbar = false },
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
                                auto_show          = function()
                                        if vim.bo.filetype == "dropbar_menu_fzf" then
                                                return false
                                        else
                                                return true
                                        end
                                end,
                                draw               = {
                                        gap        = 0,
                                        align_to   = "kind_icon",
                                        treesitter = { "lsp" },
                                        columns    = { { "kind_icon", gap = 0 }, { "label", gap = 0 }, { "source_name", gap = 0 } },
                                        components = {
                                                kind_icon   = { ellipsis = false },
                                                label       = { ellipsis = true },
                                                source_name = {
                                                        text      = function(ctx) return "   " .. ctx.source_name end,
                                                        highlight = "BlinkCmpSource",
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
                sources    = {
                        default            = { "lsp", "snippets", "path", "buffer" },
                        per_filetype       = {
                                ["rip-substitute"] = { "ripgrep", "buffer" },
                                qml                = { inherit_defaults = true, "quickshell" },
                        },
                        min_keyword_length = 0,
                        providers          = {
                                quickshell = {
                                        name         = "quick",
                                        module       = "quickshell-completions.blink",
                                        score_offset = 100,
                                },
                                lsp        = {
                                        name         = "LSP",
                                        module       = "blink.cmp.sources.lsp",
                                        opts         = { tailwind_color_icon = "██" },
                                        score_offset = 160,
                                        fallbacks    = {},
                                        async        = false,
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
                                snippets   = {
                                        name         = "snip",
                                        score_offset = -1,
                                        opts         = {
                                                show_autosnippets     = true,
                                                use_show_condition    = true,
                                                use_label_description = true,
                                                -- search_paths          = { require("quickshell-completions").get_snippet_path() },
                                        },
                                },
                                path       = {
                                        name         = "path",
                                        module       = "blink.cmp.sources.path",
                                        score_offset = 260,
                                        opts         = {
                                                trailing_slash               = true,
                                                label_trailing_slash         = true,
                                                show_hidden_files_by_default = true,
                                                get_cwd                      = vim.uv.cwd,
                                        },
                                },
                                buffer     = {
                                        name         = "buf",
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
                                omni       = {
                                        name         = "omni",
                                        module       = "blink.cmp.sources.complete_func",
                                        score_offset = 60,
                                        opts         = { disable_omnifunc = { "v:lua.vim.lsp.omnifunc" } },
                                },
                                ripgrep    = {
                                        module       = "blink-cmp-rg",
                                        name         = "rip",
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
                        ["<A-j>"]     = { "scroll_signature_down", "scroll_documentation_down" },
                        ["<A-k>"]     = { "scroll_signature_up", "scroll_documentation_up" },
                        ["<C-j>"]     = { "select_next", "fallback" },
                        ["<C-k>"]     = { "select_prev", "fallback" },
                        ["<C-Down>"]  = { "select_next", "fallback" },
                        ["<C-Up>"]    = { "select_prev", "fallback" },
                        ["<Down>"]    = { "select_next", "fallback" },
                        ["<Up>"]      = { "select_prev", "fallback" },
                        ["<C-c>"]     = { function(cmp) if cmp.is_menu_visible() then cmp.hide() else cmp.show() end end },
                        ["<C-l>"]     = { "snippet_forward" },
                        ["<C-h>"]     = { "snippet_backward" },
                        ["<C-s>"]     = { "show_signature", "hide_signature" },
                        ["<Tab>"]     = { "snippet_forward", "select_next" },
                        ["<S-Tab>"]   = { "snippet_backward", "select_prev" },
                        ["<CR>"]      = { "accept", "fallback" },
                        ["<C-Space>"] = {
                                function(cmp)
                                        if cmp.snipper_active then
                                                cmp.snippet_forward()
                                        else
                                                if cmp.is_menu_visible() then
                                                        cmp.accept()
                                                        cmp.hide()
                                                else
                                                        cmp.show()
                                                end
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
                        trigger = { enabled = false, show_on_keyword = false, show_on_insert = false },
                        window  = { direction_priority = { "n", "s" }, scrollbar = false, show_documentation = false },
                },
        },
        opts_extend  = { "sources.default", "sources.compat", "sources.completion.enabled_provider" },
        config       = function(_, opts)
                require("blink-cmp").setup(opts)

                local groups = {
                        { "KindClass",           "@class" },
                        { "KindColor",           "DevIconDss" },
                        { "KindConstant",        "@constant" },
                        { "KindConstructor",     "@constructor" },
                        { "KindEnum",            "@enum" },
                        { "KindEnumMember",      "@enumMember" },
                        { "KindEvent",           "@event" },
                        { "KindField",           "@field" },
                        { "KindFile",            "Structure" },
                        { "KindFolder",          "Directory" },
                        { "KindFunction",        "@function" },
                        { "KindInterface",       "@interface" },
                        { "KindKeyword",         "aboba" },
                        { "KindMethod",          "@method" },
                        { "KindModule",          "@module" },
                        { "KindOperator",        "@operator" },
                        { "KindProperty",        "@property" },
                        { "KindReference",       "@function.call" },
                        { "KindSnippet",         "Keyword" },
                        { "KindStruct",          "@struct" },
                        { "KindText",            "@markup" },
                        { "KindTypeParameter",   "@variable.parameter" },
                        { "KindUnit",            "@number" },
                        { "KindValue",           "@number" },
                        { "KindVariable",        "@variable" },
                        { "AbbrDeprecated",      "DiagnosticDeprecated" },

                        { "LabelDescription",    "Comment" },
                        { "LabelDetail",         "Comment" },
                        { "LabelMatch",          "Visual" },
                        { "Menu",                "Pmenu" },
                        { "MenuBorder",          "PmenuBorder" },
                        { "MenuSelection",       "pmenuSel" },
                        { "Doc",                 "NormalFloat" },
                        { "DocBorder",           "BlinkCmpDoc" },
                        { "DocSeparator",        "BlinkCmpDoc" },
                        { "SignatureHelp",       "BlinkCmpDoc" },
                        { "SignatureHelpBorder", "BlinkCmpDoc" },
                        { "Source",              "Comment" },
                        { "ScrollBarThumb",      "PmenuThumb" },
                        { "ScrollBarGutter",     "PmenuSbar" },
                }
                require("core.utils").linkHl(groups, "BlinkCmp")
        end,
}
