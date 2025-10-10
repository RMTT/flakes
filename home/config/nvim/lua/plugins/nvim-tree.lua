return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    's1n7ax/nvim-window-picker',
  },
  config = function(_)
    local opts = {
      sort_by = "case_sensitive",
      sync_root_with_cwd = true,
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local opts = function(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts "Open: Vertical Split")
        vim.keymap.set("n", "<C-h>", api.node.open.horizontal, opts "Open: Horizontal Split")
      end
      ,
      actions = {
        open_file = {
          window_picker = {
            enable = true,
            picker = require("window-picker").pick_window,
          }
        }
      },
      view = {
        adaptive_size = true,
      },
      git = {
        enable = true,
        ignore = false
      },
      renderer = {
        indent_markers = {
          enable = true,
          icons = {
            corner = "└",
            edge = "│",
            item = "│",
            none = " "
          },
        },
        icons = {
          show = {
            folder_arrow = false,
          }
        }
      },
    }
    vim.keymap.set("n", "<C-A-v>", "<cmd>vs<CR>")
    vim.keymap.set("n", "<C-A-h>", "<cmd>split<CR>")
    vim.keymap.set('n', '<A-d>', '<cmd>NvimTreeToggle<CR>',
      { silent = true, noremap = true })
    require("nvim-tree").setup(opts)
  end

}
