-- Teach venv-selector (provided by LazyVim's python extra, bound to <leader>cv)
-- to find your Miniforge/conda envs in ~/miniforge3/envs, not just project-local
-- .venv dirs. Picking one restarts pyright/ruff against that interpreter.
-- Needs `fd` on PATH (installed via pacman-packages.sh).
return {
  {
    "linux-cultist/venv-selector.nvim",
    -- The python extra only maps <leader>cv for ft=python. Add a global one so
    -- it also works in jupytext notebooks (ft=markdown) and other buffers.
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
    opts = {
      settings = {
        search = {
          miniforge_envs = {
            command = "fd 'bin/python$' ~/miniforge3/envs --full-path --color never -E /proc",
            type = "anaconda",
          },
          miniforge_base = {
            command = "fd '/python$' ~/miniforge3/bin --full-path --color never -E /proc",
            type = "anaconda",
          },
        },
      },
    },
  },
}
