#!/bin/bash
filewebsite="https://raw.githubusercontent.com/bmswens/GPiCase2-Script/main"
sleep 2s
#Step 1) Check if root--------------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "Please execute script as root." 
   exit 1
fi
#-----------------------------------------------------------

#Step 2) Download and apply display patch-------------------
echo "Backing up current config."
cd /boot
mkdir original_files
mv config.txt original_files/config.txt

echo "Applying new config."
wget --no-check-certificate -O  "config.txt" "$filewebsite""/raspberry-pi-os/patch_files/config.txt"
wget --no-check-certificate -O  "config_lcd.txt" "$filewebsite""/raspberry-pi-os/patch_files/config_lcd.txt"
wget --no-check-certificate -O  "config_hdmi.txt" "$filewebsite""/raspberry-pi-os/patch_files/config_hdmi.txt"

#-----------------------------------------------------------

#Step 3) Download Python script-----------------------------
cd /opt/
sudo mkdir RetroFlag
cd /opt/RetroFlag
script=SafeShutdown.py

if [ -e $script ];
	then
		wget --no-check-certificate -O  $script "$filewebsite""/retropie_SafeShutdown_gpi2.py"
	else
		wget --no-check-certificate -O  $script "$filewebsite""/retropie_SafeShutdown_gpi2.py"
fi
wget --no-check-certificate -O  "lcdfirst.sh" "$filewebsite""/retropielcdfirst.sh"
wget --no-check-certificate -O  "lcdnext.sh" "$filewebsite""/retropielcdnext.sh"


cd /etc/modprobe.d
wget --no-check-certificate -O  "alsa-base.conf" "$filewebsite""/alsa-base.conf"


#-----------------------------------------------------------
sleep 2s	
#Step 4) Enable Python script to run on start up------------
cd /etc/
RC=rc.local

if grep -q "sh \/opt\/RetroFlag\/lcdfirst.sh\& \nsleep 1\& \nsudo python \/opt\/RetroFlag\/SafeShutdown.py \&" "$RC";
	then
		echo "File /etc/rc.local already configured. Doing nothing."
	else
		sed -i -e "s/^exit 0/sh \/opt\/RetroFlag\/lcdfirst.sh\& \nsleep 1\& \nsudo python \/opt\/RetroFlag\/SafeShutdown.py\& \n&/g" "$RC"
		echo "File /etc/rc.local configured."
fi
#-----------------------------------------------------------

#Step 5) Enable emulationstation as service-----------------

wget --no-check-certificate -O  "/lib/systemd/system/emulationstation.service" "$filewebsite""/raspberry-pi-os/emulationstation.service"

#-----------------------------------------------------------

#Step 6) Reboot to apply changes----------------------------
echo "RetroFlag Pi Case installation done. Will now reboot after 3 seconds."
sleep 3s
sudo reboot
#-----------------------------------------------------------
