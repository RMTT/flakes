return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    's1n7ax/nvim-window-picker',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
    }
  },
  opts = {
    defaults = {
      get_selection_window = require('window-picker').pick_window
    }
  },
  config = function(_, opts)
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<space>ff', builtin.find_files, {})
    vim.keymap.set('n', '<space>fg', builtin.live_grep, {})
    vim.keymap.set('n', '<space>fb', builtin.buffers, {})
    vim.keymap.set('n', '<space>fh', builtin.help_tags, {})

    require('telescope').setup(opts)
  end
}
