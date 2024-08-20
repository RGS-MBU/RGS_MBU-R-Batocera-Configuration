#!/bin/bash

ARCHIVE="v39tov40update.tar.gz"
ARCHIVEPATH="/userdata/extractions/$ARCHIVE"

#read user configuration before "RGS TUNING", for user system changes
BEGINCONF=$(sed -e '/RGS TUNING/,$d' /userdata/system/batocera.conf)

#read end user conf after "END RGS".  (or jupace.emulator for v39 initial release)
if grep -q "END RGS" /userdata/system/batocera.conf; then
    ENDCONF=$(sed -e '0,/END RGS/d' /userdata/system/batocera.conf)
else
    ENDCONF=$(sed -e '0,/jupace.emulator/d' /userdata/system/batocera.conf)
fi

#download pack
echo "Downloading new files..."
wget --progress=dot:binary --no-check-certificate --no-cache --no-cookies -O $ARCHIVEPATH "http://rgsretro1986.ds78102.seedhost.eu/update/v40/v39tov40update.tar.gz"


echo 'Deleting old files'
rm -rf /userdata/bios/xbox
rm /userdata/bios/kick*
rm /userdata/bios/amiga*
rm -rf /userdata/bios/switch/firmware/*
rm -rf /userdata/system/configs/Ryujinx/bis/system/Contents/registered/*
rm -rf /userdata/saves/mesa_shader_cache/
rm -rf /userdata/system/configs/yuzu/nand/system/Contents/
rm /userdata/system/switch/extra/yuzu
rm /userdata/system/configs/dolphin-triforce/StateSaves/GVSJ8P.s01
rm /userdata/system/configs/dolphin-triforce/StateSaves/GGPE01.s01
rm /userdata/system/configs/dolphin-triforce/StateSaves/GVSJ8P.ini
rm /userdata/system/scripts/border
rm /userdata/system/scripts/border.py
rm -rf /userdata/themes/ckau-book-rgs-v2

echo "uncompress archive..."

tar -xvzf $ARCHIVEPATH --directory /userdata/
rm $ARCHIVEPATH


#read new conf after 'RGS TUNING' , for games tuning
RGSTUNING=$(sed -n '/RGS TUNING/,/END RGS/p' /userdata/system/batocera.conf)


echo "Update batocera.conf"


echo "$BEGINCONF" > /userdata/system/batocera.conf.new
echo "$RGSTUNING" >> /userdata/system/batocera.conf.new
echo "$ENDCONF" >> /userdata/system/batocera.conf.new
mv /userdata/system/batocera.conf.new /userdata/system/batocera.conf

echo "Update settings"

echo 'Upgrade finished. Emulationstation will be reloaded.'
sleep 2
killall -9 emulationstation
