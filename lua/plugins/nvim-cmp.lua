local kind_icons = Icons.Kinds

return {
        "hrsh7th/nvim-cmp",
        enabled      = false,
        event        = { "InsertEnter" },
        dependencies = {
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-nvim-lsp-document-symbol",
                "hrsh7th/cmp-nvim-lsp-signature-help",
                "JMarkin/cmp-diag-codes",
                "lukas-reineke/cmp-rg",
                "KadoBOT/cmp-plugins",
                "ray-x/cmp-treesitter",
                -- "gbroques/cmp-variable-type",
        },
        opts         = {
                mapping    = {
                        ["<A-k>"]     = function() require("cmp").mapping.scroll_docs(-4) end,
                        ["<A-j>"]     = function() require("cmp").mapping.scroll_docs(4) end,
                        ["<C-c>"]     = function() require("cmp").mapping.abort() end,
                        ["<C-Space>"] = function() require("cmp").mapping.complete() end,
                        ["<CR>"]      = function() require("cmp").mapping.confirm({ select = true }) end,
                },
                sources    = {
                        { name = "nvim_lsp" },
                        { name = "buffer" },
                        { name = "luasnip" },
                },
                formatting = {
                        fields = { "icon", "abbr", "menu" },
                        format = function(entry, vimItem)
                                vimItem.icon = kind_icons[vimItem.kind]
                                -- vimItem.abbr = string.format("%s %s", kind_icons[vimItem.kind], vimItem.abbr)
                                -- vimItem.kind = string.format("%s %s", kind_icons[vimItem.kind], vimItem.kind)
                                vimItem.kind = ""
                                vimItem.menu = ({
                                        nvim_lsp = "LSP",
                                        buffer   = "Buf",
                                        luasnip  = "Snip",
                                })[entry.source.name]
                                return vimItem
                        end,
                },
        },
        config       = function(_, opts)
                require("cmp").setup(opts)
                local groups = {
                        -- { "CmpItemAbbrDeprecated"    , { fg = "#7E8294", bg = "NONE", strikethrough = true } },
                        -- { "CmpItemAbbrMatch"         , { fg = "#82AAFF", bg = "NONE", bold          = true } },
                        -- { "CmpItemAbbrMatchFuzzy"    , { fg = "#82AAFF", bg = "NONE", bold          = true } },
                        -- { "CmpItemMenu"              , { fg = "#C792EA", bg = "NONE", italic        = true } },
                        { "KindClass",         "@class" },
                        { "KindColor",         "DevIconDss" },
                        { "KindConstant",      "@constant" },
                        { "KindConstructor",   "@constructor" },
                        { "KindEnum",          "@enum" },
                        { "KindEnumMember",    "@enumMember" },
                        { "KindEvent",         "@event" },
                        { "KindField",         "@field" },
                        { "KindFile",          "Structure" },
                        { "KindFolder",        "Directory" },
                        { "KindFunction",      "@function" },
                        { "KindInterface",     "@interface" },
                        { "KindKeyword",       "aboba" },
                        { "KindMethod",        "@method" },
                        { "KindModule",        "@module" },
                        { "KindOperator",      "@operator" },
                        { "KindProperty",      "@property" },
                        { "KindReference",     "@function.call" },
                        { "KindSnippet",       "Keyword" },
                        { "KindStruct",        "@struct" },
                        { "KindText",          "@markup" },
                        { "KindTypeParameter", "@variable.parameter" },
                        { "KindUnit",          "@number" },
                        { "KindValue",         "@number" },
                        { "KindVariable",      "@variable" },
                }
                require("core.utils").linkHl(groups, "CmpItem")
        end,
}
