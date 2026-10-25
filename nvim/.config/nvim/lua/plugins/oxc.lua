-- The oxc extra appends oxfmt to every JS/TS filetype unconditionally, and
-- conform runs every listed formatter in sequence. Gate oxfmt on an oxfmt
-- config so prettier-only projects aren't formatted twice.
local oxlint_markers = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }
local eslint_root_dir

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        oxfmt = {
          condition = function(_, ctx)
            return vim.fs.find(
              { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" },
              { path = ctx.filename, upward = true }
            )[1] ~= nil
          end,
        },
      },
    },
  },

  -- Keep eslint out of projects that have an oxlint config, so a project
  -- carrying both configs doesn't report every problem twice. Otherwise defer
  -- to nvim-lspconfig's own root detection.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          root_dir = function(bufnr, on_dir)
            if vim.fs.root(bufnr, oxlint_markers) then
              return
            end
            eslint_root_dir = eslint_root_dir
              or dofile(vim.api.nvim_get_runtime_file("lsp/eslint.lua", false)[1]).root_dir
            eslint_root_dir(bufnr, on_dir)
          end,
        },
      },
    },
  },
}
