return {
  'mfussenegger/nvim-dap',
  dependencies = { 'theHamsta/nvim-dap-virtual-text' },
  config = function()
    vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
    vim.keymap.set('n', '<F6>', function() require('dap').step_over() end)
    vim.keymap.set('n', '<F7>', function() require('dap').step_into() end)
    vim.keymap.set('n', '<F8>', function() require('dap').step_out() end)
    vim.keymap.set('n', '<space>b', function() require('dap').toggle_breakpoint() end)
    vim.keymap.set('n', '<space>lp',
      function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
    vim.keymap.set('n', '<space>dr', function() require('dap').repl.open() end)
    vim.keymap.set({ 'n', 'v' }, '<space>dp', function()
      require('dap.ui.widgets').preview()
    end)
    vim.keymap.set('n', '<space>df', function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.frames)
    end)
    vim.keymap.set('n', '<space>ds', function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.scopes)
    end)
  end
}
