#!/bin/bash

################################################################################
# post-install.sh
#
# Script to be run after MacOS install to set preferences and install apps.
# Shamelessly stolen from https://github.com/joshukraine/ and modified by me.
# Odds are, this won't be useful to you except as a template to build your own.
# Feel free. Licensed under the "Good Luck With That" public license.
################################################################################


# Make the echo pretty
post_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n[post-install] $fmt\\n" "$@"
}

function set_system_name () {
	echo "Setting computer name set to $COMPUTER_NAME"
	sudo scutil --set ComputerName $COMPUTER_NAME
	sudo scutil --set HostName $COMPUTER_NAME
	sudo scutil --set LocalHostName $COMPUTER_NAME
	sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
}

################################################################################
# VARIABLE DECLARATIONS
################################################################################

osname=$(uname)

export BOOTSTRAP_REPO_URL="https://github.com/khaosx/macos-setup.git"
export BOOTSTRAP_DIR=$HOME/macos-setup
export DOTFILES_DIR=$HOME/macos-setup/dotfiles
DEFAULT_COMPUTER_NAME="Lithium"
DEFAULT_TIME_ZONE="America/New_York"


################################################################################
# Make sure we're on a Mac before continuing
################################################################################

if [ "$osname" == "Linux" ]; then
  post_echo "Oops, looks like you're on a Linux machine. Please have a look at
  this Linux Bootstrap script: https://github.com/joshukraine/linux-bootstrap"
  exit 1
elif [ "$osname" != "Darwin" ]; then
  post_echo "Oops, it looks like you're using a non-UNIX system. This script
only supports MacOS. Exiting..."
  exit 1
fi

################################################################################
# Authenticate
################################################################################

sudo -v

# Keep-alive: update existing `sudo` time stamp until bootstrap has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


################################################################################
# Welcome and setup
################################################################################
clear
echo
echo "*************************************************************************"
echo "*******                                                           *******"
echo "*******                 Post Install MacOS Config                 *******"
echo "*******                                                           *******"
echo "*************************************************************************"
echo

printf "Before we get started, let's get some info about your setup.\\n"

printf "\\nBootstrap script will be cloned from:
==> %s.\\n\\n" "$BOOTSTRAP_REPO_URL"

printf "\\nEnter a name for your Mac. (Leave blank for default: %s)\\n" "$DEFAULT_COMPUTER_NAME"
read -r -p "> " COMPUTER_NAME
export COMPUTER_NAME=${COMPUTER_NAME:-$DEFAULT_COMPUTER_NAME}
# I want all hostnames to be the lowercase version of the computer name
HOST_NAME=$(echo ${COMPUTER_NAME} | tr '[:upper:]' '[:lower:]')
export HOST_NAME=${HOST_NAME:-$DEFAULT_HOST_NAME}

printf "\\nEnter your desired time zone.
To view available options run \`sudo systemsetup -listtimezones\`
(Leave blank for default: %s)\\n" "$DEFAULT_TIME_ZONE"
read -r -p "> " TIME_ZONE
export TIME_ZONE=${TIME_ZONE:-$DEFAULT_TIME_ZONE}

printf "\\nLooks good. Here's what we've got so far.\\n"
printf "Computer name:    ==> [%s]\\n" "$COMPUTER_NAME"
printf "Host name:        ==> [%s]\\n" "$HOST_NAME"
printf "Time zone:        ==> [%s]\\n" "$TIME_ZONE"

echo
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Exiting..."
  exit 1
fi

################################################################################
# 1. Install HomeBrew (we do this now to get the xcode CLI tools installed
################################################################################

post_echo "Step 1: Installing XCode CLI and setting up the Homebrew environment"

xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew analytics off
brew update
brew doctor
brew tap "caskroom/cask"
brew tap "homebrew/bundle"
brew tap "caskroom/drivers"
brew install mas

post_echo "Done!"

################################################################################
# 2. Clone  repo
################################################################################

post_echo "Step 2: Cloning macos-setup repo..."

git clone "$BOOTSTRAP_REPO_URL" "$BOOTSTRAP_DIR"

# Temp workaround for MAS sign-in issue
cp "$BOOTSTRAP_DIR/install/mas" /usr/local/bin/mas

post_echo "Done!"


################################################################################
# 3. Do some fundamental things for any system. Specific configs happen later..
################################################################################

post_echo "Step 3: Setting macOS preferences..."

sudo scutil --set ComputerName $COMPUTER_NAME
sudo scutil --set HostName $HOST_NAME
sudo scutil --set LocalHostName $HOST_NAME
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $HOST_NAME

# Set the timezone; see `systemsetup -listtimezones` for other values
systemsetup -settimezone "$TIME_ZONE" > /dev/null

# shellcheck source=/dev/null
source "$BOOTSTRAP_DIR/install/macos-defaults"

post_echo "Done!"


################################################################################
# 4. Remember when I said "Specific configs happen later.."? It's later.
################################################################################

post_echo "Step 4: Installing customizations based on machine name..."

if [ -f "$BOOTSTRAP_DIR/install/brewfiles/Brewfile.$HOST_NAME" ]; then
   cp "$BOOTSTRAP_DIR/install/brewfiles/Brewfile.$HOST_NAME" $HOME/.Brewfile
   brew doctor
   brew bundle --global
fi

if [ -f "$BOOTSTRAP_DIR/custom/$HOST_NAME" ]; then
   source "$BOOTSTRAP_DIR/custom/$HOST_NAME"
fi

post_echo "Done!"


################################################################################
# 5. Setup dotfiles
################################################################################

post_echo "Step 5: Installing dotfiles..."

source "$DOTFILES_DIR/install.sh"

post_echo "Done!"

################################################################################
# 6. Set up terminal
################################################################################

post_echo "Step 6: Setting up terminal..."

pathToTerminalPrefs="${HOME}/Library/Preferences/com.apple.Terminal.plist"
/usr/libexec/PlistBuddy -c "Copy :Window\ Settings:Basic :Window\ Settings:Basic\ Improved" ${pathToTerminalPrefs}
/usr/libexec/PlistBuddy -c "Set :Window\ Settings:Basic\ Improved:name Basic\ Improved" ${pathToTerminalPrefs}
# Close if the shell exited cleanly
/usr/libexec/PlistBuddy -c "Add :Window\ Settings:Basic\ Improved:shellExitAction integer 1" ${pathToTerminalPrefs}
# Make the window a bit larger
/usr/libexec/PlistBuddy -c "Add :Window\ Settings:Basic\ Improved:columnCount integer 120" ${pathToTerminalPrefs}
/usr/libexec/PlistBuddy -c "Add :Window\ Settings:Basic\ Improved:rowCount integer 70" ${pathToTerminalPrefs}
# Shell opens with: /bin/bash
defaults write com.apple.Terminal Shell -string "/bin/bash"
# Set the "Basic Improved" as the default
defaults write com.apple.Terminal "Startup Window Settings" -string "Basic Improved"
defaults write com.apple.Terminal "Default Window Settings" -string "Basic Improved"
# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

post_echo "Done!"


################################################################################
# 7. Set macOS preferences
################################################################################

post_echo "Step 7: Setting Final preferences..."

source "$BOOTSTRAP_DIR"/install/macos-dock

rm -rf "$BOOTSTRAP_DIR"

post_echo "Done!"

echo
echo "**********************************************************************"
echo "**********************************************************************"
echo "****                                                              ****"
echo "****            MacOS post-install script complete!               ****"
echo "****                Please restart your computer.                 ****"
echo "****                                                              ****"
echo "**********************************************************************"
echo "**********************************************************************"
echo
