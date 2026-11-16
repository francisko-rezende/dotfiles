# dotfiles

GNU Stow packages for an [Omarchy](https://omarchy.org) install, plus
`setup.sh`, which rebuilds the machine from them. Each top-level directory is a
package whose contents mirror `$HOME`:

- `hypr/`: Hyprland config (Omarchy's Lua config format)
- `nvim/`: Neovim (LazyVim-based)
- `herdr/`: [herdr](https://github.com/herdrdev/herdr) terminal workspace manager config
- `omarchy/`: Omarchy shell config (`shell.json`: bar layout, idle/lock) and
  my own shell plugins (`plugins/francisko.notifications`: the notifications
  bar widget `shell.json` enables) and my `hooks/theme-set.d/10-owe-sync` hook.
  Omarchy's own sample and generated hooks, branding and themed files stay
  untracked.
- `bash/`: `.bashrc` (interactive shell setup, incl. Starship init)
- `starship/`: Starship prompt config (`starship.toml`)
- `ssh/`: `~/.ssh/config` (`AddKeysToAgent yes`, so a passphrase prompt
  caches the key in the agent instead of just unlocking it once)

`packages.txt` lists the packages installed beyond Omarchy's own. Terminal
emulator and git config aren't tracked here; those are left as Omarchy
defaults for now.

## Setting up on a fresh Omarchy install

Steps marked **(you)** need a person: a sudo password, a confirmation
window, a private key, or a new login session. An agent can run the rest.

1. **(you)** Clone over HTTPS (there's no SSH key on the machine yet):

   ```
   git clone https://github.com/francisko-rezende/dotfiles.git ~/Coding/personal/dotfiles
   ```

2. **(you)** In a terminal, install the packages. This asks for your sudo
   password and opens Omarchy's Voxtype dictation installer, which asks for
   confirmation:

   ```
   cd ~/Coding/personal/dotfiles
   ./setup.sh packages
   ```

3. Link the configs, set up Omarchy's SSH agent (gcr-ssh-agent) and install
   Neovim plugins:

   ```
   ./setup.sh apply
   ```

   Omarchy's installer creates its own default config files where these
   symlinks go, so `apply` moves any that differ from the repo into
   `~/.local/state/dotfiles-backup/<timestamp>/` and lists them. On a fresh
   install those are Omarchy's defaults and can be ignored. The repo is never
   modified.

4. **(you)** Put your SSH private key in `~/.ssh/` (never tracked here: copy or
   generate it separately), then switch the remote to SSH:

   ```
   git remote set-url origin git@github.com:francisko-rezende/dotfiles.git
   ```

5. **(you)** Log out and back in. The session reads `SSH_AUTH_SOCK` from
   `~/.config/environment.d/` only at login. After that, the first `git push` or `ssh`
   opens a dialog asking for the key's passphrase. Tick the option to remember
   it in the keyring, and it won't ask again, even after a reboot.

6. Check the result. Setup is done when this passes:

   ```
   ./setup.sh verify
   ```

   Each `FAIL` line says how to fix it. Mason installs LSPs the first time you
   open `nvim`, which needs network access and takes a minute.

## Keeping the repo in sync

Run `./setup.sh verify` after changing configs or installing packages. It
catches the two ways this machine drifts from the repo:

- **A config came unlinked.** Saving bar changes from inside the Omarchy
  shell can replace `~/.config/omarchy/shell.json` with a plain file, so
  later edits stop reaching the repo. `./setup.sh apply` re-links it and
  moves the plain file to the backup directory it prints. Diff it against the
  repo copy, port the edits you want and commit.
- **A package isn't listed.** Something installed by hand that neither
  Omarchy nor `packages.txt` accounts for. Add it to `packages.txt`.
