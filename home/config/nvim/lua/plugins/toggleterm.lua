return {
  'akinsho/toggleterm.nvim',
  config = function()
    local Terminal = require('toggleterm.terminal').Terminal
    local gitui    = Terminal:new({
      cmd = "gitui",
      hidden = true,
      direction = "float",
      on_open = function(term)
        vim.cmd('startinsert!')
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<A-g>", "<C-\\><C-n><cmd>close<CR>",
          { noremap = true, silent = true })
      end,
    })
    local main     = Terminal:new({
      cmd = vim.o.shell,
      hidden = true,
      direction = "float",
      on_open = function(term)
        vim.cmd('startinsert!')
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<A-i>", "<C-\\><C-n><cmd>close<CR>",
          { noremap = true, silent = true })
      end,
    })
    local claude   = Terminal:new({
      cmd = "claude --continue",
      hidden = true,
      direction = "float",
      on_open = function(term)
        vim.cmd('startinsert!')
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<A-c>", "<C-\\><C-n><cmd>close<CR>",
          { noremap = true, silent = true })
      end,
    })

    function Gitui_toggle()
      gitui:toggle()
    end

    function MainTerm_toggle()
      main:toggle()
    end

    function ClaudeTerm_toggle()
      claude:toggle()
    end

    vim.api.nvim_set_keymap("n", "<A-g>", "<cmd>lua Gitui_toggle()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<A-i>", "<cmd>lua MainTerm_toggle()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<A-c>", "<cmd>lua ClaudeTerm_toggle()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("t", "<C-q>", "<C-\\><C-n>", { noremap = true, silent = true })
  end
}
