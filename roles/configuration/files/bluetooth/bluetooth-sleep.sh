#!/bin/sh

# Taken from
# https://bugs.launchpad.net/dell-sputnik/+bug/1766825/comments/26
# as a workaround for
# https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Freezing_after_waking_from_suspend

if [ "$1" = "pre" ]; then
  systemctl stop bluetooth && rmmod btusb
elif [ "$1" = "post" ]; then
  modprobe btusb && systemctl start bluetooth
fi
