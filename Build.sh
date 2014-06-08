#!/bin/bash

TARGET=insttlja-$(date +%Y%m%d)

__tar=$(which gnutar 2>/dev/null)
__tar=$(which gtar 2>/dev/null)

find . -name "*~" -delete
rm -rf ${TARGET}
mkdir ${TARGET}
#cp -a bibun6-mac.md ${TARGET}/
cp -a README.md LICENSE ${TARGET}/
cp -a install-tl-{macosx,linux}.sh ${TARGET}/
cp -a sync-{tlnet,tlptexlive}.sh ${TARGET}/
cp -a profile.d ${TARGET}/

$__tar -cf - ${TARGET} | gzip -9 > ${TARGET}.tar.gz
shasum ${TARGET}.tar.gz > ${TARGET}.tar.gz.sha1sum

for x in ${TARGET}.tar.gz ${TARGET}.tar.gz.sha1sum; do
    gpg --local-user 0xC24B55FD -b ${x}
done

exit
