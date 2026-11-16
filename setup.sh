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
  sudo pacman -S --needed $(listed pacman)
  yay -S --needed $(listed aur)

  # Omarchy's installer also downloads the model and enables voxtype.service.
  if [[ $(omarchy-default-dictation 2>/dev/null) != voxtype ]]; then
    omarchy-install-dictation-voxtype
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

apply() {
  # --adopt moves live files over their repo copies, so start from a clean tree:
  # afterwards, `git diff` shows exactly what was adopted.
  if [[ -n $(git status --porcelain --untracked-files=no) ]]; then
    echo "Uncommitted changes in $repo: commit or stash them first." >&2
    exit 1
  fi

  # Without this directory, Stow folds plugins/ into one symlink into the repo,
  # and plugins Omarchy links in later (io.voxtype.settings) land in the repo.
  mkdir -p ~/.config/omarchy/plugins

  # ssh gets --no-folding: on a machine without ~/.ssh, Stow would otherwise make
  # ~/.ssh itself a symlink into the repo, and private keys would land in git.
  stow --adopt -t ~ $(stow_packages | grep -vx ssh)
  stow --adopt --no-folding -t ~ ssh

  # Stow manages files only; the agent socket is unit state.
  systemctl --user enable --now ssh-agent.socket

  # Install Neovim plugins at the versions in lazy-lock.json. Mason installs
  # LSPs on the first interactive launch.
  echo "Restoring Neovim plugins..."
  if ! nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1; then
    echo "Neovim plugin restore failed; open nvim and run :Lazy restore to see why." >&2
  fi

  if [[ -n $(git status --porcelain --untracked-files=no) ]]; then
    git status --short
    cat <<'EOF'

Stow adopted live files that differ from the repo (listed above):
- Fresh install: they're Omarchy's defaults. Discard them: git checkout -- .
- Existing machine: they're edits made while a link was broken. Review
  `git diff` and keep them.
EOF
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

  if [[ $(omarchy-default-dictation 2>/dev/null) == voxtype ]]; then ok "dictation backend is voxtype"; else fail "dictation backend is not voxtype (fix: ./setup.sh packages)"; fi

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
