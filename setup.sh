#!/bin/bash
# Rebuild this machine's setup from the repo. Every phase is safe to re-run.
#
#   ./setup.sh packages   install packages (sudo and prompts: run it in a terminal)
#   ./setup.sh apply      stow the packages into $HOME and enable user services
#   ./setup.sh verify     check the machine matches the repo; exits 1 on any FAIL
#   ./setup.sh            all three, in that order

set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$repo"

pnpm_home="$HOME/.local/share/pnpm" # must match PNPM_HOME in bash/.bashrc

# Every top-level directory in the repo is a stow package.
stow_packages() {
  git ls-files | cut -d/ -f1 | sort -u | while read -r entry; do
    [[ -d $entry ]] && echo "$entry"
  done
}

# Names from packages.txt for one source (pacman, aur or ignore).
listed() {
  awk -v src="$1" '{ sub(/#.*/, "") } $1 == src { print $2 }' packages.txt
}

packages() {
  omarchy pkg add $(listed pacman)
  omarchy pkg aur add $(listed aur)

  # Omarchy's installer also downloads the model and enables voxtype.service.
  if [[ $(omarchy default dictation 2>/dev/null) != voxtype ]]; then
    omarchy install dictation voxtype
  fi

  # The installer appends a pnpm block to ~/.bashrc. On a fresh install that's
  # still Omarchy's file, which `apply` then replaces with bash/.bashrc.
  if [[ ! -x $pnpm_home/bin/pnpm ]]; then
    curl -fsSL https://get.pnpm.io/install.sh | sh -
  fi
  if [[ ! -x $pnpm_home/bin/cf ]]; then
    PNPM_HOME=$pnpm_home PATH="$pnpm_home/bin:$PATH" "$pnpm_home/bin/pnpm" add -g cf
  fi
}

# Move anything in $HOME that would block a link out of the way. Files identical
# to the repo's copy are just dropped; the rest go to one timestamped backup
# directory, so nothing is lost and the repo is never modified.
clear_conflicts() {
  local pkg file target backup="" moved=()
  for pkg in $(stow_packages); do
    while read -r file; do
      target="$HOME/${file#*/}"
      [[ -f $target || -L $target ]] || continue
      [[ $(readlink -f "$target") == "$repo/$file" ]] && continue
      if [[ -f $target && ! -L $target ]] && cmp -s "$target" "$repo/$file"; then
        rm "$target"
        continue
      fi
      backup=${backup:-$HOME/.local/state/dotfiles-backup/$(date +%Y%m%d-%H%M%S)}
      mkdir -p "$backup/$(dirname "${file#*/}")"
      mv "$target" "$backup/${file#*/}"
      moved+=("${file#*/}")
    done < <(git ls-files "$pkg")
  done
  if ((${#moved[@]})); then
    printf '\nMoved %d existing file(s) that differ from the repo to %s:\n' "${#moved[@]}" "$backup"
    printf '  ~/%s\n' "${moved[@]}"
    cat <<'EOF'

- Fresh install: they're Omarchy's defaults; ignore the backup.
- Existing machine: they may hold edits made while a link was broken. Compare
  with `diff <backup>/<file> <repo>/<package>/<file>`, port what you want into
  the repo, and commit.
EOF
  fi
}

apply() {
  # Without these directories, Stow folds each into one symlink into the repo,
  # and files Omarchy adds later (the io.voxtype.settings plugin, hooks it
  # installs) land in the repo.
  mkdir -p ~/.config/omarchy/plugins ~/.config/omarchy/hooks/theme-set.d

  # ssh gets --no-folding: on a machine without ~/.ssh, Stow would otherwise make
  # ~/.ssh itself a symlink into the repo, and private keys would land in git.
  clear_conflicts
  stow -t ~ $(stow_packages | grep -vx ssh)
  stow --no-folding -t ~ ssh

  # Stow manages files only; the agent socket is unit state.
  systemctl --user enable --now ssh-agent.socket

  # Install Neovim plugins at the versions in lazy-lock.json. Mason installs
  # LSPs on the first interactive launch.
  echo "Restoring Neovim plugins..."
  if ! nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1; then
    echo "Neovim plugin restore failed; open nvim and run :Lazy restore to see why." >&2
  fi
}

verify() {
  local failed=0
  ok() { echo "ok    $1"; }
  fail() { echo "FAIL  $1"; failed=1; }

  # Every tracked file must be reachable from $HOME as a link into the repo.
  local file target unlinked=0
  for pkg in $(stow_packages); do
    while read -r file; do
      target="$HOME/${file#*/}"
      if [[ $(readlink -f "$target") != "$repo/$file" ]]; then
        fail "not linked: ~/${file#*/} (fix: ./setup.sh apply)"
        unlinked=1
      fi
    done < <(git ls-files "$pkg")
  done
  ((unlinked)) || ok "every package file is linked into \$HOME"

  if [[ -d ~/.ssh && ! -L ~/.ssh ]]; then ok "~/.ssh is a real directory"; else fail "~/.ssh is missing or a symlink; it must be a real directory (fix: ./setup.sh apply)"; fi

  if systemctl --user is-enabled --quiet ssh-agent.socket && systemctl --user is-active --quiet ssh-agent.socket; then
    ok "ssh-agent.socket enabled and active"
  else
    fail "ssh-agent.socket not enabled and active (fix: ./setup.sh apply)"
  fi

  if [[ $(omarchy default dictation 2>/dev/null) == voxtype ]]; then ok "dictation backend is voxtype"; else fail "dictation backend is not voxtype (fix: ./setup.sh packages)"; fi

  local missing
  missing=$(pacman -T $(listed pacman) $(listed aur) || true)
  if [[ -z $missing ]]; then ok "listed packages installed"; else fail "missing packages: $(echo $missing) (fix: ./setup.sh packages)"; fi

  if [[ -x $pnpm_home/bin/pnpm && -x $pnpm_home/bin/cf ]]; then ok "pnpm and cf installed"; else fail "pnpm or cf missing from $pnpm_home/bin (fix: ./setup.sh packages)"; fi

  # Explicitly installed packages that neither Omarchy nor packages.txt accounts for.
  local unlisted
  unlisted=$(comm -23 <(pacman -Qqe | sort) <(
    { sed 's/#.*//' /usr/share/omarchy/install/omarchy-*.packages | tr -s ' \t' '\n'
      listed pacman; listed aur; listed ignore; } | grep -v '^$' | sort -u
  ))
  if [[ -z $unlisted ]]; then ok "no unlisted packages"; else fail "unlisted packages: $(echo $unlisted) (fix: add them to packages.txt)"; fi

  if [[ -n $(git status --porcelain) ]]; then echo "note  uncommitted changes in the repo"; fi

  return $failed
}

case "${1:-all}" in
  packages | apply | verify) "$1" ;;
  all) packages && apply && verify ;;
  *) echo "usage: $0 [packages|apply|verify]" >&2; exit 2 ;;
esac
