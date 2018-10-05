#!/bin/bash

################################################################################
# install.sh
#
# Symlinks the dotfiles into place in the home directory.
################################################################################

dotfiles_echo() {
  local fmt="$1"; shift
  printf "\\n[DOTFILES] $fmt\\n" "$@"
}

set -e # Terminate script if anything exits with a non-zero value

DOTFILES_DIR=$HOME/dotfiles
mkdir -p $DOTFILES_DIR

files=(
"gitconfig"
"gitignore"
"gitmessage"
)

dotfiles_echo "Installing dotfiles..."

for file in "${files[@]}"; do
  cp "$BOOTSTRAP_DIR/dotfiles/$file" $DOTFILES_DIR/
  dotfiles_echo "-> Linking $DOTFILES_DIR/$file to $HOME/.$file..."
  ln -nfs "$DOTFILES_DIR"/"$file" "$HOME"/."$file"
done
