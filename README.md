insttlja
========

This program supports the TeX Live installation by downloading install-tl-unx.tar.gz or using local tlnet for Japanese Unix users.

## インスール処理

### 例：標準的なインストール 

PROFILE=default を読み込みます。

```
$ sudo ./install-tl-macosx.sh
```

### 例：TeX Live 準拠にしたインストール 

```
$ sudo PROFILE=texlive ./install-tl-macosx.sh
```

### 例：ローカルな tlnet とローカルな tlptexlive を指定し、tlptexliveを有効にしたインストール

```
$ sudo PROFILE=texlive TLTEXJP=/var/local/tlptexlive TLREPO=/var/local/tlnet TEXLIVE_INSTALL_PREFIX=/opt/texlive ./install-tl-macosx.sh
```

### 例：GhostscriptのResourceディレクトリを与えたインストール

```
$ sudo GSRESOURCEDIR=/opt/mactexaddons/share/ghostscript/9.20/Resources ./install-tl-macosx.sh
```
