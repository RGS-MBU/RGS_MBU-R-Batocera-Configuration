#!/bin/bash

ARCHIVE="rgs-v40-full.tar.gz"
ARCHIVEPATH="/userdata/$ARCHIVE"

#download pack
echo "Downloading new files..."
wget --progress=dot:binary --no-check-certificate --no-cache --no-cookies -O $ARCHIVEPATH "http://rgsretro1986.ds78102.seedhost.eu/update/v40/rgs-v40-full.tar.gz"


echo 'Deleting old directories'
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

echo "uncompress archive..."

tar -xvzf $ARCHIVEPATH --directory /userdata/
mv /userdata/Batocera/roms/rgs /userdata/roms/
rm -rf /userdata/Batocera/roms
mv /userdata/Batocera/* /userdata/
rm -rf /userdata/Batocera
rm $ARCHIVEPATH

echo 'Upgrade finished. reboot.'
sleep 2
shutdown -r now
