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

vim.keymap.set("i", ";a", "->")
vim.keymap.set("i", ";A", "->")

-- map Meta p to paste in insert mode
vim.keymap.set("n", "<M-p>", "<C-r>+")
vim.keymap.set("i", "<M-p>", "<C-r>+")
vim.keymap.set("i", "<C-S-v>", "<C-r>+")

-- Misc
vim.keymap.set("n", "<leader>dl", "d$")

vim.keymap.set("n", "<leader>pi", function()
  -- get current line
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]

  -- append comment if it's not already there
  if not line:match("# pyright: ignore") then
    vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { line .. "  # pyright: ignore" })
  end
end, { silent = true, desc = "Append # pyright: ignore to current line" })


