-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Seamless <C-h/j/k/l> window navigation with herdr panes (vim-tmux-navigator
-- style). Try moving to a vim split first; if the window number doesn't
-- change (we're at the edge), ask herdr to move pane focus instead. herdr's
-- ctrl+h/j/k/l bindings (see the herdr package's config.toml + navigate.sh)
-- mirror this: they forward the raw key back into a focused Neovim pane so
-- this mapping runs, and only move panes directly for non-Neovim panes.
if vim.env.HERDR_ENV == "1" then
  local function move(direction, wincmd_key)
    local before = vim.fn.winnr()
    vim.cmd("wincmd " .. wincmd_key)
    if vim.fn.winnr() == before then
      vim.fn.jobstart({ "herdr", "pane", "focus", "--direction", direction, "--current" }, { detach = true })
    end
  end

  vim.keymap.set("n", "<C-h>", function() move("left", "h") end, { desc = "Window/herdr pane left" })
  vim.keymap.set("n", "<C-j>", function() move("down", "j") end, { desc = "Window/herdr pane down" })
  vim.keymap.set("n", "<C-k>", function() move("up", "k") end, { desc = "Window/herdr pane up" })
  vim.keymap.set("n", "<C-l>", function() move("right", "l") end, { desc = "Window/herdr pane right" })
end
