return {
  's1n7ax/nvim-window-picker',
  lazy = false,
  priority = 1000,
  version = '2.*',
  config = function()
    require 'window-picker'.setup {
      hint = 'floating-big-letter',
      -- property, you are on your own
      filter_rules = {
        include_current_win = true,
      }
    }
  end,
}
