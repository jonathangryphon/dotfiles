#!/usr/bin/env bash

echo "Installing Xcode Command Line Tools..."
xcode-select --install

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Creating /dev folder"
mkdir -p ~/dev

echo "Cloning dotfiles repo..."
git clone https://github.com/jonathangryphon/dotfiles.git ~/dev/dotfiles

echo "Running through Brewfile to install software and cli..."
brew bundle --file="$HOME/dev/dotfiles/Brewfile"

echo "Generating SSH key..."
ssh-keygen -t ed25519 -C "macbook-pro-2021"

PUBLIC_KEY=$(cat ~/.ssh/id_ed25519.pub)

echo ""
echo "=================================================="
echo " SSH KEY GENERATED — ADD TO GITHUB"
echo "=================================================="
echo ""
echo "Your public SSH key is below:"
echo ""
echo "$PUBLIC_KEY"
echo ""
echo "It has also been copied to your clipboard."
echo "$PUBLIC_KEY" | pbcopy
echo ""
echo "Opening GitHub SSH key page..."
open "https://github.com/settings/keys"
echo ""
echo "Paste the key into GitHub and you're done!"
echo "=================================================="
echo ""
echo "Bootstrap completed successfully."


echo "Done!"
