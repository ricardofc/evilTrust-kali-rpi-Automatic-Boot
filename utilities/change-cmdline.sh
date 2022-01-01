# This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License
# Creative Commons License: http://creativecommons.org/licenses/by-sa/4.0/
# Author: Ricardo Feijoo Costa
# DATA: 2021-12-30 10:21:54.246698541 +0000

#!/bin/bash     #Liña necesaria para saber que shell executará o script

##FUNCIONS
function f_help() {
  clear
  echo
  echo -ne '\e[01;33m'
  echo '#########################################'
  echo -ne '\e[01;33m'
  echo Execución errónea. Exemplo execución:
  echo -ne '\e[00m'
  echo -ne '\e[01;77m'
  echo ""
  echo "  bash $0 TP_LINK 11           #SSID=TP_LINK e channel=11"
  echo -ne '\e[00m'
  echo -ne '\e[01;77m'
  echo ""
  echo -ne '\e[01;33m'
  echo '#########################################'
  echo -e '\e[00m'
  echo
  exit 55
}

function f_main(){
  #VARIABLES
  SSID=${1}
  CHANNEL=${2}
  FILE_CMDLINE='/boot/cmdline.txt'

  grep ap ${FILE_CMDLINE}
  if [ $? -ne '0' ]; then
    LINE=$(cat ${FILE_CMDLINE})
    echo "${LINE} ap=${1}:${2}" > ${FILE_CMDLINE} 
  else
    LINE=$(awk '{$NF=""; print $0}' ${FILE_CMDLINE})
    echo "${LINE} ap=${1}:${2}" > ${FILE_CMDLINE} 
  fi
  }
##main
[ $# -ne 2 ] && f_help 
f_main ${1} ${2}
