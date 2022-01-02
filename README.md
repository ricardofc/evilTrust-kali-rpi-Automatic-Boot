# Forked from [s4vitar/evilTrust](https://github.com/s4vitar/evilTrust)  
># evilTrust
>
><p align="center">
><img src="images/evil.png"
>	alt="Evil logo"
>	width="200"
>	style="float: left; margin-right: 10px;" />
></p>
>
>Herramienta ideal para el despliegue automatizado de un **Rogue AP** con capacidad de selección de plantilla + 2FA.
>
>Esta herramienta dispone de varias plantillas a utilizar, incluyendo una opción de plantilla personalizada, donde el atacante es capaz de desplegar su propia plantilla.


## Como funciona?  
**LIMITACIÓN DE RESPONSABILIDADE** O autor(ricardofc) do presente documento declina calquera responsabilidade asociada ao uso incorrecto e/ou malicioso que puidese realizarse coa información exposta no mesmo. Por tanto, non se fai responsable en ningún caso, nin pode ser considerado legalmente responsable en ningún caso, das consecuencias que poidan derivarse da información contida nel ou que esté enlazada dende ou hacia el, incluíndo os posibles erros e información incorrecta existentes, información difamatoria, así como das consecuencias que se poidan derivar sobre a súa aplicación en sistemas de información reais e/ou virtuais. Este documento foi xerado para uso didáctico e debe ser empregado en contornas privadas e virtuais controladas co permiso correspondente do administrador desas contornas.  
**IMPORTANTE**: Ferramenta modificada para o emprego no Taller de Prácticas no módulo Seguridade Informática de 2º curso do Ciclo de Grao Medio Sistemas Microinformáticos e Redes (SMR). Foi modificada para arrancar automáticamente nunha Raspberry Pi 4 a plantilla ***ies-ald-login ➝ "Plantilla Taller Prácticas SI"***.   

### Guía Rápida  
1. "Queimar" microSD:
     ```console
       # xzcat kali-linux-2021.4-rpi-arm64.img.xz | dd of=/dev/mmcblk0 bs=4M status=progress #”Queimar” microSD  
     ```
2. Arrancar Raspberry Pi 4:
     ```console
     $ setxkbmap es #Configurar teclado en español  
     $ sudo su - #Acceder á consola de root(administrador) a través dos permisos configurados co comando sudo (/etc/sudoers, visudo)  
       # git clone https://github.com/ricardofc/evilTrust-kali-rpi-Automatic-Boot.git && cd evilTrust-kali-rpi-Automatic-Boot #Clonar e acceder ao contido do repositorio
       # bash automatic-kali-rpi.sh #Executar o script automatic-kali-rpi.sh que permitirá tras a súa execución que a Raspberry Pi a partir do próximo reinicio arranque automaticamente na contorna gráfica co usuario root(sen solicitar contrasinal) e sexa executada esta ferramenta lanzándose o Rogue AP á espera de "víctimas"
     ```
3. Opcional: Modificar SSID e channel do "ataque"
     ```console
       # bash utilities/change-cmdline.sh TP_LINK 11
       # reboot
     ```

### Guía
1. Arrancar Raspberry Pi 4 con Kali arm64 GNU/Linux   
2. Automaticamente execútase esta ferramenta lanzando un Rogue AP á espera de "víctimas".  
3. Pódese modificar o SSID e a canle do Rogue AP executando o script ***utilities/change-cmdline.sh***, que permite modificar ***/boot/cmdline.txt***, polo que no seguinte arranque actívanse eses cambios (*/proc/cmdline*).  
4. Una vez conectadas as víctimas serán redireccionadas ao servidor web no que espera a plantilla *ies-ald-login* (páxina phishing da Aula Virtual do centro). O usuario introducirá as súas credenciais, as cales seran visibles en tempo real e gardadas nun ficheiro. Automaticamente ao introducir as credenciais serán redireccionados á páxina real para autentificarse xa que é posible conectarse a Internet. Ademais os usuarios poderán navegar sen ningunha restricción a non ser que se modifique a directiva ***address*** de *dnsmasq.conf*. Co cal os usuarios pensarán que a primeira vez introduciron mal as súas credenciais e probarán de novo.  
5. Premer **Ctrl+C** para acabar co "ataque". As credenciais serán gardadas nos ficheiros coa data actual e a configuración de rede, iptables, arquivos temporais, etc será devolta ao estado existente antes de realizar o "ataque".  

#### Requisitos  
1) Non é necesario contar cunha tarxeta de rede que acepte o modo monitor [[1]](https://wireless.wiki.kernel.org/en/users/documentation/hostapd#details_of_nl80211)
2) Rede cableada con asignación dinámica de IPs (DCHP) que permita conexión a Internet.
3) Raspberry Pi 4:  

   eth0  ➝ NIC cableada. Non precisa configuración sempre e cando configúrese automaticamente por DHCP e posúa conexión a Internet na rede que esté conectada a Raspberry Pi 4  

   wlan0 ➝ NIC WIFI onde se crea automáticamente o Rogue AP. Configurada totalmente con esta ferramenta ao arrancar a Raspberry Pi 4  

   a) Crear a MicroSD arrancable coa distribución kali-rpi [[2]](https://www.kali.org/get-kali/#kali-arm)[[3]](https://raw.githubusercontent.com/ricardofc/repoEDU-CCbySA/main/SI/Taller-SI-Practica-5.pdf). Por exemplo nun PC cun SO GNU/Linux introducir a tarxeta MicroSD e executar nunha consola: 
     ```console
     $ mount #Importante!: Verificar que o dispositivo non está montado`  
     $ sudo su - #Acceder á consola de root(administrador) a través dos permisos configurados co comando sudo (/etc/sudoers, visudo)   
       # xzcat kali-linux-2021.4-rpi-arm64.img.xz | dd of=/dev/mmcblk0 bs=4M status=progress #”Queimar” microSD  
       # exit #Saír da shell  
     $ mount #Importante!: Verificar que o dispositivo non está montado. Se non está montado sacar a tarxeta MicroSD(adaptador SD) do PC
     ```
   b) Insertar a tarxeta MicroSD que acabamos de "queimar" coa distro Kali arm64 [[2]](https://www.kali.org/get-kali/#kali-arm)
   
   c) Conectar á rede cableada, monitor, rato, teclado, etc
   
   d) Arrancar
   
   e) Acceder á contorna gráfica:  
      usuario ➝ kali  
      contrasinal ➝ kali
   
   f) Abrir unha consola e executar:
     ```console
     $ setxkbmap es #Configurar teclado en español  
     $ sudo su - #Acceder á consola de root(administrador) a través dos permisos configurados co comando sudo (/etc/sudoers, visudo)  
       # git clone https://github.com/ricardofc/evilTrust-kali-rpi-Automatic-Boot.git #Clonar o repositorio desta ferramenta
       # cd evilTrust-kali-rpi-Automatic-Boot #Acceder ao contido do repositorio
       # bash automatic-kali-rpi.sh #Executar o script automatic-kali-rpi.sh que permitirá tras a súa execución que a Raspberry Pi a partir do próximo reinicio arranque automaticamente na contorna gráfica co usuario root(sen solicitar contrasinal) e sexa executada esta ferramenta lanzándose o Rogue AP á espera de "víctimas"
     ```

   g) Modificar o SSID e o channel do "ataque" para ter en conta na próxima execución da ferramenta (reboot ➝ /root/.bashrc ➝ exec.sh ➝ evilTrust.sh ➝ /proc/cmdline)
     ```console
       # bash utilities/change-cmdline.sh TP_LINK 11
       # reboot
     ```

## URLs de interese 
* [1] https://wireless.wiki.kernel.org/en/users/documentation/hostapd#details_of_nl80211
* [2] https://www.kali.org/get-kali/#kali-arm
* [3] https://raw.githubusercontent.com/ricardofc/repoEDU-CCbySA/main/SI/Taller-SI-Practica-5.pdf
* [4] https://raw.githubusercontent.com/ricardofc/repoEDU-CCbySA/main/SI/Taller-SI-Practica-8.pdf
