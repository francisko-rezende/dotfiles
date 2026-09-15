-- Disable the inline return-type inlay hints from vtsls (LazyVim's typescript
-- extra turns these on by default). Everything else stays on.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        settings = {
          typescript = {
            inlayHints = {
              functionLikeReturnTypes = { enabled = false },
            },
          },
        },
      },
    },
  },
}
