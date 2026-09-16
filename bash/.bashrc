# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Starship prompt (config tracked in dotfiles: ~/.config/starship.toml)
eval "$(starship init bash)"

# Fallback in case systemd environment.d wasn't picked up by this session
: "${SSH_AUTH_SOCK:=$XDG_RUNTIME_DIR/ssh-agent.socket}"
export SSH_AUTH_SOCK

# pnpm
export PNPM_HOME='/home/francisko/.local/share/pnpm'
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
