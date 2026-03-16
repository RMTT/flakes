function install_lazy(lazy_rtp)
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out,                            "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup("plugins", {
        performance = {
            rtp = {
                paths = { lazy_rtp }
            }
        }
    })
end

function setup(lazy_rtp)
    local utility = require('utility')

    ---- Options ----
    vim.o.mouse = 'a'
    vim.o.smartindent = true
    vim.o.cindent = true
    vim.o.tabstop = 4
    vim.o.expandtab = true
    vim.o.softtabstop = 4
    vim.o.shiftwidth = 4
    vim.o.shiftround = true
    vim.o.autowriteall = true
    vim.o.report = 0
    vim.o.number = true
    vim.o.secure = true
    vim.o.exrc = true

    vim.o.backup = true
    vim.o.backupdir = vim.fn.stdpath('data') .. '/backup'
    vim.o.backupext = '-nvimbak'

    vim.o.undofile = true
    vim.o.undodir = vim.fn.stdpath('data') .. '/undo'

    vim.o.updatecount = 100
    vim.o.directory = vim.fn.stdpath('data') .. '/swap'

    vim.o.shadafile = "NONE"

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.o.termguicolors = true

    -- make sure the dir is exist
    utility.mkdir(vim.o.backupdir)
    utility.mkdir(vim.o.undodir)
    utility.mkdir(vim.o.directory)
    utility.mkdir(vim.fn.stdpath('data') .. '/shada')

    vim.o.encoding = 'utf-8'

    vim.o.completeopt = "menu,menuone,noselect"

    -- auto-reload files when modified externally
    vim.o.autoread = true
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
        command = "if mode() != 'c' | checktime | endif",
        pattern = { "*" },
    })
    ---- end ----

    -- load lspconfig
    require('lsp')

    require('mapping')

    install_lazy(lazy_rtp)
end

return setup
