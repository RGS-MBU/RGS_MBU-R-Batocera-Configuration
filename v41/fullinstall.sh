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
if [ ! -f $ARCHIVEPATH ]; then
    wget --progress=dot:binary --no-check-certificate --no-cache --no-cookies -O $ARCHIVEPATH http://rgsretro1986.ds78102.seedhost.eu/update/v41/fullinstall.tar.gz
fi

echo "uncompress archive..."
sleep 5


if tar -xvf $ARCHIVEPATH --directory /userdata/
then
    echo 'uncompressing archive ok'
else
    echo 'error with uncompressing archive. We stop here.'
    sleep 30
    exit
fi


echo 'Stopping emulationstation'
killall -9 openbox
sleep 5

echo 'Deleting old directories'
sleep 5

shopt -s dotglob
rm -rf /userdata/bios/*
rm -rf /userdata/cheats/*
rm -rf /userdata/extractions/*
rm -rf /userdata/decorations/*
rm -rf /userdata/kodi/*
rm -rf /userdata/library/*
rm -rf /userdata/music/*
rm -rf /userdata/recordings/*
rm -rf /userdata/saves/*
rm -rf /userdata/screenshots/*
rm -rf /userdata/shaders/*
rm -rf /userdata/splash/*
rm -rf /userdata/system/*
rm -rf /userdata/themes/*

if [ ! -d /userdata/roms/rgs ]; then
    mv /userdata/Batocera/roms/rgs /userdata/roms/
fi
rm -rf /userdata/Batocera/roms

mv /userdata/Batocera/bios/* /userdata/bios/
mv /userdata/Batocera/cheats/* /userdata/cheats/
mv /userdata/Batocera/extractions/* /userdata/extractions/
mv /userdata/Batocera/decorations/* /userdata/decorations/
mv /userdata/Batocera/kodi/* /userdata/kodi/
mv /userdata/Batocera/library/* /userdata/library/
mv /userdata/Batocera/music/* /userdata/music/
mv /userdata/Batocera/recordings/* /userdata/recordings/
mv /userdata/Batocera/saves/* /userdata/saves/
mv /userdata/Batocera/screenshots/* /userdata/screenshots/
if [ ! -d /userdata/shaders ]; then
    mkdir -p /userdata/shaders
fi
mv /userdata/Batocera/shaders/* /userdata/shaders/
mv /userdata/Batocera/splash/* /userdata/splash/
mv /userdata/Batocera/system/* /userdata/system/
mv /userdata/Batocera/themes/* /userdata/themes/
shopt -u dotglob

rm -rf /userdata/Batocera


#rm $ARCHIVEPATH

echo "The install ${ARCHIVEPATH} file is not autodelete. Please remove it manually later."
echo 'RGS full install finished. reboot in 30s.'
sleep 30
killall -9 emulationstation
shutdown -r now
