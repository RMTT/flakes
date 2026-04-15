return {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = 'v1.10.2',
    config = function()
        local opts = {
            keymap = {
                preset = 'default',
                ['<Tab>'] = { 'select_and_accept', 'fallback' },
            },
            cmdline = {
                keymap = { preset = 'inherit' },
                completion = { menu = { auto_show = true } },
            },

            appearance = {
                nerd_font_variant = 'mono'
            },

            completion = { documentation = { auto_show = true } },

            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },

            fuzzy = { implementation = "prefer_rust_with_warning" }
        }

        require('blink.cmp').setup(opts)
    end
}
