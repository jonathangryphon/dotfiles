# to run script on fresh install, paste the following command into terminal
# sudo curl -fsSL https://raw.githubusercontent.com/username/dotfiles/main/bootstrap.sh | bash

#!/usr/bin/env bash
set -e

echo "=== Bootstrap starting ==="

###
# XCODE COMMAND LINE TOOLS
###
echo "Checking Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
    echo "✓ Xcode Command Line Tools already installed."
else
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait until installed
    until xcode-select -p &>/dev/null; do
        sleep 3
    done
fi

###
# HOMEBREW
###
echo "Checking Homebrew..."
if command -v brew >/dev/null 2>&1; then
    echo "✓ Homebrew already installed."
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for non-interactive shells
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
fi

###
# DEV FOLDER
###
DEV_DIR="$HOME/dev"

echo "Checking ~/dev folder..."
if [[ -d "$DEV_DIR" ]]; then
    echo "✓ ~/dev already exists."
else
    echo "Creating ~/dev folder..."
    mkdir -p "$DEV_DIR"
fi

###
# DOTFILES REPO
###
DOTFILES_DIR="$DEV_DIR/dotfiles"

echo "Checking dotfiles repo..."
if [[ -d "$DOTFILES_DIR" ]]; then
    echo "✓ Dotfiles repo already exist Creating backup and cloning."
    mv "$DOTFILES_DIR" "${DOTFILES_DIR}_backup_$(date + %s)"
fi

echo "Cloning dotfiles repo..."
git clone https://github.com/jonathangryphon/dotfiles.git "$DOTFILES_DIR"


###
# SAFE BREW BUNDLE INSTALL (IDEMPOTENT + AUTOHEAL)
###
BREWFILE="$DOTFILES_DIR/Brewfile"

echo "Running Brew bundle (with auto-repair)..."

run_brew_bundle() {
    echo ""
    echo "→ Running brew bundle..."
    if brew bundle --file="$BREWFILE"; then
        echo "✓ Brew bundle completed successfully."
        return 0
    else
        return 1
    fi
}

if ! run_brew_bundle; then
    echo "⚠️ brew bundle failed — checking for cask conflicts…"

    # Loop through each cask in the Brewfile
    grep -E '^cask ' "$BREWFILE" | awk -F\" '{print $2}' | while read -r cask; do

        echo "Testing cask: $cask"

        OUT=$(brew install --cask "$cask" 2>&1 || true)

        if echo "$OUT" | grep -q "different from the one being installed"; then
            echo "   → Fixing conflict for $cask"

            APP_PATH=$(brew info --cask "$cask" | awk '/==> / {print $3}')

            if [[ -n "$APP_PATH" ]]; then
                sudo rm -rf "/Applications/$APP_PATH.app"
            fi

            brew install --cask "$cask" || true
        fi

    done

    echo "Retrying brew bundle..."
    brew bundle --file="$BREWFILE" || echo "⚠️ Some Brewfile items failed — continuing anyway."
fi


###
# MACOS DEFAULTS
###
if [[ -f "$DOTFILES_DIR/macos-defaults.sh" ]]; then
    echo "Applying macOS defaults..."
    bash "$DOTFILES_DIR/macos-defaults.sh"
else
    echo "⚠️ macos-defaults.sh not found, skipping."
fi

###
# GIT DEFAULTS
###
git config --global url."git@github.com:".insteadOf "https://github.com/"

###
# SSH KEY
###
SSH_KEY="$HOME/.ssh/id_ed25519"

echo "Checking SSH key..."
if [[ -f "$SSH_KEY" ]]; then
    echo "✓ SSH key already exists."
else
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "macbook-pro-2021" -f "$SSH_KEY" -N ""
fi

PUBLIC_KEY=$(cat "${SSH_KEY}.pub")

echo ""
echo "=================================================="
echo " Your SSH Public Key:"
echo "=================================================="
echo "$PUBLIC_KEY"
echo ""
echo "Copying to clipboard..."
echo "$PUBLIC_KEY" | pbcopy
echo ""
echo "Opening GitHub SSH key page..."
open "https://github.com/settings/keys"
echo "=================================================="
echo "Add the key to GitHub!"
echo "=================================================="
echo ""


###
# DONE
###
echo "Bootstrap completed successfully."
echo "Done!"
