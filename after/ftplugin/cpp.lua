local api     = vim.api
local command = api.nvim_create_user_command

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- local cmake = require "cmake-tools"

command("CMakeRunPerf", function()
                -- cmake.run { wrap_call = { "perf", "record", "--call-graph", "dwarf" } }
        end, {})

command("CMakeRunValgrind", function()
                -- cmake.run { wrap_call = { "valgrind", "--leak-check=full", "--xml=yes", "--xml-file=valgrind.xml" } }
        end, {})

command("CMakeRunPerfCurrent", function()
                -- cmake.run_current_file { wrap_call = { "perf", "record", "--call-graph", "dwarf" } }
        end, {})

command("CMakeRunValgrindCurrent", function()
                -- cmake.run_current_file { wrap_call = { "valgrind", "--leak-check=full", "--xml=yes", "--xml-file=valgrind.xml" } }
        end, {})
