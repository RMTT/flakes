vim.lsp.config('efm', {
  init_options = { documentFormatting = true },
  settings = {
    rootMarkers = { '.git' },
    languages = {
      sh = {
        { formatCommand = 'shfmt -s', formatStdin = true }
      },
      json = {
        { formatCommand = 'jq', formatStdin = true }
      }
    }
  },
  filetypes = { 'sh', 'json' },
  single_file_support = true
}
)
