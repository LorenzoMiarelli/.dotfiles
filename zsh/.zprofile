# Login shell: environment only (Ghostty and tmux start login shells on macOS)

# Homebrew (Apple Silicon, then Intel)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv zsh)"
fi

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=vim
export VISUAL=vim
