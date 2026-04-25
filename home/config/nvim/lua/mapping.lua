---- use alt+hjkl to move between windows ----
vim.api.nvim_set_keymap('n', '<A-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w>k', { noremap = true, silent = true })
---- end ----

-- use alt+pn to move between buffers
vim.api.nvim_set_keymap('n', '<A-p>', ':bp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-n>', ':bn<CR>', { noremap = true, silent = true })
-- end

---- using <space>y[y] and <space>p to copy and paster from clipboard ----
vim.api.nvim_set_keymap('v', '<space>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<space>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<space>Y', '"+yy', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<space>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<space>P', '"+P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<space>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<space>P', '"+P', { noremap = true, silent = true })
---- end ----

---- close buffer and window ----
vim.api.nvim_set_keymap('n', '<A-w>', ':bd<CR>', { noremap = true, silent = true })


-- copy location inside file
local function copy_file_location(is_visual)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':.')
    local location = ''

    if is_visual then
        local start_line = vim.fn.getpos("'<")[2]
        local end_line = vim.fn.getpos("'>")[2]

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
