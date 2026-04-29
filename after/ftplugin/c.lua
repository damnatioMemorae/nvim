local groups = {
        -- { "cType",                                    "Type" },
        -- { "cTypedef",                                 "TypeDef" },
        -- { "cBlock",                                   "Statement" },
        -- { "cParen",                                   "Delimiter" },
        -- { "cBracket",                                 "Delimiter" },
        -- { "cCommentStartError",                       "Comment" },
        -- { "cRepeat",                                  "Conditional" },
        -- { "cConditional",                             "Conditional" },
        -- { "cInclude",                                 "Include" },
        -- { "cDefine",                                  "Define" },
        -- { "cppModifier",                              "@modifier" },

        { "@keyword.import.c",                      "Preproc" },
        { "@keyword.directive.define.c",            "PreProc" },

        { "@lsp.typemod.variable.globalScope.c",    "@variable" },
        { "@lsp.typemod.class.defaultLibrary.c",    "@class" },
        { "@lsp.typemod.variable.functionScope.c",  "@string" },
        { "@lsp.typemod.variable.defaultLibrary.c", "@variable.builtin" },
        { "@lsp.typemod.function.defaultLibrary.c", "@function.builtin" },
}
require("core.utils").linkHl(groups)
