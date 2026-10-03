-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = true
vim.opt.winbar = "%=%m %f"
vim.g.autoformat = true

-- In an Nx monorepo, LSP root_dir resolves to the nearest app's package.json
-- (apps/<app>/), not the workspace root. Default spec tries "lsp" first,
-- so it wins before .git gets a chance. Move .git ahead of lsp instead.
vim.g.root_spec = { { ".git" }, "lsp", "cwd" }

-- Only run prettier in projects that have a prettier config, so it doesn't
-- stack with oxfmt (see plugins/oxc.lua).
vim.g.lazyvim_prettier_needs_config = true
