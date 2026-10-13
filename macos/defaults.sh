#!/usr/bin/env bash
# macOS preferences. Safe to re-run. Some changes need a logout to fully apply.
set -euo pipefail

#############################
## Keyboard
#############################
# Fast key repeat (fastest values offered by System Settings). Takes effect after logout.
defaults write NSGlobalDomain KeyRepeat -int 2             # 30 ms between repeats
defaults write NSGlobalDomain InitialKeyRepeat -int 15     # 225 ms before repeating
# Holding a key repeats it instead of showing the accent popup (vim hjkl!)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# No "smart" text: quotes, dashes, double-space period, autocorrect
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

#############################
## Desktops (Spaces)
#############################
# Keep desktops in a fixed order (don't rearrange by most recent use)
defaults write com.apple.dock mru-spaces -bool false

#############################
## Finder
#############################
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
defaults write com.apple.finder FXDefaultSearchScope -string SCcf        # search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv        # list view
defaults write com.apple.finder NewWindowTarget -string PfHm             # new window = Home

# No .DS_Store files on network shares and USB drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

#############################
## Dock, screenshots
#############################
defaults write com.apple.dock autohide -bool true
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

killall Finder Dock SystemUIServer 2>/dev/null || true
# launchd does not always relaunch the Dock, and without it Cmd+Tab and
# desktop switching stop working: make sure it is back
sleep 2
pgrep -x Dock >/dev/null || launchctl kickstart "gui/$(id -u)/com.apple.Dock.agent"
echo "Done. Log out and back in for key repeat and .DS_Store settings to apply everywhere."
