#!/bin/bash
RELEASE="v39"
CURRENTCOMMIT="HEAD"
PACKAGE="../RGS_MBU-R-Batocera-Configuration/$RELEASE/update.tar.gz"
UPDATESCRIPT="$RELEASE/rgs_upgrade"

cd ../Batocera

#archive new && changed files
rm $PACKAGE
git diff --diff-filter=ACMRTUXB --name-only v39 HEAD | sed 's/.*/"&"/' | xargs tar -czf $PACKAGE

RMFILES=$(git diff v39 HEAD|grep "rename from"|sed 's/rename from /rm \/userdata\//')



cd ../RGS_MBU-R-Batocera-Configuration


#create remove of  old files (deleted of renamed)
cat rgs_upgrade.template > $UPDATESCRIPT
echo "$RMFILES" >> $UPDATESCRIPT





