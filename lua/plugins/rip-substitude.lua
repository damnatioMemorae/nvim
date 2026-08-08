local function sub() require "rip-substitute".sub() end
local function subR() require "rip-substitute".rememberCursorWord() end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "chrisgrieser/nvim-rip-substitute",
        cmd  = "RipSubstitute",
        keys = {
                { "<LocalLeader>w", sub,  mode = { "n", "x" }, desc = "Substitute (rip-sub)" },
                { "<LocalLeader>W", subR, mode = "n",          desc = "Remember cursor word (rip-sub)" },
        },
        opts = {
                popupWin        = {
                        title                   = "",
                        border                  = Border.Default.Normal,
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
