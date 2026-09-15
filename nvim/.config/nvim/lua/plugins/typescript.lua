-- Disable the inline type inlay hints from vtsls (LazyVim's typescript extra
-- turns these on by default): both the function return type (shown after the
-- closing paren of a signature) and the inferred parameter type (shown right
-- after an unannotated parameter name, e.g. `assessment: Foo =>`). Everything
-- else (property/enum hints) stays on.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        settings = {
          typescript = {
            inlayHints = {
              functionLikeReturnTypes = { enabled = false },
              parameterTypes = { enabled = false },
            },
          },
        },
      },
    },
  },
}
