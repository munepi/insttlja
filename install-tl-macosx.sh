#!/bin/bash
#
# Copyright (c) 2013-2021 Munehiro Yamamoto (a.k.a. munepi)
#
# It may be distributed and/or modified under the MIT License.

DARWIN_SUDO_USER=${SUDO_USER:-$([ -z ${SUDO_USER} ] && echo root || echo ${SUDO_USER})}

DARWIN_DESTDIR=$(dirname $0)
DARWIN_PROFILE_D=${DARWIN_DESTDIR}/profile.d/macosx

# given a profile
DARWIN_PROFILE=${PROFILE:-default}
. ${DARWIN_PROFILE_D}/${DARWIN_PROFILE}.conf || exit 1


# given the Resource directory of Ghostscript if any
DARWIN_GSRESOURCEDIR=${GSRESOURCEDIR:-}

# check the existence of install-tl
if [ ! -f ${DARWIN_INSTALL_TL} ]; then
    echo E: No such install-tl: ${DARWIN_INSTALL_TL}
    exit 1
fi
__install_tl="perl ${DARWIN_INSTALL_TL} --no-gui --repository ${DARWIN_TLREPO}"

# check the same TeX Live environment
if [ -d ${DARWIN_TEXDIR}/tlpkg -o -d ${DARWIN_TEXDIR} ]; then
    echo E: already installed TeX Live ${DARWIN_TLVERSION}: ${DARWIN_TLROOT}
    exit 1
fi


# check whether DARWIN_TLREPO is a local tlnet repository or not
if [ ! -d ${DARWIN_TLREPO} ]; then
    echo W: We will attempt to install TeX Live ${DARWIN_TLVERSION} from the external repository ${DARWIN_TLREPO}
fi


# choice your platform
DARWIN_OSXVERSION=$(sw_vers -productVersion)
DARWIN_OSXVERSION=$(echo ${DARWIN_OSXVERSION} | awk -F. '{ OFS=FS; print $1, $2 }') # replace: 10.X.Y -> 10.X
case ${DARWIN_OSXVERSION} in
    10.[012345])
        echo E: not supported: ${DARWIN_OSXVERSION}
        exit 1
        ;;
    10.[6789]|10.1[12])
        DARWIN_TLARCH=x86_64-darwinlegacy
        echo W: not supported: ${DARWIN_OSXVERSION}
        echo We will attempt to install ${DARWIN_TLARCH}
        ;;
    *)
        # 10.13 or higher version
        DARWIN_TLARCH=x86_64-darwin
        ;;
esac

# forcely set $PATH when installing TeX Live ${DARWIN_TLVERSION} and modifying
# your TeX environment
export PATH=${DARWIN_TEXDIR}/bin/${DARWIN_TLARCH}:/usr/bin:/bin:/usr/sbin:/sbin

# show the summary of given profile and given settings
cat<<EOF
==================== SUMMARY ====================
DARWIN_SUDO_USER:		${DARWIN_SUDO_USER}
base profile:			${DARWIN_PROFILE_D}/${DARWIN_PROFILE}.conf
DARWIN_TLVERSION:		${DARWIN_TLVERSION}
DARWIN_TLREPO:			${DARWIN_TLREPO}
DARWIN_INSTALL_TL:		${DARWIN_INSTALL_TL}
DARWIN_TLROOT:			${DARWIN_TLROOT}
DARWIN_TEXDIR:			${DARWIN_TEXDIR}
DARWIN_TEXMFLOCAL:		${DARWIN_TEXMFLOCAL}
DARWIN_TEXMFSYSCONFIG:		${DARWIN_TEXMFSYSCONFIG}
DARWIN_TEXMFSYSVAR:		${DARWIN_TEXMFSYSVAR}
DARWIN_TEXMFHOME:		${DARWIN_TEXMFHOME}
DARWIN_TEXMFCONFIG:		${DARWIN_TEXMFCONFIG}
DARWIN_TEXMFVAR:		${DARWIN_TEXMFVAR}
DARWIN_option_doc:		${DARWIN_option_doc}
DARWIN_option_src:		${DARWIN_option_src}
DARWIN_OSXVERSION:		${DARWIN_OSXVERSION}
DARWIN_TLARCH:			${DARWIN_TLARCH}
PATH:				${PATH}
=================================================
EOF


# generate your installation profile
mkdir -p ${DARWIN_TEXDIR}/tlpkg
cat<<EOF> ${DARWIN_TEXDIR}/tlpkg/texlive.profile
# ${DARWIN_TEXDIR}/tlpkg/texlive.profile $(LANG=C date)
selected_scheme scheme-full
$([ ! -z "${DARWIN_TEXDIR}" ] && echo TEXDIR ${DARWIN_TEXDIR})
$([ ! -z "${DARWIN_TEXMFLOCAL}" ] && echo TEXMFLOCAL ${DARWIN_TEXMFLOCAL})
$([ ! -z "${DARWIN_TEXMFSYSCONFIG}" ] && echo TEXMFSYSCONFIG ${DARWIN_TEXMFSYSCONFIG})
$([ ! -z "${DARWIN_TEXMFSYSVAR}" ] && echo TEXMFSYSVAR ${DARWIN_TEXMFSYSVAR})
$([ ! -z "${DARWIN_TEXMFHOME}" ] && echo TEXMFHOME ${DARWIN_TEXMFHOME})
$([ ! -z "${DARWIN_TEXMFCONFIG}" ] && echo TEXMFCONFIG ${DARWIN_TEXMFCONFIG})
$([ ! -z "${DARWIN_TEXMFVAR}" ] && echo TEXMFVAR ${DARWIN_TEXMFVAR})
binary_${DARWIN_TLARCH} 1
in_place 0
option_adjustrepo 1
option_autobackup 0
option_backupdir tlpkg/backups
option_desktop_integration 1
option_doc ${DARWIN_option_doc}
option_file_assocs 1
option_fmt 1
option_letter 0
option_menu_integration 1
option_path 0
option_post_code 1
option_src ${DARWIN_option_src}
option_sys_bin /usr/local/bin
option_sys_info /usr/local/share/info
option_sys_man /usr/local/share/man
option_w32_multi_user 0
option_write18_restricted 1
portable 0
EOF

# gooooo!
$__install_tl -profile ${DARWIN_TEXDIR}/tlpkg/texlive.profile

# change permissions of DARWIN_TEXMFLOCAL, DARWIN_TEXMFSYSCONFIG, and
# DARWIN_TEXMFSYSVAR under /Users/Shared/TeXLive
echo ${DARWIN_TEXMFLOCAL} | grep -q "/Users/Shared/TeXLive"
if [ $? -eq 0 ]; then
    mkdir -p ${DARWIN_TEXMFLOCAL} ${DARWIN_TEXMFSYSCONFIG} ${DARWIN_TEXMFSYSVAR}
    chown -R ${DARWIN_SUDO_USER}:admin /Users/Shared/TeXLive
    find /Users/Shared/TeXLive -type d -exec chmod 1777 {} \;
fi

echo Happy TeXing!

exit
