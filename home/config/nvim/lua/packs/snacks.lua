local current_cmd = nil
local current_term = nil

local toggle_float_term = function(next_cmd)
    local terminal = require("snacks.terminal")
    local opts = {
        win = {
            position = "float",
            border = "rounded",
        },
    }

    local next_term = terminal.get(next_cmd, opts)
    local same_cmd = current_cmd == next_cmd
    if current_cmd and current_term then
        current_term:hide()

        current_term = nil
        current_cmd = nil
    end
    if same_cmd then
        return
    end

    next_term:show()
    current_cmd = next_cmd
    current_term = next_term
end

return {
    "folke/snacks.nvim",
    config = function()
        local opts = {
            terminal = {
                win = {
                    border = "rounded",
                },
            },
        }
        require("snacks").setup(opts)

        vim.keymap.set({ "n", "t" }, "<A-i>", function()
            toggle_float_term("zsh")
        end, { noremap = true, silent = true, desc = "Toggle zsh Terminal" })

        vim.keymap.set({ "n", "t" }, "<A-g>", function()
            toggle_float_term("gitui")
        end, { noremap = true, silent = true, desc = "Toggle gitui" })
    end
}
