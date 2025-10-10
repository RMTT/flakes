return {
  "rmagatti/auto-session",
  lazy = false,

  config = function()
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

    local auto_sesison_lib = require('auto-session.lib')
    local function set_shadafile()
      local session_name = auto_sesison_lib.escape_session_name(vim.fn.getcwd())
      local shadafile = vim.fn.stdpath('data') .. '/shada/' .. session_name .. '.shada'
      vim.o.shadafile = shadafile
      vim.cmd('rshada!')
    end
    local opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      log_level = "warning",

      pre_save_cmds = { "NvimTreeClose" },
      post_restore_cmds = { set_shadafile },
      cwd_change_handling = {
        post_cwd_changed_hook = function()
          require("lualine").refresh()
        end,
      },
    }
    require("auto-session").setup(opts)
  end
}
