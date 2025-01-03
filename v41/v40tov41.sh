#!/bin/bash

ARCHIVE="v40tov41update.tar.gz"
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
wget --progress=dot:binary --no-check-certificate --no-cache --no-cookies -O $ARCHIVEPATH "http://rgsretro1986.ds78102.seedhost.eu/update/v41/v40tov41update.tar.gz"


echo 'Deleting old files'
rm -rf /userdata/system/evmapy
rm -rf /userdata/bios/switch/*
rm -rf /userdata/system/configs/Ryujinx/bis/system/Contents/registered
rm -rf /userdata/system/configs/yuzu/nand/system/Contents/registered
rm -rf /userdata/system/wine/*
rm /userdata/system/configs/3dsen/GeneratorImporter.py
rm /userdata/system/configs/3dsen/launcher.py
rm -rf /userdata/system/configs/Ryujinx/system
rm /userdata/system/configs/demul/GeneratorImporter.py
rm /userdata/system/configs/demul/__pycache__/GeneratorImporter.cpython-311.pyc
rm /userdata/system/configs/demul/__pycache__/customGenerator.cpython-311.pyc
rm /userdata/system/configs/demul/demul/gpuDX11old.ini
rm /userdata/system/configs/demul/launcher.py
rm /userdata/system/configs/dolphin5-triforce/GeneratorImporter.py
rm /userdata/system/configs/dolphin5-triforce/launcher.py
rm /userdata/system/configs/gaelco/Demul.ini
rm /userdata/system/configs/gaelco/GeneratorImporter.py
rm /userdata/system/configs/gaelco/gpuDX11old.ini
rm /userdata/system/configs/gaelco/launcher.py
rm /userdata/system/configs/gaelco/launcher.py.save
rm /userdata/system/configs/sudachi
rm /userdata/system/configs/winebat/GeneratorImporter.py
rm /userdata/system/configs/winebat/launcher.py
rm '/userdata/themes/Carbon-PixN/art/logos/atari.svg'
rm '/userdata/themes/Hypermax-Plus-PixN/Gamelist-text anim.xml'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/logos/CloneHero.jpg'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/logos/bk.rar'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/logos/electronika.png'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/music/Beach (8-Bit Remix) - New Super Mario Bros.ogg'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/music/Fracktail Battle (8-Bit Cover) - Super Paper Mario.ogg'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/music/Francis Battle 8Bit Remix  Super Paper Mario BT.ogg'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/music/Mars Attacks Main Theme.mp3'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/music/Mars Attacks Main Theme.wav'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/music/New Super Mario Bros.ogg'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/music/Red Streamer Battle (8-Bit Remix) - Paper Mario_ The Origami King.ogg'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/music/Vellumental Battle 8Bit Remix  Paper Mario The Origami King.ogg'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/scotty.mp4'
rm -rf themes/Hypermax-Plus-PixN/_inc/text anim/*
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/wallpaper1/D0IIRGVUcAEcS5K.png'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/wallpaper1/NINTCHDBPICT000536074229-e1572807808559.webp'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/wallpaper1/desktop.ini'
rm '/userdata/themes/Hypermax-Plus-PixN/_inc/wallpaper1/neshd.png'
rm '/userdata/themes/Hypermax-Plus-PixN/_template/4815203235791361221411321768176177154196199443.ico'
rm '/userdata/themes/Hypermax-Plus-PixN/capcom/desktop.ini'
rm '/userdata/themes/Hypermax-Plus-PixN/default/desktop.ini'
rm '/userdata/themes/Hypermax-Plus-PixN/konami/desktop.ini'

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
