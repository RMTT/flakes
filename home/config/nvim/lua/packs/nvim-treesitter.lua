return {
    "nvim-treesitter/nvim-treesitter",
    version = 'main',
    config = function()
        require('nvim-treesitter').setup {
            install_dir = vim.fn.stdpath('data') .. '/site'
        }
        require('nvim-treesitter').install { "c", "lua", "vim", "cmake", "python", "nix", "go", "rust", "python", "cpp" }

        vim.api.nvim_create_autocmd('FileType', {
            callback = function()
                -- Enable treesitter highlighting and disable regex syntax
                pcall(vim.treesitter.start)
                -- Enable treesitter-based indentation
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
