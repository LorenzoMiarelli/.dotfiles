#!/usr/bin/env bash
# macOS setup: packages, symlinks, tmux plugins, Karabiner, key bindings.
# Works without admin rights too (no Homebrew): tools go to ~/.local/bin.
# Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")"
DOTFILES="$PWD"
BIN="$HOME/.local/bin"
mkdir -p "$BIN" "$HOME/.config"
notes=()

if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv bash)"
elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv bash)"; fi

#############################
## Packages
#############################
if command -v brew >/dev/null; then
    brew install tmux vim starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting
    brew install --cask font-fira-code-nerd-font
    [ -d /Applications/Ghostty.app ] || [ -d "$HOME/Applications/Ghostty.app" ] || brew install --cask ghostty
    [ -d /Applications/Karabiner-Elements.app ] || brew install --cask karabiner-elements
else
    echo "Homebrew not found: installing user-local tools (no admin needed)"
    command -v starship >/dev/null || curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$BIN"
    command -v zoxide >/dev/null || curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    if ! command -v fzf >/dev/null; then
        [ -d "$HOME/.fzf" ] || git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --bin && ln -sf "$HOME/.fzf/bin/fzf" "$BIN/fzf"
    fi
    # .zshrc loads plugins from ~/.zsh when Homebrew is missing
    for p in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
        [ -d "$HOME/.zsh/${p#*/}" ] || git clone --depth 1 "https://github.com/$p.git" "$HOME/.zsh/${p#*/}"
    done
    mkdir -p "$HOME/Library/Fonts"
    cp -n fonts/.local/share/fonts/*.ttf "$HOME/Library/Fonts/" 2>/dev/null || true
    notes+=("No Homebrew: tmux, Ghostty and Karabiner-Elements were skipped (ask IT, or install Homebrew).")
fi

#############################
## Symlinks
#############################
backup="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
link() {  # link <repo path> <target>; real files are moved to $backup first
    local src="$DOTFILES/$1" dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$backup/$(dirname "${dst#$HOME/}")"
        mv "$dst" "$backup/${dst#$HOME/}" && echo "backed up $dst -> $backup/"
        [ "${dst#$HOME/}" = .zshrc ] && notes+=("Your old .zshrc is in $backup: move work-specific lines (proxy, PATH, tools) to ~/.zshrc.local")
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
}
for pkg in zsh vim tmux git starship ghostty; do
    while IFS= read -r f; do
        link "$pkg/$f" "$HOME/$f"
    done < <(cd "$pkg" && find . -type f ! -name .DS_Store | sed 's|^\./||')
done
# Karabiner wants the whole directory symlinked (it rewrites the file atomically)
link karabiner/.config/karabiner "$HOME/.config/karabiner"

#############################
## tmux plugins (TPM)
#############################
if command -v tmux >/dev/null; then
    [ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

#############################
## PC-style Home/End in native text fields
#############################
mkdir -p "$HOME/Library/KeyBindings"
cp macos/DefaultKeyBinding.dict "$HOME/Library/KeyBindings/DefaultKeyBinding.dict"

#############################
## Karabiner config
#############################
/usr/bin/python3 scripts/karabiner.py

echo
echo "Done. Open a new terminal (or: exec zsh -l)."
for n in "${notes[@]+"${notes[@]}"}"; do echo "NOTE: $n"; done
