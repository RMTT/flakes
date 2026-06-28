---- use alt+hjkl to move between windows ----
vim.keymap.set('n', '<A-h>', '<C-w>h', { noremap = true, silent = true, desc = 'Go to left window' })
vim.keymap.set('n', '<A-l>', '<C-w>l', { noremap = true, silent = true, desc = 'Go to right window' })
vim.keymap.set('n', '<A-j>', '<C-w>j', { noremap = true, silent = true, desc = 'Go to lower window' })
vim.keymap.set('n', '<A-k>', '<C-w>k', { noremap = true, silent = true, desc = 'Go to upper window' })
---- end ----

-- use alt+pn to move between buffers
vim.keymap.set('n', '<A-p>', ':bp<CR>', { noremap = true, silent = true, desc = 'Go to previous buffer' })
vim.keymap.set('n', '<A-n>', ':bn<CR>', { noremap = true, silent = true, desc = 'Go to next buffer' })
-- end

---- using <space>y[y] and <space>p to copy and paster from clipboard ----
vim.keymap.set('v', '<space>y', '"+y', { noremap = true, silent = true, desc = 'Copy selection to clipboard' })
vim.keymap.set('n', '<space>y', '"+y', { noremap = true, silent = true, desc = 'Copy motion to clipboard' })
vim.keymap.set('n', '<space>Y', '"+yy', { noremap = true, silent = true, desc = 'Copy line to clipboard' })

vim.keymap.set('n', '<space>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard after cursor' })
vim.keymap.set('n', '<space>P', '"+P', { noremap = true, silent = true, desc = 'Paste from clipboard before cursor' })
vim.keymap.set('v', '<space>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard after selection' })
vim.keymap.set('v', '<space>P', '"+P', { noremap = true, silent = true, desc = 'Paste from clipboard before selection' })
---- end ----

---- resize window
vim.keymap.set('n', '<M-=>', ':vertical resize +3<CR>',
    { noremap = true, silent = true, desc = 'increase width of windows' })
vim.keymap.set('n', '<M-->', ':vertical resize -3<CR>',
    { noremap = true, silent = true, desc = 'decrease width of windows' })


---- close buffer and window ----
vim.keymap.set('n', '<A-w>', ':bd<CR>', { noremap = true, silent = true, desc = 'Close buffer' })


-- copy location inside file
local function copy_file_location(is_visual)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':.')
    local location = ''

    if is_visual then
        local start_line = vim.fn.getpos("v")[2]
        local end_line = vim.fn.getpos(".")[2]

        if start_line > end_line then
            start_line, end_line = end_line, start_line
        end

        location = string.format('%s: L%d-L%d', filename, start_line, end_line)
    else
        location = string.format('%s: L%d', filename, vim.api.nvim_win_get_cursor(0)[1])
    end

    vim.fn.setreg('+', location)
    vim.notify('Copied ' .. location)
end

vim.keymap.set('n', '<space>go', function()
    copy_file_location(false)
end, { silent = true, desc = 'Copy file location' })

vim.keymap.set('v', '<space>go', function()
    copy_file_location(true)
end, { silent = true, desc = 'Copy file range' })
