#!/bin/bash

ARCHIVE="fullinstall.tar.gz"
ARCHIVEPATH="/userdata/$ARCHIVE"

#download rclone
#mkdir -p /userdata/system/.config/rclone/
#wget --progress=dot:binary --no-check-certificate --no-cache --no-cookies -O /usr/bin/rclone https://pixeldrain.com/api/filesystem/YD1k3dcE/rclone
#wget --progress=dot:binary --no-check-certificate --no-cache --no-cookies -O /userdata/system/.config/rclone/rclone.conf https://pixeldrain.com/api/filesystem/YD1k3dcE/rclone.conf
#chmod +x /usr/bin/rclone


#download pack
echo "Downloading new files..."
#rclone sync "PixN-Updates:/v41/$ARCHIVE" $ARCHIVEPATH --progress
wget --progress=dot:binary --no-check-certificate --no-cache --no-cookies -O $ARCHIVEPATH https://pixeldrain.com/api/filesystem/YD1k3dcE/v41/fullinstall.tar.gz

echo "uncompress archive..."
sleep 5


if tar -xvzf $ARCHIVEPATH --directory /userdata/
then
    echo 'uncompressing archive ok'
else
    echo 'error with uncompressing archive. We stop here.'
    sleep 30
    exit
fi


echo 'Deleting old directories'
sleep 5


rm -rf /userdata/bios
rm -rf /userdata/cheats
rm -rf /userdata/extractions
rm -rf /userdata/decorations
rm -rf /userdata/kodi
rm -rf /userdata/library
rm -rf /userdata/music
rm -rf /userdata/recordings
rm -rf /userdata/saves
rm -rf /userdata/screenshots
rm -rf /userdata/shaders
rm -rf /userdata/splash
rm -rf /userdata/system
rm -rf /userdata/themes


mv /userdata/Batocera/roms/rgs /userdata/roms/
rm -rf /userdata/Batocera/roms
mv /userdata/Batocera/* /userdata/
rm -rf /userdata/Batocera
rm $ARCHIVEPATH

echo 'Upgrade finished. reboot.'
sleep 5
killall -9 emulationstation
shutdown -r now
