# Login shell: environment only (Ghostty and tmux start login shells on macOS)

# Homebrew (macOS Apple Silicon)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=vim
export VISUAL=vim
