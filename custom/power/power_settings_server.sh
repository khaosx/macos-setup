#!/bin/bash

###############################################################################
# Set Power Options - Server                                                  #
###############################################################################

# Change default sleep to disabled
sudo pmset -a sleep 0

# Irrelevant with an SSD, but pmset is an asshole about sleep settings.
sudo pmset -a disksleep 60

# Set display sleep
sudo pmset -a displaysleep 60

# Turn on powernap
sudo pmset -a powernap 1

# Set bounds for standby -> hibernate
sudo pmset -a standbydelayhigh 86400
sudo pmset -a standbydelaylow 86400
sudo pmset -a standbydelay 86400

# Turn off hibernate
sudo pmset -a hibernatemode 0

# Turn off standby
sudo pmset -a standby 0

# Disable autopoweroff to off
sudo pmset -a autopoweroff 0
sudo pmset -a autopoweroffdelay 86400

# Dim display off
sudo pmset -a lessbright 0