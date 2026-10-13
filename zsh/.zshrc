# ── Options ──────────────────────────────────────────────────────────────
unsetopt menu_complete
unsetopt flowcontrol          # free Ctrl-S / Ctrl-Q

setopt globdots
setopt always_to_end
setopt auto_menu
setopt complete_in_word
setopt no_list_ambiguous
setopt auto_cd                # "dir" instead of "cd dir"
setopt interactive_comments

# ── History ──────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space      # commands starting with a space are not saved
setopt hist_verify
setopt share_history

# ── Plugin location (Homebrew on macOS, ~/.zsh on Linux) ─────────────────
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  ZSHPLUG="$HOMEBREW_PREFIX/share"
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
else
  ZSHPLUG="$HOME/.zsh"
fi

# ── Completion ───────────────────────────────────────────────────────────
# Rebuild the completion dump at most once a day (faster startup)
zmodload zsh/complist        # provides the menuselect keymap used below
autoload -Uz compinit
stale=(~/.zcompdump(N.mh+24))
if [[ ! -f ~/.zcompdump || -n $stale ]]; then compinit; else compinit -C; fi
unset stale

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── Keybindings ──────────────────────────────────────────────────────────
# Emacs keymap (EDITOR=vim would otherwise switch zsh to vi mode)
bindkey -e
bindkey '^[[H'    beginning-of-line      # Home
bindkey '^[[F'    end-of-line            # End
bindkey '^[[3~'   delete-char            # Delete
bindkey '^[[1;5D' backward-word          # Ctrl-Left
bindkey '^[[1;5C' forward-word           # Ctrl-Right
bindkey '^[[1;3D' backward-word          # Alt-Left (Ctrl-Left via Karabiner)
bindkey '^[[1;3C' forward-word           # Alt-Right (Ctrl-Right via Karabiner)
bindkey '^H'      backward-kill-word     # Ctrl-Backspace
bindkey '^[[3;5~' kill-word              # Ctrl-Delete
bindkey '^[[3;3~' kill-word              # Alt-Delete (Ctrl-Delete via Karabiner)
bindkey -M menuselect '^[[Z' reverse-menu-complete   # Shift-Tab in menu

# Stop at / - _ . when moving/deleting by word, like on Linux
WORDCHARS=${WORDCHARS//[\/\-_.]}

# ── Aliases ──────────────────────────────────────────────────────────────
if [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lla='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias vi='vim'
alias grep='grep --color=auto'

# ── Tools ────────────────────────────────────────────────────────────────
# fzf: Ctrl-R history, Ctrl-T files, Alt-C cd (Catppuccin Mocha colors)
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
  source <(fzf --zsh)
fi

(( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

# ── Plugins (syntax highlighting must be last) ───────────────────────────
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -f $ZSHPLUG/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source $ZSHPLUG/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh ]] &&
  source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
[[ -f $ZSHPLUG/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source $ZSHPLUG/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Machine-specific, untracked settings
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
