return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha",
    integrations = {
      barbar = true,
    },
  },
  config = function()
    vim.cmd.colorscheme "catppuccin"
  end
}
