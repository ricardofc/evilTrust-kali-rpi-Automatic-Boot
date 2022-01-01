# This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License
# Creative Commons License: http://creativecommons.org/licenses/by-sa/4.0/
# Author: Ricardo Feijoo Costa (ricardofc)
# DATA: 2021-12-30 10:21:54.246698541 +0000

#!/bin/bash     #Liña necesaria para saber que shell executará o script

#VARIABLES
MAC=${1}

##FUNCIONS
function f_change_mac() {
  ip link set down dev wlan0

  macchanger -m ${1} wlan0
  ##ip link set address ${1} dev wlan0

  ip link set up dev wlan0

  terminator --geometry=900x600+1920+1080 -e 'timeout 30 watch ip addr show wlan0' 
}

function f_main(){
  f_change_mac ${1}
}

##main
f_main ${MAC}
