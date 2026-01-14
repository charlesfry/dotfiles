-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map jk to escape in insert, command, visual, and terminal modes
vim.keymap.set("i", ";l", "<Esc>")
vim.keymap.set("c", ";l", "<Esc>")
vim.keymap.set("v", ";l", "<Esc>")
vim.keymap.set("n", ";l", "<Esc>")
vim.keymap.set("t", ";l", "<C-\\><C-n>")
vim.keymap.set("i", ";L", "<Esc>")
vim.keymap.set("c", ";L", "<Esc>")
vim.keymap.set("v", ";L", "<Esc>")
vim.keymap.set("t", ";L", "<C-\\><C-n>")
vim.keymap.set("n", ";L", "<Esc>")

