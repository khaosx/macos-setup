# MacOS Setup Helper

Script to be run after MacOS install to set preferences and install apps. Shamelessly stolen from [joshukraine](https://github.com/joshukraine/) and modified by me. Odds are, this won't be useful to you except as a template to build your own. I mean it. It's really dammed unlikely that this is going to even run. Give it a shot though. It works for me, most of the time. Feel free to fork it, but you're better off going to the above mentioned page and getting the original. Licensed under the "Good Luck With That" public license.

Tested on MacOS Mojave (10.14)

## Prerequisites

* A Mac
* with an OS
* named Lithium, Sodium, or Magnesium.
* Also, you should sign into the Mac App Store if you didn't do the iCloud setup. All mas installs will fail.

## Installation

Seriously, log into the App Store before you run this. You have been warned.

To install with a one-liner, run this:

```sh
curl --remote-name https://raw.githubusercontent.com/khaosx/macos-setup/master/post_install.sh && sh post_install.sh 2>&1 | tee ~/install.log
```

## What does it do?

It pulls down a script that installs a bunch of stuff using brew and mas, and then sets up the machine to my liking.

## Post-install Tasks

There's a few things to do once the install is complete. I'll document them one of these days.

## To-Do
[Current list of to-do's](todo.md)

## License

No copyright implied or inferred. [GLWT License](https://github.com/khaosx/macos-setup/blob/master/LICENSE)
