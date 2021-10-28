# MAST (macOS Ansible Setup Tool)

This repo grew out of my [(now-deprecated) script](https://github.com/khaosx/macos-setup-deprecated) for a mostly-automated setup of macOS, to include system configuration, application install, and environment configuration. The initial script was written in BASH and was remarkably stupid in its simplicity. Fast forward to now, and there are much more effective and intuitive configuration management tools, such as Ansible, which will provide the majority of the heavy lifting for configuration of the new system.

My usage of this script assumes that I'll be running this as a standalone installer for my primary workstation which acts as command and control for my devops environment. Elements of this are utilized as a role in my monolithic infrastructure role to setup other Macs in my environment that require customization.

Tested on macOS Big Sur (11.6) and Monterey (12.1)

## Prerequisites

* A Mac (either Intel- or Apple M1-based)
* macOS Big Sur (11.6) or higher, freshly installed.

## Installation (How does it, um, how does it work?)
1. Install macOS, keeping your install as close to vanilla as possible. Remember, you want to manage your config via Ansible, and waste as little time as possible doing manual configurations.
1. Log into the App Store before you run this, if you set `install_mas_apps` to TRUE.
1. In the file `post_install.sh`, modify the three lines for environment variables
    * `export BOOTSTRAP_REPO_URL...`
    * `export DEFAULT_COMPUTER_NAME...`
    * `export DEFAULT_TIME_ZONE=...` - Find your TZ with `sudo systemsetup -listtimezones\`
1. To install with a one-liner, run ```curl --remote-name https://raw.githubusercontent.com/khaosx/mast/master/post_install.sh && sh post_install.sh 2>&1 | tee ~/install.log```

## What does it do?

It pulls down a script that installs a bunch of stuff using brew and mas, and then sets up the machine to my liking.

## Post-install Tasks

There's a few things to do once the install is complete. I'll document them one of these days.

## To-Do
- [ ] Finish writing this thing!

## Resources and Inspiration
* https://github.com/joshukraine/mac-bootstrap
* https://github.com/geerlingguy/mac-dev-playbook
* https://www.freecodecamp.org/news/install-xcode-command-line-tools/
* System setup commands - https://support.apple.com/guide/remote-desktop/about-systemsetup-apd95406b8d/mac

## License

Copyright &copy; 2021 Kristopher Newman. [MIT License](https://github.com//khaosx/mast/blob/master/LICENSE.md)