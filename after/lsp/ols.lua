local api  = vim.api
local util = require "lspconfig.util"

---@type vim.lsp.Config
return {
        cmd       = { "ols" },
        filetypes = { "odin" },
        root_dir  = function(bufnr, onDir)
                local fname = api.nvim_buf_get_name(bufnr)
                onDir(util.root_pattern("ols.json", ".git", "*.odin")(fname))
        end,
        settings  = {
                enable_format                           = true,
                enable_hover                            = true,
                enable_document_symbols                 = true,
                enable_fake_methods                     = true,
                enable_overload_resolution              = true,
                enable_reference                        = true,
                enable_document_highlights              = true,
                enable_document_links                   = true,
                enable_completion_matching              = true,
                enable_inlay_hints_params               = true,
                enable_inlay_hints_default_params       = true,
                enable_inlay_hints_implicit_return      = true,
                enable_inlay_hints_optional_result      = true,
                enable_semantic_tokens                  = false,
                enable_snippets                         = true,
                enable_procedure_snippets               = true,
                enable_checker_only_saved               = true,
                enable_checker_workspace_diagnostics    = true,
                enable_auto_import                      = true,
                enable_comp_lit_signature_help          = true,
                enable_comp_lit_signature_help_use_docs = true,
                enable_code_action_invert_if            = true,
                struct_fields_underscore_visibility     = "package",
                completion_exclude_attributes           = "@(test)",
        },
}
