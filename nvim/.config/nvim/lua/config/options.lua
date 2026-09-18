-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = true
vim.g.autoformat = true

-- In an Nx monorepo, LSP root_dir resolves to the nearest app's package.json
-- (apps/<app>/), not the workspace root. Default spec tries "lsp" first,
-- so it wins before .git gets a chance. Move .git ahead of lsp instead.
vim.g.root_spec = { { ".git" }, "lsp", "cwd" }
