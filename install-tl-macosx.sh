#!/bin/bash
#
# Copyright (c) 2013 Munehiro Yamamoto (a.k.a. munepi)
# <munepi@greencherry.jp, munepi@vinelinux.org>
#
# It may be distributed and/or modified under the MIT License.

DARWIN_SUDO_USER=${SUDO_USER:-$([ -z ${SUDO_USER} ] && echo root || echo ${SUDO_USER})}

DARWIN_DESTDIR=$(dirname $0)
DARWIN_PROFILE_D=${DARWIN_DESTDIR}/profile.d/macosx

# given a profile
DARWIN_PROFILE=${PROFILE:-default}
. ${DARWIN_PROFILE_D}/${DARWIN_PROFILE}.conf || exit 1


# check the existence of install-tl
if [ ! -f ${DARWIN_INSTALL_TL} ]; then
    echo E: No such install-tl: ${DARWIN_INSTALL_TL}
    exit 1
fi
__install_tl="perl ${DARWIN_INSTALL_TL} -repository ${DARWIN_TLREPO}"

# check the same TeX Live environment
if [ -d ${DARWIN_TEXDIR}/tlpkg -o -d ${DARWIN_TEXDIR} ]; then
    echo E: already installed TeX Live ${DARWIN_TLVERSION}: ${DARWIN_TLROOT}
    exit 1
fi

# check DARWIN_ENABLE_TLPTEXLIVE and DARWIN_ENABLE_TLBIBUN
case "${DARWIN_ENABLE_TLPTEXLIVE},${DARWIN_ENABLE_TLBIBUN}" in
    [01],[01]) ;;
    *)
        echo E: unknown strings: "${DARWIN_ENABLE_TLPTEXLIVE},${DARWIN_ENABLE_TLBIBUN}"
        exit 1
        ;;
esac


# check whether DARWIN_TLREPO is a local tlnet repository or not
if [ ! -d ${DARWIN_TLREPO} ]; then
    echo W: We will attempt to install TeX Live ${DARWIN_TLVERSION} from the external repository ${DARWIN_TLREPO}
fi


# choice your platform
DARWIN_OSXVERSION=$(sw_vers -productVersion)
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
DARWIN_TLPTEXLIVEREPO:		${DARWIN_TLPTEXLIVEREPO}
DARWIN_ENABLE_TLPTEXLIVE:	${DARWIN_ENABLE_TLPTEXLIVE}
DARWIN_ENABLE_TLBIBUN:		${DARWIN_ENABLE_TLBIBUN}
DARWIN_kanjiEmbed:		${DARWIN_kanjiEmbed}
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

# collection-langcjk: depend hiraprop
# # for LaTeX2e Bibunsho 6th Edition
# if [ ${DARWIN_ENABLE_TLBIBUN} -eq 1 ]; then
#     tlmgr --repository ${DARWIN_TLREPO} install hiraprop
# fi

# for tlptexlive repository
if [ ${DARWIN_ENABLE_TLPTEXLIVE} -eq 1 ]; then
    tlmgr --repository ${DARWIN_TLPTEXLIVEROOT} install pmetapost hiraprop
    tlmgr --repository ${DARWIN_TLPTEXLIVEROOT} update --all
    mkdir -p ${DARWIN_TEXMFLOCAL}/tlpkg
    cat<<EOF>${DARWIN_TEXMFLOCAL}/tlpkg/pinning.txt
tlmgr pinning add tlptexlive '*'
EOF
    tlmgr repository add http://www.tug.org/~preining/tlptexlive/2013/ tlptexlive
fi

# patching texmf.cnf
echo "shell_escape_commands = \\
bibtex,bibtex8,bibtexu,pbibtex,upbibtex,biber,\\
kpsewhich,\\
makeindex,mendex,texindy,\\
mpost,pmpost,upmpost,\\
repstopdf,epspdf,extractbb" >> ${DARWIN_TEXDIR}/texmf.cnf

# setup Japanese pLaTeX2e typesetting environment
mkdir -p ${DARWIN_TEXMFLOCAL}/fonts/opentype/screen/hiragino
(cd ${DARWIN_TEXMFLOCAL}/fonts/opentype/screen/hiragino
    [ -f "/Library/Fonts/ヒラギノ明朝 Pro W3.otf" ] && \
        ln -s "/Library/Fonts/ヒラギノ明朝 Pro W3.otf" HiraMinPro-W3.otf
    [ -f "/Library/Fonts/ヒラギノ明朝 Pro W6.otf" ] && \
        ln -s "/Library/Fonts/ヒラギノ明朝 Pro W6.otf" HiraMinPro-W6.otf
    [ -f "/Library/Fonts/ヒラギノ丸ゴ Pro W4.otf" ] && \
        ln -s "/Library/Fonts/ヒラギノ丸ゴ Pro W4.otf" HiraMaruPro-W4.otf
    [ -f "/Library/Fonts/ヒラギノ角ゴ Pro W3.otf" ] && \
        ln -s "/Library/Fonts/ヒラギノ角ゴ Pro W3.otf" HiraKakuPro-W3.otf
    [ -f "/Library/Fonts/ヒラギノ角ゴ Pro W6.otf" ] && \
        ln -s "/Library/Fonts/ヒラギノ角ゴ Pro W6.otf" HiraKakuPro-W6.otf
    [ -f "/Library/Fonts/ヒラギノ角ゴ Std W8.otf" ] && \
        ln -s "/Library/Fonts/ヒラギノ角ゴ Std W8.otf" HiraKakuStd-W8.otf
    [ -f "/System/Library/Fonts/ヒラギノ明朝 ProN W3.otf" ] && \
        ln -s "/System/Library/Fonts/ヒラギノ明朝 ProN W3.otf" HiraMinProN-W3.otf
    [ -f "/System/Library/Fonts/ヒラギノ明朝 ProN W6.otf" ] && \
        ln -s "/System/Library/Fonts/ヒラギノ明朝 ProN W6.otf" HiraMinProN-W6.otf
    [ -f "/Library/Fonts/ヒラギノ丸ゴ ProN W4.otf" ] && \
        ln -s "/Library/Fonts/ヒラギノ丸ゴ ProN W4.otf" HiraMaruProN-W4.otf
    [ -f "/System/Library/Fonts/ヒラギノ角ゴ ProN W3.otf" ] && \
        ln -s "/System/Library/Fonts/ヒラギノ角ゴ ProN W3.otf" HiraKakuProN-W3.otf
    [ -f "/System/Library/Fonts/ヒラギノ角ゴ ProN W6.otf" ] && \
        ln -s "/System/Library/Fonts/ヒラギノ角ゴ ProN W6.otf" HiraKakuProN-W6.otf
    [ -f "/Library/Fonts/ヒラギノ角ゴ StdN W8.otf" ] && \
        ln -s "/Library/Fonts/ヒラギノ角ゴ StdN W8.otf" HiraKakuStdN-W8.otf
)
mkdir -p ${DARWIN_TEXMFLOCAL}/fonts/opentype/jiyukobo/yu
(cd ${DARWIN_TEXMFLOCAL}/fonts/opentype/jiyukobo/yu
    [ -f "/Library/Fonts/Yu Mincho Medium.otf" ] && \
        ln -s "/Library/Fonts/Yu Mincho Medium.otf" YuMincho-Medium.otf
    [ -f "/Library/Fonts/Yu Mincho Demibold.otf" ] && \
        ln -s "/Library/Fonts/Yu Mincho Demibold.otf" YuMincho-Demibold.otf
    [ -f "/Library/Fonts/Yu Gothic Medium.otf" ] && \
        ln -s "/Library/Fonts/Yu Gothic Medium.otf" YuGothic-Medium.otf
    [ -f "/Library/Fonts/Yu Gothic Bold.otf" ] && \
        ln -s "/Library/Fonts/Yu Gothic Bold.otf" YuGothic-Bold.otf
)
${DARWIN_TEXDIR}/bin/${DARWIN_TLARCH}/mktexlsr ${DARWIN_TEXMFLOCAL}
${DARWIN_TEXDIR}/bin/${DARWIN_TLARCH}/kanji-config-updmap-sys ${DARWIN_kanjiEmbed}

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