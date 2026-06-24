local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.cmdline()
        local function run(input)
                if not input or input == "" then
                        return
                end
                vim.cmd(input)
        end
        if vim.fn.mode() == "n" then
                vim.ui.input({ icon = "", prompt = "", win = { ft = "vim" }, completion = "cmdline" }, run)
        else
                vim.cmd.normal({ '"zy', bang = true })
                run(vim.fn.getreg("z"))
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
