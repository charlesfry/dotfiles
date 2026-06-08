-- Jupyter-in-Neovim stack:
--   molten-nvim   — run code cells against a real Jupyter kernel (rich output)
--   jupytext.nvim — open/edit .ipynb notebooks as plain markdown
--   image.nvim    — render plots inline (kitty/ghostty terminals ONLY)
-- One-time host setup (pynvim, jupyter_client, jupytext, kernels):
-- run `scripts/neovim-deps.sh`. See config/nvim/README.md. Keymaps: <leader>j.

-- Inline images need the kitty graphics protocol — kitty or ghostty, NOT
-- alacritty. Gate image.nvim (and molten's image output) on a supported term so
-- nothing errors on startup elsewhere.
local function image_terminal()
  return vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
    or vim.env.TERM_PROGRAM == "ghostty"
    or vim.env.TERM == "xterm-kitty"
    or vim.env.TERM == "ghostty"
end

return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    ft = { "python", "markdown" },
    cmd = { "MoltenInit" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = image_terminal() and "image.nvim" or "none"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = true
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Molten: init kernel" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten: eval line" },
      { "<leader>jc", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: re-eval cell" },
      { "<leader>je", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Molten: eval selection" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Molten: show output" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Molten: hide output" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Molten: delete cell" },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },
  {
    "3rd/image.nvim",
    cond = image_terminal,
    build = false,
    ft = { "markdown", "python" },
    opts = {
      backend = "kitty",
      processor = "magick_cli", -- uses the ImageMagick CLI; no luarock needed
      integrations = {
        markdown = { enabled = true, only_render_image_at_cursor = true },
      },
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = 50,
    },
  },
}
