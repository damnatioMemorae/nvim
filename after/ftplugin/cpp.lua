local groups = {
        { "@keyword.type.cpp",                        "@keyword" },
        { "@keyword.import.cpp",                      "Preproc" },
        { "@keyword.repeat.cpp",                      "@keyword.repeat" },
        { "@keyword.return.cpp",                      "cppStatement" },
        { "@keyword.modifier.cpp",                    "@modifier" },
        { "@keyword.operator.cpp",                    "@keyword.operator" },
        { "@keyword.conditional.cpp",                 "@keyword.conditional" },

        { "@lsp.type.type.cpp",                       "@type" },
        { "@lsp.type.class.cpp",                      "@class" },
        { "@lsp.type.method.cpp",                     "@method" },
        { "@lsp.type.modifier.cpp",                   "@modifier" },
        { "@lsp.type.function.cpp",                   "@function" },
        { "@lsp.type.namespace.cpp",                  "@module" },
        { "@lsp.typemod.variable.globalScope.cpp",    "@variable" },
        { "@lsp.typemod.class.defaultLibrary.cpp",    "@class" },
        { "@lsp.typemod.variable.functionScope.cpp",  "@character" },
        { "@lsp.typemod.variable.defaultLibrary.cpp", "@variable.builtin" },
        { "@lsp.typemod.function.defaultLibrary.cpp", "@function.builtin" },
}
require("core.utils").linkHl(groups)
