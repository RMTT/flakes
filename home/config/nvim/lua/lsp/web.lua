local cssls_capabilities = vim.lsp.protocol.make_client_capabilities()
cssls_capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config('cssls', {
    capabilities = cssls_capabilities,
})

local html_capabilities = vim.lsp.protocol.make_client_capabilities()
html_capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config('html', {
    capabilities = html_capabilities,
})
