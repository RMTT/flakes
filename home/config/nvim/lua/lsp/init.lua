require 'efm'
require 'nix'
require 'lua_ls'

vim.lsp.enable({
  'gopls',
  'cmake',
  'clangd',
  'rust_analyzer',
  'efm',
  'nixd',
  'bashls',
  'ruff',
  'lua_ls',
  'pyright'
})
