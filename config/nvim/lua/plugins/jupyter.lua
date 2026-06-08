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

-- molten evaluates a line/visual/range you give it; it has no concept of a
-- markdown cell. jupytext writes cells as ```python ... ``` fences, so walk the
-- buffer pairing fences from the top (robust against prose between cells) and
-- hand each block's inner line range to MoltenEvaluateRange (1-indexed).
local function for_each_cell(fn)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local in_code, start = false, nil
  for n = 1, #lines do
    if lines[n]:match("^%s*```") then
      if not in_code then
        in_code, start = true, n
      else
        if n - 1 >= start + 1 then
          fn(start + 1, n - 1)
        end
        in_code = false
      end
    end
  end
end

local function run_current_cell()
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local matched = false
  for_each_cell(function(first, last)
    if not matched and cur >= first and cur <= last then
      matched = true
      vim.fn.MoltenEvaluateRange(first, last)
    end
  end)
  if not matched then
    vim.notify("Not inside a code cell", vim.log.levels.WARN)
  end
end

local function run_all_cells()
  for_each_cell(function(first, last)
    vim.fn.MoltenEvaluateRange(first, last)
  end)
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
      { "<leader>jj", run_current_cell, desc = "Molten: run current cell" },
      { "<leader>ja", run_all_cells, desc = "Molten: run all cells" },
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
