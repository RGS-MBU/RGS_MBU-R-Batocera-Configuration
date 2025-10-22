#!/bin/bash

TARGET_DIR="/userdata"

log() { echo "[$(date +'%F %T')] $*"; }
err() { echo "[$(date +'%F %T')] ERROR: $*" >&2; }

if [[ $(id -u) -ne 0 ]]; then
    log "Warning: not running as root. You may not be able to kill processes owned by other users."
fi

# get PIDs that have open files in TARGET_DIR using lsof -nP (fast)
find_pids_using_target() {
    if command -v lsof >/dev/null 2>&1; then
        lsof -nP 2>/dev/null | awk -v dir="$TARGET_DIR" 'NR>1 { for(i=9;i<=NF;i++){ if($i ~ dir){print $2; break}} }' | sort -n -u
    elif command -v fuser >/dev/null 2>&1; then
        fuser -m "$TARGET_DIR" 2>/dev/null | tr -cd '0-9
' | sort -n -u
    else
        err "Neither lsof nor fuser found."
        exit 1
    fi
}

# Return 0 if $1 is equal to $2 or is a descendant (child/grandchild/..) of $2
is_descendant_or_same() {
    local pid=$1
    local ancestor=$2
    if [[ "$pid" -eq "$ancestor" ]]; then
        return 0
    fi
    while true; do
        if [[ ! -d "/proc/$pid" ]]; then
            return 1
        fi
        local ppid
        ppid=$(awk '/^PPid:/ {print $2}' /proc/$pid/status 2>/dev/null || true)
        if [[ -z "$ppid" || "$ppid" -le 0 ]]; then
            return 1
        fi
        if [[ "$ppid" -eq "$ancestor" ]]; then
            return 0
        fi
        if [[ "$ppid" -eq 1 ]]; then
            return 1
        fi
        pid=$ppid
    done
}

# Collect ancestors (parent chain) of a PID, excluding 1
collect_ancestors() {
    local pid=$1
    local -a anc=()
    while true; do
        if [[ ! -d "/proc/$pid" ]]; then
            break
        fi
        local ppid
        ppid=$(awk '/^PPid:/ {print $2}' /proc/$pid/status 2>/dev/null || true)
        if [[ -z "$ppid" || "$ppid" -le 0 || "$ppid" -eq 1 ]]; then
            break
        fi
        anc+=("$ppid")
        pid=$ppid
    done
    printf "%s
" "${anc[@]}"
}

# Get session and pgid for a pid (returns "sid pgid")
get_sid_pgid() {
    local pid=$1
    if [[ ! -d "/proc/$pid" ]]; then
        echo "0 0"
        return
    fi
    local sid pgid
    sid=$(awk '/^Tgid:/ {tg=$2} END{ if(tg) print tg }' /proc/$pid/status 2>/dev/null || true)
    # fallback to using ps if above fails
    if [[ -z "$sid" ]]; then
        sid=$(ps -o sess= -p "$pid" 2>/dev/null || true)
    fi
    pgid=$(ps -o pgid= -p "$pid" 2>/dev/null || true)
    sid=${sid// /}
    pgid=${pgid// /}
    echo "${sid:-0} ${pgid:-0}"
}

SCRIPT_PID=$$
log "Script PID: $SCRIPT_PID"

# compute script sid/pgid
read SCRIPT_SID SCRIPT_PGID < <(get_sid_pgid "$SCRIPT_PID")
log "Script SID: $SCRIPT_SID, PGID: $SCRIPT_PGID"

# Build ancestor exclusion list (so we don't kill sshd/parents when running over SSH)
mapfile -t ANCESTORS < <(collect_ancestors "$SCRIPT_PID" || true)
log "Excluding ancestors: ${ANCESTORS[*]}"

# Get candidate PIDs
mapfile -t CANDIDATES < <(find_pids_using_target || true)


ARCHIVE="fullinstall.tar.gz"
ARCHIVEPATH="/userdata/$ARCHIVE"

#download pack
echo "Downloading new files..."
if [ ! -f $ARCHIVEPATH ]; then
    wget  -q --show-progress --progress=bar --no-check-certificate --no-cache --no-cookies -O $ARCHIVEPATH http://rgsretro1986.ds78102.seedhost.eu/update/v42/fullinstall.tar.gz
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


if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
    log "No processes have files open in $TARGET_DIR. Continuing..."
else
    # Filter out this script, its descendants, ancestors, and processes in the same session or pgid
    TARGETS=()
    for pid in "${CANDIDATES[@]}"; do
        [[ -z "$pid" ]] && continue
        if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
            continue
        fi
        # skip if same pid / descendant
        if is_descendant_or_same "$pid" "$SCRIPT_PID"; then
            log "Skipping PID $pid (this script or descendant)"
            continue
        fi
        # skip if ancestor
        skip=0
        for a in "${ANCESTORS[@]}"; do
            if [[ "$pid" -eq "$a" ]]; then
                log "Skipping PID $pid (ancestor of this script)"
                skip=1
                break
            fi
        done
        [[ $skip -eq 1 ]] && continue

        # skip if same session or same pgid (protect shells, sshd, piped bash)
        read pid_sid pid_pgid < <(get_sid_pgid "$pid")
        if [[ -n "$pid_sid" && "$pid_sid" -ne 0 && "$pid_sid" -eq "$SCRIPT_SID" ]]; then
            log "Skipping PID $pid (same session $pid_sid)"
            continue
        fi
        if [[ -n "$pid_pgid" && "$pid_pgid" -ne 0 && "$pid_pgid" -eq "$SCRIPT_PGID" ]]; then
            log "Skipping PID $pid (same pgid $pid_pgid)"
            continue
        fi

        TARGETS+=("$pid")
    done

    if [[ ${#TARGETS[@]} -eq 0 ]]; then
        log "After excluding script relatives and session/pgid peers, no targets remain. Continuing..."
    else
        log "About to kill the following PIDs (SIGKILL): ${TARGETS[*]}"
        for pid in "${TARGETS[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                log "Killing $pid"
                kill -9 "$pid" 2>/dev/null || true
            else
                log "PID $pid already gone"
            fi
        done

        sleep 1

        mapfile -t REMAINING < <(find_pids_using_target || true)
        SURVIVORS=()
        for pid in "${REMAINING[@]}"; do
            [[ -z "$pid" ]] && continue
            if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
                continue
            fi
            if is_descendant_or_same "$pid" "$SCRIPT_PID"; then
                continue
            fi
            skip=0
            for a in "${ANCESTORS[@]}"; do
                if [[ "$pid" -eq "$a" ]]; then
                    skip=1
                    break
                fi
            done
            [[ $skip -eq 1 ]] && continue
            read pid_sid pid_pgid < <(get_sid_pgid "$pid")
            if [[ -n "$pid_sid" && "$pid_sid" -ne 0 && "$pid_sid" -eq "$SCRIPT_SID" ]]; then
                continue
            fi
            if [[ -n "$pid_pgid" && "$pid_pgid" -ne 0 && "$pid_pgid" -eq "$SCRIPT_PGID" ]]; then
                continue
            fi
            SURVIVORS+=("$pid")
        done

        if [[ ${#SURVIVORS[@]} -gt 0 ]]; then
            log "The following PIDs still have files open under $TARGET_DIR after SIGKILL: ${SURVIVORS[*]}. We are going to continue."
            for p in "${SURVIVORS[@]}"; do
                ps -p "$p" -o pid,ppid,uid,comm,args --no-headers 2>/dev/null || true
            done
        else
            log "Success: no processes (other than this script and its relatives) have files open in $TARGET_DIR."
        fi
    fi
fi

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

#mv /userdata/Batocera/bios/* /userdata/bios/
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

mkdir /userdata/themes/ckau-book-PixN

echo -e "Bios installation...."
/userdata/system/rgs/rclone sync PixN-Themes-New:/update/Batocera/bios /userdata/bios --progress --skip-links

if [ -d "/userdata/themes/ckau-book-PixN" ]; then
    echo -e "upgrade ckau-book-PixN theme"
    /userdata/system/rgs/rclone sync PixN-Themes-New:/update/Themes/ckau-book-PixN /userdata/themes/ckau-book-PixN --progress
fi


read -p "Do you want to install theme Hypermax-Plus-PixN (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    mkdir -p /userdata/themes/Hypermax-Plus-PixN
fi

read -p "Do you want to install theme Carbon-PixN (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    mkdir -p /userdata/themes/Carbon-PixN
fi


echo -e "Themes installation...."
sleep 1


if [ -d "/userdata/themes/Hypermax-Plus-PixN" ]; then
    echo -e "upgrade Hypermax-Plus-PixN theme"
    /userdata/system/rgs/rclone sync PixN-Themes-New:/update/Themes/Hypermax-Plus-PixN /userdata/themes/Hypermax-Plus-PixN --exclude=/_inc/videos/** --progress
fi

if [ -d "/userdata/themes/Carbon-PixN" ]; then
    echo -e "upgrade Carbon-PixN theme"
    /userdata/system/rgs/rclone sync PixN-Themes-New:/update/Themes/Carbon-PixN /userdata/themes/Carbon-PixN --progress
fi

if [ -d "/userdata/themes/ckau-book" ]; then
    echo -e "upgrade ckau-book theme"
    /userdata/system/rgs/rclone sync PixN-Themes-New:/update/Themes/ckau-book /userdata/themes/ckau-book --progress
fi



echo "The install ${ARCHIVEPATH} file is not autodelete. Please remove it manually later."
echo 'RGS full install finished. reboot in 30s.'
sleep 30
killall -9 emulationstation
shutdown -r now
