#!/bin/bash
export LANG=C LC_ALL=C

DEFAULT_TLNETROOT=${TLNETROOT:-/var/local/tlnet}

mkdir -p ${DEFAULT_TLNETROOT}
rsync -v -rpt --delete \
    rsync://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/ ${DEFAULT_TLNETROOT}

echo $(basename $0): done.

exit
