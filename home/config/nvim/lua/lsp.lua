vim.lsp.enable({
    'gopls',
    'cmake',
    'clangd',
    'rust_analyzer',
    'efm',
    'nixd',
    'bashls',
    'ruff',
    'ty',
    'lua_ls',
    'vtsls',
    'cssls',
    'html',
    'eslint',
    'terraformls',
    'dartls'
})

vim.lsp.codelens.enable(true)

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', function()
    vim.diagnostic.jump { count = -1, float = true }
end)
vim.keymap.set('n', ']d', function()
    vim.diagnostic.jump { count = 1, float = true }
end)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', require 'telescope.builtin'.lsp_definitions, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', require 'telescope.builtin'.lsp_references, opts)
        vim.keymap.set('n', '<A-f>', function()
            -- formatting vis conform which use lsp as fallback
            require("conform").format()
        end, opts)
    end,
})
