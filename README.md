# MAST (MacOS Ansible Setup Assistant)

This repo grew out of my (now-deprecated) script for a mostly-automated setup of MacOS, to include system configuration, application install, and environment configuration. The initial script was written in BASH and was remarkably stupid. Fast forward to now, and we have much more effective and intuitive configuration management tools, such as Ansible, which will provide the majority of the "heavy lifting" for the new system.

Tested on MacOS Mojave (10.14)

## Prerequisites

* A Mac
* with an OS
* Also, you should sign into the Mac App Store if you didn't do the iCloud setup, or all mas installs will fail.

## Installation

Seriously, log into the App Store before you run this. You have been warned.

To install with a one-liner, run this:

```sh
curl --remote-name https://raw.githubusercontent.com/khaosx/mast/master/post_install.sh && sh post_install.sh 2>&1 | tee ~/install.log
```

## What does it do?

It pulls down a script that installs a bunch of stuff using brew and mas, and then sets up the machine to my liking.

## Post-install Tasks

There's a few things to do once the install is complete. I'll document them one of these days.

## To-Do
[Current list of to-do's](todo.md)

## Resources and Inspiration
* https://github.com/joshukraine/mac-bootstrap
* https://github.com/geerlingguy/mac-dev-playbook

## License

Copyright &copy; 2021 Kristopher Newman. [MIT License](https://github.com//khaosx/mast/blob/master/LICENSE.md)