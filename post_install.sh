#!/bin/bash

################################################################################
# post-install.sh
#
# Script to be run after MacOS install to set up a baseline install with ansible, python, pip, brew, and 
# mas. The script will automatically call an ansible playbook to configure the rest of the system, to 
# include settings and apps.
################################################################################

# Make sure we're on a Mac before continuing
if [ $(uname) != "Darwin" ]; then
  printf "Oops, it looks like you're using a non-MacOS system. This script only supports MacOS. Exiting..."
  exit 1
fi

# Authenticate via sudo and update existing `sudo` time stamp until finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Let's set up some environmental variables
export BOOTSTRAP_REPO_URL="https://github.com/khaosx/mast.git"
export BOOTSTRAP_DIR=$HOME/macos-setup
export DEFAULT_COMPUTER_NAME="Silicon"
export DEFAULT_TIME_ZONE="America/New_York" 

# Let's get started
clear
printf "*************************************************************************\\n"
printf "*******                                                           *******\\n"
printf "*******                 MacOS Ansible Setup Tool                  *******\\n"
printf "*******                                                           *******\\n"
printf "*************************************************************************\\n\\n"

printf "Checking for homebrew installation...\\n"
which -s brew  >/dev/null 2>&1
if [[ $? != 0 ]] ; then
    export HOMEBREW_INSTALLED="false"
else
    export HOMEBREW_INSTALLED="true"
fi

# Get system name
printf "Enter a name for your Mac. (Leave blank for default: $DEFAULT_COMPUTER_NAME)\\n"
read COMPUTER_NAME
export COMPUTER_NAME=${COMPUTER_NAME:-$DEFAULT_COMPUTER_NAME}

# I want all hostnames to be the lowercase version of the computer name
HOST_NAME=$(echo ${COMPUTER_NAME} | tr '[:upper:]' '[:lower:]')
export HOST_NAME=${HOST_NAME}

# Get time zone
printf "Enter your desired time zone.\\n"
printf "To view available options run \`sudo systemsetup -listtimezones\`\\n"
printf "(Leave blank for default: $DEFAULT_TIME_ZONE)\\n" 
read TIME_ZONE
export TIME_ZONE=${TIME_ZONE:-$DEFAULT_TIME_ZONE}

printf "Here's what we've got so far:\\n"
printf "Bootstrap script: $BOOTSTRAP_REPO_URL\\n"
printf "Bootstrap dir: $BOOTSTRAP_DIR\\n"
printf "Computer name: $COMPUTER_NAME\\n"
printf "Time zone: $TIME_ZONE\\n"
printf "Host name: $HOST_NAME\\n"
if [[ $HOMEBREW_INSTALLED = "false" ]] ; then
  printf "HomeBrew status: MISSING.\\n"
else
  printf "HomeBrew status: Installed.\\n"
fi

printf "Continue? (y/n)\\n"
read CONFIRM
echo
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  printf "Exiting per user choice\\n"
  exit 1
fi

printf "Applying basic system info\\n"

printf "  - Setting system label and name\\n"
sudo scutil --set ComputerName $COMPUTER_NAME
sudo scutil --set HostName $HOST_NAME
sudo scutil --set LocalHostName $HOST_NAME
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $HOST_NAME

printf "  - Setting system time zone and network time sync\\n"
sudo /usr/sbin/systemsetup -settimezone "$TIME_ZONE"  >/dev/null 2>&1
sudo /usr/sbin/systemsetup -setusingnetworktime on  >/dev/null 2>&1

if [[ $HOMEBREW_INSTALLED = "false" ]] ; then
  printf " - Installing HomeBrew - Follow the prompts!\\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

printf "Setting up HomeBrew environment\\n"
brew analytics off
brew doctor

printf "Cloning github repo\\n"
git clone "$BOOTSTRAP_REPO_URL" "$BOOTSTRAP_DIR"

# printf "Loading functions\\n"
# source "$BOOTSTRAP_DIR/bin/functions"
# 
# printf "Applying macOS defaults\\n"
# source "$BOOTSTRAP_DIR/bin/apply_macos_defaults"
# 
# printf "Installing taps, formulas, casks, and MAS apps\\n"
# export BOOTSTRAP_CUSTOM=$BOOTSTRAP_DIR/lib/systems/$HOST_NAME
# if [ -f "$BOOTSTRAP_CUSTOM/brewfile" ]; then
#    cp "$BOOTSTRAP_CUSTOM/brewfile" $HOME/.Brewfile
#    brew bundle --global
#    printf "Running bundle install again to verify\\n"
#    brew bundle --global
# fi
# 
# # Copy over stubborn apps
# mkdir $HOME/temp_software
# mount_smbfs -N //guest@carbon/Software $HOME/temp_software
# pip3 install slack-cleaner
# 
# if [ "$(ls $HOME/temp_software/OSX/Apps/all)" ]; then
#    cp -R $HOME/temp_software/OSX/Apps/all/* ~/Desktop
# fi
# 
# if [ "$(ls $HOME/temp_software/OSX/Apps/$HOST_NAME)" ]; then
#    cp -R $HOME/temp_software/OSX/Apps/$HOST_NAME/* ~/Desktop
# fi
# 
# if [ "$(ls $HOME/Desktop/*.app)" ]; then
#    mv $HOME/Desktop/*.app /Applications
# fi
# 
# if $(which slack >/dev/null); then
#     source "$HOME/Desktop/slack_init.sh"
#     rm "$HOME/Desktop/slack_init.sh"
# fi
# 
# umount $HOME/temp_software
# rm -rf $HOME/temp_software
# 
# if [ -f "$BOOTSTRAP_CUSTOM/custom_setup" ]; then
#    printf "Applying per-system customizations\\n"
#    source "$BOOTSTRAP_CUSTOM/custom_setup"
# fi
# 
# printf "Installing launchctl jobs\\n"
# 
# mkdir -p "$HOME/Library/LaunchAgents"
# if [ -f "$BOOTSTRAP_CUSTOM/com.khaosx.dailywork.plist" ]; then
# 	mv "$BOOTSTRAP_CUSTOM/com.khaosx.dailywork.plist" "$HOME/Library/LaunchAgents/com.khaosx.dailywork.plist"
# 	printf "Found system specific daily work job - configuring.\\n"
# else
# 	mv "$BOOTSTRAP_DIR/lib/plists/com.khaosx.dailywork_generic.plist" "$HOME/Library/LaunchAgents/com.khaosx.dailywork.plist"
# 	printf "No system specific daily work job found - configuring generic daemon.\\n"
# fi
# launchctl load ~/Library/LaunchAgents/com.khaosx.dailywork.plist
# 
# if [ -f "$BOOTSTRAP_CUSTOM/dock" ]; then
#    printf "Applying dock customizations\\n"
#    source "$BOOTSTRAP_CUSTOM/dock"
# fi
# 
# printf "Installing dotfiles\\n"
# git clone "https://github.com/khaosx/dotfiles.git" "dotfiles"
# source "$BOOTSTRAP_DIR/bin/install_dotfiles"
# 
printf "Step 7: Cleaning up...\\n"
#rm -rf "$BOOTSTRAP_DIR"

printf  "**********************************************************************\\n"
printf  "**********************************************************************\\n"
printf  "****                                                              ****\\n"
printf  "****            MacOS post-install script complete!               ****\\n"
printf  "****                Please restart your computer.                 ****\\n"
printf  "****                                                              ****\\n"
printf  "**********************************************************************\\n"
printf  "**********************************************************************\\n"