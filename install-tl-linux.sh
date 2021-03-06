#!/bin/bash
#
# Copyright (c) 2013-2021 Munehiro Yamamoto (a.k.a. munepi)
#
# It may be distributed and/or modified under the MIT License.

LINUX_DESTDIR=$(dirname $0)
LINUX_PROFILE_D=${LINUX_DESTDIR}/profile.d/linux

# given a profile
LINUX_PROFILE=${PROFILE:-default}
. ${LINUX_PROFILE_D}/${LINUX_PROFILE}.conf || exit 1


# given the Resource directory of Ghostscript if any
LINUX_GSRESOURCEDIR=${GSRESOURCEDIR:-}

# check the existence of install-tl
if [ ! -f ${LINUX_INSTALL_TL} ]; then
    echo E: No such install-tl: ${LINUX_INSTALL_TL}
    exit 1
fi
__install_tl="perl ${LINUX_INSTALL_TL} --no-gui --repository ${LINUX_TLREPO}"

# check the same TeX Live environment
if [ -d ${LINUX_TEXDIR}/tlpkg -o -d ${LINUX_TEXDIR} ]; then
    echo E: already installed TeX Live ${LINUX_TLVERSION}: ${LINUX_TLROOT}
    exit 1
fi

# check whether LINUX_TLREPO is a local tlnet repository or not
if [ ! -d ${LINUX_TLREPO} ]; then
    echo W: We will attempt to install TeX Live ${LINUX_TLVERSION} from the external repository ${LINUX_TLREPO}
fi


# choice your platform
LINUX_UNAME_M=$(uname -m)
case ${LINUX_UNAME_M} in
    i[3-6]86) LINUX_TLARCH=i386-linux;;
    x86_64|amd64) LINUX_TLARCH=x86_64-linux;;
    *) echo E: not supported: ${LINUX_UNAME_M};;
esac

# forcely set $PATH when installing TeX Live ${LINUX_TLVERSION} and modifying
# your TeX environment
export PATH=${LINUX_TEXDIR}/bin/${LINUX_TLARCH}:/usr/bin:/bin:/usr/sbin:/sbin

# show the summary of given profile and given settings
cat<<EOF
==================== SUMMARY ====================
base profile:			${LINUX_PROFILE_D}/${LINUX_PROFILE}.conf
LINUX_TLVERSION:		${LINUX_TLVERSION}
LINUX_TLREPO:			${LINUX_TLREPO}
LINUX_ENABLE_TLBIBUN:		${LINUX_ENABLE_TLBIBUN}
LINUX_INSTALL_TL:		${LINUX_INSTALL_TL}
LINUX_TLROOT:			${LINUX_TLROOT}
LINUX_TEXDIR:			${LINUX_TEXDIR}
LINUX_TEXMFLOCAL:		${LINUX_TEXMFLOCAL}
LINUX_TEXMFSYSCONFIG:		${LINUX_TEXMFSYSCONFIG}
LINUX_TEXMFSYSVAR:		${LINUX_TEXMFSYSVAR}
LINUX_TEXMFHOME:		${LINUX_TEXMFHOME}
LINUX_TEXMFCONFIG:		${LINUX_TEXMFCONFIG}
LINUX_TEXMFVAR:			${LINUX_TEXMFVAR}
LINUX_option_doc:		${LINUX_option_doc}
LINUX_option_src:		${LINUX_option_src}
LINUX_UNAME_M:			${LINUX_UNAME_M}
LINUX_TLARCH:			${LINUX_TLARCH}
PATH:				${PATH}
=================================================
EOF


# generate your installation profile
mkdir -p ${LINUX_TEXDIR}/tlpkg
cat<<EOF> ${LINUX_TEXDIR}/tlpkg/texlive.profile
# ${LINUX_TEXDIR}/tlpkg/texlive.profile $(LANG=C date)
selected_scheme scheme-full
$([ ! -z "${LINUX_TEXDIR}" ] && echo TEXDIR ${LINUX_TEXDIR})
$([ ! -z "${LINUX_TEXMFLOCAL}" ] && echo TEXMFLOCAL ${LINUX_TEXMFLOCAL})
$([ ! -z "${LINUX_TEXMFSYSCONFIG}" ] && echo TEXMFSYSCONFIG ${LINUX_TEXMFSYSCONFIG})
$([ ! -z "${LINUX_TEXMFSYSVAR}" ] && echo TEXMFSYSVAR ${LINUX_TEXMFSYSVAR})
$([ ! -z "${LINUX_TEXMFHOME}" ] && echo TEXMFHOME ${LINUX_TEXMFHOME})
$([ ! -z "${LINUX_TEXMFCONFIG}" ] && echo TEXMFCONFIG ${LINUX_TEXMFCONFIG})
$([ ! -z "${LINUX_TEXMFVAR}" ] && echo TEXMFVAR ${LINUX_TEXMFVAR})
binary_${LINUX_TLARCH} 1
in_place 0
option_adjustrepo 1
option_autobackup 0
option_backupdir tlpkg/backups
option_desktop_integration 1
option_doc ${LINUX_option_doc}
option_file_assocs 1
option_fmt 1
option_letter 0
option_menu_integration 1
option_path 0
option_post_code 1
option_src ${LINUX_option_src}
option_sys_bin /usr/local/bin
option_sys_info /usr/local/share/info
option_sys_man /usr/local/share/man
option_w32_multi_user 0
option_write18_restricted 1
portable 0
EOF

# gooooo!
$__install_tl -profile ${LINUX_TEXDIR}/tlpkg/texlive.profile

echo Happy TeXing!

exit
