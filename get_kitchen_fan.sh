#!/bin/bash

# get_kitchen_fan.sh
#
# Script for to get the light in Fjäråskupan, https://www.fjaraskupan.se/ It is 
# controlled via bluetooth. If running on a Raspberry Pi it can be 
# set up according to this instruction: 
# https://www.instructables.com/Control-Bluetooth-LE-Devices-From-A-Raspberry-Pi/
#
# The script depends on mac.sh which should have the MAC address of the Fjäråskupan 
# set. The MAC address can be obtained with e. g. Bluetooth Mac Finder for Android.
#
# Command to get the light look like this:
# gatttool -b 00:1E:C0:57:41:35 --char-read -a 0x000B
# It returns something like this:
# Characteristic value/descriptor: 31 32 33 34 30 4c 5f 5f 5f 5f 30 31 30 30 30
# E. g. in this case 30 31 30 equals 010 %.
#
# The script returns the brightness, 0 - 255
#

# include the mac address
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $dir/mac_address.sh

retries=0
while [ $retries -lt 20 ]; do
  result=$(timeout 0.6 gatttool -b $mac_address --char-read -a 0x000B)
  let retries=retries+1 
  substring=${result:0:44}
  if [ "$substring" == "Characteristic value/descriptor: 31 32 33 34" ]; then
    value=${result:44:3} # get substring that contains the fan speed as an asciihex string
    value=$(echo "$value" | sed -r 's| |\\x|g') # escape each value vith \x
    value=$(echo -e $value) # convert to ascii
    value=$(($value)) # convert to integer
    echo $value
    exit 0
  fi
done

# all retries failed...
echo 0
exit 1
