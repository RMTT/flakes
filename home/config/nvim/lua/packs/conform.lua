return {
    "stevearc/conform.nvim",

    config = function()
        require("conform").setup({
            formatters_by_ft = {
                javascript = { "prettier" },
                typescript = { "prettier" },
                json = { "jq" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
        })
    end
}
