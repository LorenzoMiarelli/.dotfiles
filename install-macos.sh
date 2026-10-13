#!/usr/bin/env bash
# macOS setup: brew packages, stow symlinks, tmux plugins, Karabiner, key bindings.
# Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")"
DOTFILES="$PWD"

#############################
## Homebrew packages
#############################
if ! command -v brew >/dev/null; then
    echo "Install Homebrew first: https://brew.sh" && exit 1
fi
brew install stow tmux vim starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting
brew install --cask font-fira-code-nerd-font
[ -d /Applications/Ghostty.app ] || brew install --cask ghostty
[ -d /Applications/Karabiner-Elements.app ] || brew install --cask karabiner-elements

#############################
## Symlinks (GNU stow)
#############################
backup="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
move_if_real() {  # move a real (non-symlink) file out of the way
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        mkdir -p "$backup" && mv "$1" "$backup/" && echo "backed up $1 -> $backup/"
    fi
}
for f in .zshrc .zprofile .vimrc .tmux.conf .gitconfig .config/starship.toml \
         .config/ghostty/config.ghostty; do
    move_if_real "$HOME/$f"
done
# Karabiner wants the whole directory symlinked (it rewrites the file atomically)
move_if_real "$HOME/.config/karabiner"

mkdir -p "$HOME/.config"
stow --no-folding -t "$HOME" zsh vim tmux git starship ghostty
stow -t "$HOME" karabiner

#############################
## tmux plugins (TPM)
#############################
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

#############################
## PC-style Home/End in native text fields
#############################
mkdir -p "$HOME/Library/KeyBindings"
cp macos/DefaultKeyBinding.dict "$HOME/Library/KeyBindings/DefaultKeyBinding.dict"

#############################
## Karabiner config
#############################
/usr/bin/python3 scripts/karabiner.py

echo "Done. Open a new terminal (or: exec zsh)."
