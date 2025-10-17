#!/bin/bash

TARGET_DIR="/userdata/"
SCRIPT_PID=$
PARENT_PID=$PPID

# Function to find and kill processes
kill_processes() {
    # Find all PIDs with files open in /userdata/ (excluding this script and parent shell)
    ALL_PIDS=$(lsof -n 2>/dev/null | grep "^[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  */userdata/" | awk '{print $2}' | sort -u)
    
    # Filter out script PID, parent PID, and curl processes
    PIDS=""
    for pid in $ALL_PIDS; do
        if [ "$pid" != "$SCRIPT_PID" ] && [ "$pid" != "$PARENT_PID" ]; then
            cmd=$(ps -p "$pid" -o comm= 2>/dev/null)
            if [ "$cmd" != "curl" ]; then
                PIDS="$PIDS $pid"
            fi
        fi
    done
    
    if [[ -z "$PIDS" ]]; then
        return 1  # No processes found
    fi
    
    # Display the processes that will be killed
    echo "Found processes with files open in $TARGET_DIR:"
    echo "PID    COMMAND"
    echo "----   -------"
    for pid in $PIDS; do
        ps -p "$pid" -o pid=,comm= 2>/dev/null
    done
    
    # Force kill the processes
    echo ""
    echo "Force killing processes (SIGKILL)..."
    for pid in $PIDS; do
        if kill -9 "$pid" 2>/dev/null; then
            echo "Killed process $pid"
        else
            echo "Failed to kill process $pid (may not exist or no permission)"
        fi
    done
    
    return 0  # Processes were found and killed
}

ARCHIVE="fullinstall.tar.gz"
ARCHIVEPATH="/userdata/$ARCHIVE"

##download pack
#echo "Downloading new files..."
#if [ ! -f $ARCHIVEPATH ]; then
#    wget --progress=dot:binary --no-check-certificate --no-cache --no-cookies -O $ARCHIVEPATH http://rgsretro1986.ds78102.seedhost.eu/update/v42/fullinstall.tar.gz
#fi
#
#echo "uncompress archive..."
#sleep 5
#
#
#if tar -xvf $ARCHIVEPATH --directory /userdata/
#then
#    echo 'uncompressing archive ok'
#else
#    echo 'error with uncompressing archive. We stop here.'
#    sleep 30
#    exit
#fi


# Main execution
echo "Starting process killer for $TARGET_DIR"
echo "========================================"
echo ""

echo "Checking for processes..."

if ! kill_processes; then
    echo ""
    echo "No processes found with files open in $TARGET_DIR"
    echo "All clear!"
else
    echo ""
    echo "Waiting 5 seconds before rechecking..."
    sleep 5
    echo ""

    echo "Rechecking for remaining processes..."
    
    # Find remaining PIDs (excluding bash and curl processes)
    ALL_REMAINING=$(lsof -n 2>/dev/null | grep "^[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  *[^ ]*  */userdata/" | awk '{print $2}' | sort -u)
    
    # Filter out script PID, bash, and curl processes
    REMAINING_PIDS=""
    for pid in $ALL_REMAINING; do
        if [ "$pid" != "$SCRIPT_PID" ]; then
            cmd=$(ps -p "$pid" -o comm= 2>/dev/null)
            if [ "$cmd" != "bash" ] && [ "$cmd" != "curl" ]; then
                REMAINING_PIDS="$REMAINING_PIDS $pid"
            fi
        fi
    done

    if [[ -z "$REMAINING_PIDS" ]]; then
        echo "No remaining processes found. All clear!"
    else
        echo "ERROR: Some processes still have files open in $TARGET_DIR:"
        echo "PID    COMMAND"
        echo "----   -------"
        for pid in $REMAINING_PIDS; do
            ps -p "$pid" -o pid=,comm= 2>/dev/null
        done
        echo ""
        echo "Script stopped due to remaining processes."
        exit 1
    fi
fi


sleep 5


exit

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


mv /userdata/Batocera/roms/rgs /userdata/roms/
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
mv /userdata/Batocera/shaders/* /userdata/shaders/
mv /userdata/Batocera/splash/* /userdata/splash/
mv /userdata/Batocera/system/* /userdata/system/
shopt -u dotglob

rm -rf /userdata/Batocera


echo "The install ${ARCHIVEPATH} file is not autodelete. Please remove it manually later."
echo 'RGS full install finished. reboot in 30s.'
sleep 30
killall -9 emulationstation
shutdown -r now
