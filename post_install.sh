#!/bin/bash

################################################################################
# post-install.sh
#
# Script to be run after macOS install to set up a baseline install with ansible, python, pip, brew, and 
# mas. The script will automatically call an ansible playbook to configure the rest of the system, to 
# include settings and apps.
################################################################################

# Make sure we're on a Mac before continuing
if [ $(uname) != "Darwin" ]; then
  printf "Oops, it looks like you're using a non-macOS system. This script only supports macOS. Exiting..."
  exit 1
fi

# Authenticate via sudo and update existing `sudo` time stamp until finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Let's set up some environmental variables - you should modify these!
export BOOTSTRAP_REPO_URL="https://github.com/khaosx/mast.git"     # The repo you're using
export DEFAULT_COMPUTER_NAME="Silicon"                                           # The hostname for your "default" system
export DEFAULT_TIME_ZONE="America/New_York"                                   # Your timezone
# Don't modify past here unless you know what you're doing

# Let's get started
export BOOTSTRAP_DIR=$HOME/mast-files
export HOMEBREW_INSTALLED="false"

clear
printf "*************************************************************************\\n"
printf "*******                                                           *******\\n"
printf "*******                 macOS Ansible Setup Tool                  *******\\n"
printf "*******                                                           *******\\n"
printf "*************************************************************************\\n\\n"

printf "Checking for homebrew installation...\\n"
which -s brew  >/dev/null 2>&1
if [[ $? = 0 ]] ; then
    export HOMEBREW_INSTALLED="true"
fi

printf "Checking CPU architecture...\\n"
if [[ $(uname -p) == 'arm' ]]; then
  export APPLE_SILICON="true"
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

printf "Setting system label and name\\n"
sudo scutil --set ComputerName $COMPUTER_NAME
sudo scutil --set HostName $HOST_NAME
sudo scutil --set LocalHostName $HOST_NAME
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $HOST_NAME

printf "Setting system time zone and network time sync\\n"
sudo /usr/sbin/systemsetup -settimezone "$TIME_ZONE"  >/dev/null 2>&1
sudo /usr/sbin/systemsetup -setusingnetworktime on  >/dev/null 2>&1

if [[ $HOMEBREW_INSTALLED = "false" ]] ; then
  printf "Installing HomeBrew - Follow the prompts!\\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

printf "Setting up HomeBrew environment\\n"
# Adds homebrew environment to $path via ~/.zprofile
if [[ $APPLE_SILICON = "true" ]] ; then
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew analytics off
brew doctor

printf "Installing Python 3\\n"
brew install python3

printf "Installing Ansible\\n"
pip3 install ansible

printf "Cloning github repo\\n"
git clone "$BOOTSTRAP_REPO_URL" "$BOOTSTRAP_DIR"

printf "Running Ansible playbook\\n"
cd "$BOOTSTRAP_DIR"
ansible-playbook -i inventory main.yml

printf  "**********************************************************************\\n"
printf  "**********************************************************************\\n"
printf  "****                                                              ****\\n"
printf  "****            macOS post-install script complete!               ****\\n"
printf  "****                Please restart your computer.                 ****\\n"
printf  "****                                                              ****\\n"
printf  "**********************************************************************\\n"
printf  "**********************************************************************\\n"
exit 0