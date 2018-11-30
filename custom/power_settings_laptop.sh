#!/bin/bash

###############################################################################
# Laptop Power Options - AC                                                   #
###############################################################################

# Change default sleep from 0 to 30 minutes
sudo pmset -c sleep 30

# Irrelevant with an SSD, but pmset is an asshole about sleep settings.
sudo pmset -c disksleep 30

# Set display sleep
sudo pmset -c displaysleep 25

# Turn on powernap
sudo pmset -c powernap 1

# Set bounds for standby -> hibernate
sudo pmset -c standbydelayhigh 86400
sudo pmset -c standbydelaylow 86400

# Turn off hibernate
sudo pmset -c hibernatemode 0

# Turn off standby
sudo pmset -c standby 0

# Disable autopoweroff to off
sudo pmset -c autopoweroff 0
sudo pmset -c autopoweroffdelay 86400

# Dim display off
sudo pmset -c lessbright 0

###############################################################################
# Laptop Power Options - Battery                                              #
###############################################################################

# Change default sleep from 0 to 15 minutes
sudo pmset -b sleep 15

# Irrelevant with an SSD, but pmset is an asshole about sleep settings.
sudo pmset -b disksleep 15

# Change display sleep to 15
sudo pmset -b displaysleep 15

# Turn off powernap
sudo pmset -b powernap 0

# Set bounds for standby -> hibernate
sudo pmset -b standbydelayhigh 30
sudo pmset -b standbydelaylow 10

# Turn on hibernate
sudo pmset -b hibernatemode 3

# Turn on standby
sudo pmset -b standby 1

# Set autopoweroff
sudo pmset -b autopoweroff 1
sudo pmset -b autopoweroffdelay 28800

# Wake machine on AC connection
sudo pmset -b acwake 1

# Dim display
sudo pmset -b lessbright 1

# Activate audible chime when power cable is plugged in.
defaults write com.apple.PowerChime ChimeOnAllHardware -bool true; open /System/Library/CoreServices/PowerChime.app
