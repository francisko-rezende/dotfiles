# dotfiles

Stow packages for this Omarchy machine. `setup.sh` rebuilds the machine from
them (`packages`, `apply`, `verify`), and `packages.txt` lists what it installs.
README.md has the package list and the fresh-install steps.

Every top-level directory is a stow package, symlinked into `$HOME`, so
editing `~/.config/hypr/bindings.lua` edits this repo. `setup.sh` finds
packages through `git ls-files`, so a new package directory counts once it's
staged.

## Done means `./setup.sh verify` passes

Run it as the last step of every change: here, in a linked config under
`$HOME`, or to the machine (a package installed, a service enabled). When it
fails, bring the repo up to date with the machine:

- **not linked**: a live file was replaced by a plain one. Run
  `./setup.sh apply` (stash your own uncommitted changes first), then review
  `git diff`. The adopted changes are the user's edits made while the link
  was broken, so keep them.
- **unlisted packages**: add each one to `packages.txt` under `pacman` or
  `aur`, or under `ignore` with a comment saying how it gets installed.
- **anything else**: the line says which `setup.sh` phase fixes it.
  `packages` needs sudo and prompts, so ask the user to run that one.

Checks only cover what `verify` can see. Keep these in step by hand:

- new stow package: a line in the README's package list
- a config that starts calling a new tool: that tool's package in `packages.txt`
- machine state outside files (a systemd unit, a default set through an
  `omarchy-*` command): a step in `setup.sh packages` or `apply`, plus a check
  in `verify`
