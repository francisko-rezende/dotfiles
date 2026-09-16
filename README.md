# dotfiles

GNU Stow packages for an [Omarchy](https://omarchy.org) install. Each top-level
directory is a package whose contents mirror `$HOME`:

- `hypr/` — Hyprland config (Omarchy's Lua config format)
- `nvim/` — Neovim (LazyVim-based)
- `herdr/` — [herdr](https://github.com/herdrdev/herdr) terminal workspace manager config
- `omarchy/` — Omarchy shell config (`shell.json`: bar layout, idle/lock)
- `bash/` — `.bashrc` (interactive shell setup, incl. Starship init)
- `starship/` — Starship prompt config (`starship.toml`)

Terminal emulator and git config aren't tracked here — those are left as
Omarchy defaults for now. Anything else required to reproduce this setup on a
fresh machine should end up as a package here.

## Setting up on a fresh Omarchy install

1. Install `stow` (not part of the base install):

   ```
   sudo pacman -S stow
   ```

2. Clone this repo, e.g. to `~/Coding/personal/dotfiles`.

3. Stow the packages. Omarchy's installer seeds real (non-symlink) files at
   `~/.config/hypr/*.lua`, `~/.config/herdr/config.toml`,
   `~/.config/omarchy/shell.json`, `~/.bashrc`, and `~/.config/starship.toml`,
   so a plain `stow` will refuse due to conflicts. Use `--adopt` to pull those
   files into the repo, then immediately discard them with git so your
   tracked config wins:

   ```
   cd ~/Coding/personal/dotfiles
   stow --adopt -t ~ herdr hypr nvim omarchy bash starship
   git status    # should show files modified with Omarchy's defaults
   git checkout .    # discard them, restoring your tracked config
   ```

   Do the `git checkout .` right away, before committing anything else, so
   Omarchy's defaults don't get baked into history.

4. First `nvim` launch will install plugins via lazy.nvim and LSPs via Mason —
   needs network access and takes a minute.
