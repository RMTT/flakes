-- format done by conform
return {
    on_attach = function(client, bufnr)
        -- Disable vtsls formatting to let Prettier/ESLint handle it
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end,
    settings = {
        typescript = {
            format = { enable = false },
        },
        javascript = {
            format = { enable = false },
        },
    },
}
