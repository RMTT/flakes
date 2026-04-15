return {
    "nickjvandyke/opencode.nvim",
    version = "main", -- Latest stable release
    config = function()
        ---@type opencode.Opts
        local opencode_cmd = 'opencode --port'
        ---@type snacks.terminal.Opts
        local snacks_terminal_opts = {
            win = {
                position = 'float',
            },
        }
        vim.g.opencode_opts = {
            server = {
                start = function()
                    require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
                end,
                stop = function()
                    require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts):close()
                end,
                toggle = function()
                    require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
                end,
            },
        }

        vim.o.autoread = true -- Required for `opts.events.reload`

        -- Recommended/example keymaps
        vim.keymap.set({ "n", "x" }, "<A-a>", function() require("opencode").ask("@this: ", { submit = true }) end,
            { desc = "Ask opencode…" })
        vim.keymap.set({ "n", "t" }, "<A-c>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

        vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
            { desc = "Add range to opencode", expr = true })
        vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
            { desc = "Add line to opencode", expr = true })
    end,
}
