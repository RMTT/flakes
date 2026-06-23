return {
    "stevearc/conform.nvim",

    config = function()
        require("conform").setup({
            formatters_by_ft = {
                javascript = { "prettier" },
                typescript = { "prettier" },
                json = { "jq" },
                terraform = { "terraform_fmt" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
        })
    end
}
