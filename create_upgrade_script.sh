#!/bin/bash
RELEASE="v42"
CURRENTCOMMIT="HEAD"
PACKAGE="../RGS_MBU-R-Batocera-Configuration/$RELEASE/update.tar.gz"
UPDATESCRIPT="$RELEASE/rgs_upgrade"

cd ../Batocera

#archive new && changed files
rm $PACKAGE
git diff --diff-filter=ACMRTUXB --name-only $RELEASE HEAD | sed 's/^/.\//' |tar -czf $PACKAGE -T -
RENAMEDFILES=$(git diff $RELEASE HEAD|grep "rename from"|sed 's/rename from /rm \/userdata\//')
RMFILES=$(git diff $RELEASE HEAD --diff-filter=D --summary|sed 's/delete mode 100644/rm/')


cp system/rgs.version ../RGS_MBU-R-Batocera-Configuration/$RELEASE/version.txt

cd ../RGS_MBU-R-Batocera-Configuration

#create remove of  old files (deleted of renamed)
cat rgs_upgrade_part1.template > $UPDATESCRIPT
echo "$RENAMEDFILES" >> $UPDATESCRIPT
echo "$RMFILES" >> $UPDATESCRIPT
cat rgs_upgrade_part2.template >> $UPDATESCRIPT


