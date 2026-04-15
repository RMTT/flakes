return {
    "catppuccin/nvim",
    name = 'catppuccin',
    config = function()
        local opts = {
            flavour = "mocha",
            integrations = {
                barbar = true,
            },
        }
        require('catppuccin').setup(opts)

        vim.cmd.colorscheme "catppuccin"
    end
}
