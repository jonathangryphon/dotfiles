#!/bin/bash
set -e

echo "Applying macOS defaults..."

# --- Finder tweaks ---
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder WarnOnEmptyTrash -bool false
# defaults write com.apple.finder FXPreferredSortBy -string "Kind"
# defaults write com.apple.finder _FXSortFoldersFirst -bool true
# defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
killall Finder

# --- Dock tweaks ---
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 100
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# --- Dock app tweaks ---
dockutil --no-restart --add /System/Library/CoreServices/Finder.app
dockutil --no-restart --add /Applications/Orion.app
dockutil --no-restart --add /Applications/Spotify.app
dockutil --no-restart --add /Applications/Signal.app
dockutil --no-restart --add /Applications/WhatsApp.app
dockutil --no-restart --add "/Applications/Ente Auth.app"
dockutil --no-restart --add /Applications/Joplin.app
dockutil --no-restart --add /System/Applications/Notes.app
killall Dock

# --- Screenshot tweaks ---
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
killall SystemUIServer

echo "macOS defaults applied successfully!"
