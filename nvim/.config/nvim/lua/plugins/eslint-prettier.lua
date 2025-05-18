-- return {
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         eslint = {
--           settings = {
--             workingDirectories = { mode = "auto" },
--           },
--           on_attach = function(client, bufnr)
--             -- Enable formatting on save
--             vim.api.nvim_create_autocmd("BufWritePre", {
--               buffer = bufnr,
--               command = "EslintFixAll",
--             })
--           end,
--         },
--       },
--     },
--   },
--   {
--     "stevearc/conform.nvim",
--     opts = function(_, opts)
--       opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
--         javascript = { "prettier", "eslint" },
--         typescript = { "prettier", "eslint" },
--         javascriptreact = { "prettier", "eslint" },
--         typescriptreact = { "prettier", "eslint" },
--       })
--
--       -- opts.format_on_save = {
--       --   timeout_ms = 500,
--       --   lsp_fallback = true,
--       -- }
--
--       return opts
--     end,
--   },
-- }

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = { eslint = {} },
    setup = {
      eslint = function()
        require("lazyvim.util").lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
          elseif client.name == "tsserver" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    },
  },
}
