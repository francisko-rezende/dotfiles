# dotfiles

GNU Stow packages for an [Omarchy](https://omarchy.org) install, plus
`setup.sh`, which rebuilds the machine from them. Each top-level directory is a
package whose contents mirror `$HOME`:

- `hypr/`: Hyprland config (Omarchy's Lua config format)
- `nvim/`: Neovim (LazyVim-based)
- `herdr/`: [herdr](https://github.com/herdrdev/herdr) terminal workspace manager config
- `omarchy/`: Omarchy shell config (`shell.json`: bar layout, idle/lock) and
  my own shell plugins (`plugins/francisko.notifications`: the notifications
  bar widget `shell.json` enables)
- `bash/`: `.bashrc` (interactive shell setup, incl. Starship init)
- `starship/`: Starship prompt config (`starship.toml`)
- `uwsm/`: uwsm session env (`env.d/50-ssh-agent.conf` sets `SSH_AUTH_SOCK`;
  the file explains why it isn't done via `environment.d`)
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

3. Link the configs, enable `ssh-agent.socket` and install Neovim plugins:

   ```
   ./setup.sh apply
   ```

   Omarchy's installer creates its own default config files where these
   symlinks go, so `apply` adopts them into the repo (`stow --adopt`) and
   lists them. On a fresh install those are Omarchy's defaults: discard them
   right away, before committing anything, so they never enter history:

   ```
   git checkout -- .
   ```

4. **(you)** Put your SSH private key in `~/.ssh/` (never tracked here: copy or
   generate it separately), then switch the remote to SSH:

   ```
   git remote set-url origin git@github.com:francisko-rezende/dotfiles.git
   ```

5. **(you)** Log out and back in. uwsm reads its session env only at login, and
   `SSH_AUTH_SOCK` comes from it. After that, the first `git push` or `ssh` per
   boot asks for the key's passphrase once, and the agent keeps it until reboot.

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
  later edits stop reaching the repo. `./setup.sh apply` adopts the live file
  and re-links it. The adopted changes are your edits, so review `git diff`
  and commit them.
- **A package isn't listed.** Something installed by hand that neither
  Omarchy nor `packages.txt` accounts for. Add it to `packages.txt`.

Agents working in this repo follow `CLAUDE.md`, which covers the same rules.
