return {
        "chrisgrieser/nvim-rip-substitute",
        cmd  = "RipSubstitute",
        keys = {
                {
                        "<LocalLeader>w",
                        function() require("rip-substitute").sub() end,
                        mode = { "n", "x", "v" },
                        desc = "Substitute (rip-sub)",
                },
                {
                        "<LocalLeader>W",
                        function() require("rip-substitute").rememberCursorWord() end,
                        desc = "Remember cursor word (rip-sub)",
                },
        },
        opts = {
                popupWin        = {
                        title                   = "",
                        border                  = Border.borderStyle,
                        position                = "top",
                        hideSearchReplaceLabels = true,
                        hideKeymapHints         = true,
                        matchCountHlGroup       = "DiagnosticInfo",
                        noMatchHlGroup          = "DiagnosticError",
                        disabledCompletion      = true,
                },
                prefill         = {
                        normal                      = "cursorWord",
                        visual                      = "selection",
                        startInReplaceLineIfPrefill = true,
                        alsoPrefillReplaceLine      = true,
                },
                keymaps         = {
                        abort                                  = "<Esc>",
                        insertModeConfirmAndSubstituteInBuffer = "<CR>",
                        confirmAndSubstituteInBuffer           = "<CR>",
                },
                editingBehavior = { autoCaptureGroups = true },
        },
}
