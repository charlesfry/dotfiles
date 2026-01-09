-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Ctrl+Alt+L to run :Format (LazyFormat)
vim.keymap.set('n', '<C-M-L>', ':LazyFormat<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<C-M-L>', ':LazyFormat<CR>', { noremap = true, silent = true })

-- Map jk to escape in insert, command, visual, and terminal modes
vim.keymap.set("i", ";l", "<Esc>")
vim.keymap.set("c", ";l", "<Esc>")
vim.keymap.set("v", ";l", "<Esc>")
vim.keymap.set("t", ";l", "<C-\\><C-n>")

