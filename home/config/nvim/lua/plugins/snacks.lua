-- lazy.nvim
return {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
        terminal = {
            win = {
                position = "float", -- Set the default position to floating
                relative = "editor",
                width = 0.7,
                height = 0.7,
                border = "rounded",
                auto_close = true,
            },
        }
    },
    config = function()
        require("snacks").setup()

        vim.keymap.set({ "n", "t" }, "<A-i>", function()
            require("snacks.terminal").toggle("zsh")
        end, { noremap = true, silent = true, desc = "Toggle zsh Terminal" })

        vim.keymap.set({ "n", "t" }, "<A-g>", function()
            require("snacks.terminal").toggle("gitui")
        end, { noremap = true, silent = true, desc = "Toggle gitui" })
    end
}
