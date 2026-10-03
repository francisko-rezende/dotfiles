-- The oxc extra appends oxfmt to every JS/TS filetype unconditionally, and
-- conform runs every listed formatter in sequence. Gate oxfmt on an oxfmt
-- config so prettier-only projects aren't formatted twice.
return {
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
}
