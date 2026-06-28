return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'linrongbin16/lsp-progress.nvim', "RMTT/sops.nvim" },
    config = function()
        local opts = {
            icon_enabled = true,
            theme = "catppuccin",
            sections = {
                lualine_c = {
                    "filename",
                    function()
                        return require('sops').status()
                    end,
                },
            },
        }
        require('lualine').setup(opts)

        vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
        vim.api.nvim_create_autocmd("User", {
            group = "lualine_augroup",
            pattern = "LspProgressStatusUpdated",
            callback = require("lualine").refresh,
        })
    end
}
