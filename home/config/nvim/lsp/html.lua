local html_capabilities = vim.lsp.protocol.make_client_capabilities()
html_capabilities.textDocument.completion.completionItem.snippetSupport = true
return {
    capabilities = html_capabilities,
}
