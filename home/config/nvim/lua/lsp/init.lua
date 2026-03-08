require 'efm'
require 'nix'
require 'lua_ls'
require 'web'

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
  'pyright',
  'ts_ls',
  'cssls',
  'html',
  'eslint'
})
