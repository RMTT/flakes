local cssls_capabilities = vim.lsp.protocol.make_client_capabilities()
cssls_capabilities.textDocument.completion.completionItem.snippetSupport = true
return {
    capabilities = cssls_capabilities,
}
