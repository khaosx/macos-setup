#!/bin/bash

################################################################################
# post-install.sh
#
# Script to be run after MacOS install to set preferences and install apps.
# Shamelessly stolen from https://github.com/joshukraine/ and modified by me.
# Odds are, this won't be useful to you except as a template to build your own.
# Feel free. Licensed under the "Good Luck With That" public license.
################################################################################

# Make sure we're on a Mac before continuing
if [ $(uname) != "Darwin" ]; then
  printf "Oops, it looks like you're using a non-MacOS system. This script only supports MacOS. Exiting..."
  exit 1
fi

# Authenticate via sudo and update existing `sudo` time stamp until finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Let's get started
export BOOTSTRAP_REPO_URL="https://github.com/khaosx/macos-setup.git"
export BOOTSTRAP_DIR=$HOME/macos-setup
export dirAppHome=$HOME/AppTemp
clear
printf "*************************************************************************\\n"
printf "*******                                                           *******\\n"
printf "*******                 Post Install MacOS Config                 *******\\n"
printf "*******                                                           *******\\n"
printf "*************************************************************************\\n\\n"

printf "Before we get started, let's get some info about your setup.\\n"

printf "Have you signed in to the Mac App Store? (y/n)\\n"
read is-signed-in
echo
if [[ ! "$is-signed-in" =~ ^[Yy]$ ]]; then
  printf "Please sign into the Mac App Store\\n"
  exit 1
fi

# Get system name
export DEFAULT_COMPUTER_NAME="Lithium"
printf "Enter a name for your Mac. (Leave blank for default: $DEFAULT_COMPUTER_NAME)\\n"
read COMPUTER_NAME
export COMPUTER_NAME=${COMPUTER_NAME:-$DEFAULT_COMPUTER_NAME}

# I want all hostnames to be the lowercase version of the computer name
HOST_NAME=$(echo ${COMPUTER_NAME} | tr '[:upper:]' '[:lower:]')
export HOST_NAME=${HOST_NAME}

# Get time zone
export DEFAULT_TIME_ZONE="America/New_York" 
printf "Enter your desired time zone.\\n"
printf "To view available options run \`sudo systemsetup -listtimezones\`\\n"
printf "(Leave blank for default: $DEFAULT_TIME_ZONE)\\n" 
read TIME_ZONE
export TIME_ZONE=${TIME_ZONE:-$DEFAULT_TIME_ZONE}

printf "Looks good. Here's what we've got so far.\\n"
printf "Bootstrap script: ==> $BOOTSTRAP_REPO_URL\\n"
printf "Bootstrap dir:    ==> $BOOTSTRAP_DIR\\n"
printf "Computer name:    ==> $COMPUTER_NAME\\n"
printf "Host name:        ==> $HOST_NAME\\n"
printf "Time zone:        ==> $TIME_ZONE\\n"
printf "Continue? (y/n)\\n"
read CONFIRM
echo
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  printf "Exiting per user choice\\n"
  exit 1
fi

printf "Applying basic system info\\n"

printf "Setting system label and name\\n"
sudo scutil --set ComputerName $COMPUTER_NAME
sudo scutil --set HostName $HOST_NAME
sudo scutil --set LocalHostName $HOST_NAME
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $HOST_NAME

printf "Setting system time zone\\n"
sudo systemsetup -settimezone "$TIME_ZONE" > /dev/null

# Enabling location services
sudo /usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1
uuid=$(/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | cut -c22-57)
sudo /usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.$uuid LocationServicesEnabled -int 1

# Configure automatic timezone
sudo /usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
sudo /usr/bin/defaults write /private/var/db/timed/Library/Preferences/com.apple.timed.plist TMAutomaticTimeOnlyEnabled -bool YES
sudo /usr/bin/defaults write /private/var/db/timed/Library/Preferences/com.apple.timed.plist TMAutomaticTimeZoneEnabled -bool YES
sudo /usr/sbin/systemsetup -setusingnetworktime on

printf "Installing HomeBrew\\n"
echo | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"  > /dev/null

printf "Setting up HomeBrew environment\\n"
brew analytics off
brew doctor

printf "Cloning github repo\\n"
git clone "$BOOTSTRAP_REPO_URL" "$BOOTSTRAP_DIR"

printf "Loading functions\\n"
source "$BOOTSTRAP_DIR/bin/functions"

printf "Applying macOS defaults\\n"
source "$BOOTSTRAP_DIR/bin/apply_macos_defaults"

printf "Installing taps, formulas, casks, and MAS apps\\n"
export BOOTSTRAP_CUSTOM=$BOOTSTRAP_DIR/lib/systems/$HOST_NAME
if [ -f "$BOOTSTRAP_CUSTOM/brewfile" ]; then
   cp "$BOOTSTRAP_CUSTOM/brewfile" $HOME/.Brewfile
   brew bundle --global
   printf "Running bundle install again to verify"
   brew bundle --global
fi

# Copy over stubborn apps
mkdir $HOME/temp_software
mount_smbfs -N //guest@carbon/Software $HOME/temp_software

if [ "$(ls $HOME/temp_software/OSX/Apps/all)" ]; then
   cp -R $HOME/temp_software/OSX/Apps/all/* ~/Desktop
fi

if [ "$(ls $HOME/temp_software/OSX/Apps/$HOST_NAME)" ]; then
   cp -R $HOME/temp_software/OSX/Apps/$HOST_NAME/* ~/Desktop
fi

if [ "$(ls $HOME/Desktop/*.app)" ]; then
   mv $HOME/Desktop/*.app /Applications
fi

if $(which slack >/dev/null); then
    source "$HOME/Desktop/slack_init.sh"
    rm "$HOME/Desktop/slack_init.sh"
fi

umount $HOME/temp_software
rm -rf $HOME/temp_software

if [ -f "$BOOTSTRAP_CUSTOM/custom_setup" ]; then
   printf "Applying per-system customizations\\n"
   source "$BOOTSTRAP_CUSTOM/custom_setup"
fi

printf "Installing launchctl jobs\\n"

mkdir -p "$HOME/Library/LaunchAgents"
if [ -f "$BOOTSTRAP_CUSTOM/com.khaosx.dailywork.plist" ]; then
	mv "$BOOTSTRAP_CUSTOM/com.khaosx.dailywork.plist" "$HOME/Library/LaunchAgents/com.khaosx.dailywork.plist"
	printf "Found system specific daily work job - configuring.\\n"
else
	mv "$BOOTSTRAP_DIR/lib/plists/com.khaosx.dailywork_generic.plist" "$HOME/Library/LaunchAgents/com.khaosx.dailywork.plist"
	printf "No system specific daily work job found - configuring generic daemon.\\n"
fi
launchctl load ~/Library/LaunchAgents/com.khaosx.dailywork.plist

if [ -f "$BOOTSTRAP_CUSTOM/dock" ]; then
   printf "Applying dock customizations\\n"
   source "$BOOTSTRAP_CUSTOM/dock"
fi

printf "Installing dotfiles\\n"
git clone "https://github.com/khaosx/dotfiles.git" "dotfiles"
source "$BOOTSTRAP_DIR/bin/install_dotfiles"

printf "Step 7: Cleaning up...\\n"
#rm -rf "$BOOTSTRAP_DIR"

printf  "**********************************************************************"
printf  "**********************************************************************"
printf  "****                                                              ****"
printf  "****            MacOS post-install script complete!               ****"
printf  "****                Please restart your computer.                 ****"
printf  "****                                                              ****"
printf  "**********************************************************************"
printf  "**********************************************************************"