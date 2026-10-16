# Everything installed on the Mac.  Install all:  brew bundle --file ~/.dotfiles/Brewfile
# Check what is missing:  brew bundle check --verbose --file ~/.dotfiles/Brewfile
# Update this file after installing something:  edit by hand (keeps the comments)

tap "ottomatic-io/video"

# Terminal
brew "tmux"
brew "vim"
brew "starship"
brew "zoxide"
brew "fzf"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "mas"                          # App Store apps from this file

# Video
brew "ottomatic-io/video/untrunc"   # repair truncated video files
brew "yasm"

# Fonts
cask "font-fira-code-nerd-font"

# Keyboard and terminal
cask "karabiner-elements"
cask "ghostty"

# Browser, media, productivity
cask "firefox"
cask "iina"
cask "bitwarden"

# Cloud, network
cask "google-drive"
cask "nextcloud"
cask "tailscale-app"

# Hardware
cask "logi-options+"

# App Store (needs to be signed in to the App Store)
mas "Connective Plugin", id: 1428740565
mas "WhatsApp", id: 310633997

# Not available through Homebrew, install by hand:
# - DaVinci Resolve (+ Blackmagic Proxy Generator)   https://www.blackmagicdesign.com/products/davinciresolve
# - Goodnotes, DJI Assistant, Belgian eID software (eID Viewer, BEIDToken)
# - Autodesk Fusion: `brew install --cask autodesk-fusion` only runs the Autodesk
#   installer (Fusion lives in ~/Applications and updates itself), so it is not tracked here
