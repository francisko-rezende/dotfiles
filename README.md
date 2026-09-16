# dotfiles

GNU Stow packages for an [Omarchy](https://omarchy.org) install. Each top-level
directory is a package whose contents mirror `$HOME`:

- `hypr/` — Hyprland config (Omarchy's Lua config format)
- `nvim/` — Neovim (LazyVim-based)
- `herdr/` — [herdr](https://github.com/herdrdev/herdr) terminal workspace manager config
- `omarchy/` — Omarchy shell config (`shell.json`: bar layout, idle/lock)
- `bash/` — `.bashrc` (interactive shell setup, incl. Starship init)
- `starship/` — Starship prompt config (`starship.toml`)
- `uwsm/` — uwsm session env overrides (`env.d/50-ssh-agent.conf`: points
  `SSH_AUTH_SOCK` at the systemd `ssh-agent.socket`). Deliberately not done via
  `environment.d`: that generator never expands unit-file specifiers like
  `%t`, and while it can expand `$XDG_RUNTIME_DIR`, only if that var already
  exists in the manager's environment when the generator runs — uwsm's env.d
  sets `XDG_RUNTIME_DIR` itself first, so it doesn't rely on that
- `ssh/` — `~/.ssh/config` (`AddKeysToAgent yes`, so a passphrase prompt
  caches the key in the agent instead of just unlocking it once)

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
   stow --adopt -t ~ herdr hypr nvim omarchy bash starship uwsm
   git status    # should show files modified with Omarchy's defaults
   git checkout .    # discard them, restoring your tracked config
   ```

   Do the `git checkout .` right away, before committing anything else, so
   Omarchy's defaults don't get baked into history.

   Stow `ssh` separately, with `--no-folding`:

   ```
   stow --adopt --no-folding -t ~ ssh
   ```

   On a machine with no `~/.ssh` yet, a plain `stow ssh` would fold the
   whole thing into one symlink — `~/.ssh` itself pointing at
   `dotfiles/ssh/.ssh` — so any key you later drop in `~/.ssh/` would
   physically land inside this git repo. `--no-folding` forces Stow to make
   `~/.ssh` a real directory and only symlink `config` inside it.

4. First `nvim` launch will install plugins via lazy.nvim and LSPs via Mason —
   needs network access and takes a minute.

5. Enable the ssh-agent socket (not on by default — Stow only manages files,
   not systemd unit state, so this has to be done by hand once per machine):

   ```
   systemctl --user enable --now ssh-agent.socket
   ```

6. Log out and back in (uwsm's session env is only read at session start, not
   hot-reloaded) so `uwsm/env.d/50-ssh-agent.conf` takes effect. Then, once
   your private key itself is in place at `~/.ssh/` (never tracked here —
   copy or generate it separately), the first `git push`/`ssh` per boot will
   prompt for its passphrase once and stay cached in the agent — across every
   terminal and app — until reboot.
