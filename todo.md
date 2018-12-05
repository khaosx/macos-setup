# To-Do

* ~~Fix screensaver in custom install~~
* ~~Fix homepage in Safari~~
* ~~Create plist and load via launchctl~~
* ~~When MAS is updated, remove temp fixes~~
* Document post-install checklist
* Include the following code into the custom installs
+ ```function install_osx_software () {
  cd /usr/local/ && brew bundle
  brew upgrade
  open --wait -a 1Password
  open --wait -a Dropbox
  open --wait '/usr/local/Caskroom/backblaze/latest/Backblaze Installer.app'
}
```
