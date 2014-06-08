#!/bin/bash
export LANG=C LC_ALL=C

DEFAULT_TLPTEXLIVEROOT=${TLPTEXLIVEROOT:-/var/local/tlptexlive}

tmp=$(mktemp -d /tmp/tlptexlive.XXXXXX)

trap _cleanup EXIT
_cleanup(){
    rm -rf ${tmp}
}


mkdir -p ${DEFAULT_TLPTEXLIVEROOT}
(cd ${tmp}
    mkdir -p www.tug.org/~preining/
    cp -a ${DEFAULT_TLPTEXLIVEROOT} www.tug.org/~preining/tlptexlive

    wget -m -np http://www.tug.org/~preining/tlptexlive/
    find www.tug.org -regex ".*/index.html.*" -delete

    mv www.tug.org/~preining/tlptexlive $(basename ${DEFAULT_TLPTEXLIVEROOT})
    cp -a $(basename ${DEFAULT_TLPTEXLIVEROOT}) $(dirname ${DEFAULT_TLPTEXLIVEROOT})/
)

echo $(basename $0): done.

exit
