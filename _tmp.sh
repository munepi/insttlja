#!/bin/bash -x

# choice your platform
DARWIN_OSXVERSION=${OSXVERSION:-10.10}
case ${DARWIN_OSXVERSION} in
    10.[01234]|10.[01234].*)
        echo E: not supported: ${DARWIN_OSXVERSION}
        exit 1
        ;;
    10.5|10.5.*)
        DARWIN_TLARCH=universal-darwin
        echo W: not supported: ${DARWIN_OSXVERSION}
        echo We will attempt to install ${DARWIN_TLARCH}
        ;;
    10.6|10.6.*)
        DARWIN_TLARCH=universal-darwin
        ;;
    10.[789]|10.[789].*)
        DARWIN_TLARCH=x86_64-darwin
        ;;
    *)
        DARWIN_TLARCH=x86_64-darwin
        echo W: not supported: ${DARWIN_OSXVERSION}
        echo We will attempt to install ${DARWIN_TLARCH}
        ;;
esac
