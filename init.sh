#!/bin/bash

## set -e exit immediaately if a pipeline -v print shell input lines as they are read
# set -ev
set -e

# this script creates
# //this is a path to the /Applications directory where there is a hidden directory .env_darwin_amd64
# //which is a symbolic link to vendor/github.com/therecipe/env_darwin_amd64_602
# on my computer it creates the below symbolic link
# ln -s .env_darwin_amd64 /Users/marclevine/go/src/github.com/therecipe/env_darwin_amd64_513/

# set qt root as the location of Qt not the root of the Qt directory	
QT_ROOT=$HOME
# set Qt Version as the prefered
QT_VERSION=5.13.0
echo $QT_ROOT

# remove Qt Version in this directory and the licenses directory
rm -rf ./${QT_VERSION}
rm -rf ./Licenses

# copy the files from /Users/fizzywhizbang/Qt/5.13.0/clang_64 to this direcotry
rsync -avz $QT_ROOT/Qt/${QT_VERSION}/clang_64 ./${QT_VERSION}/
# copy the Licenses folder because this is OpenSource
rsync -avz $QT_ROOT/Qt/Licenses .


# remove unwanted files copied over from QT_ROOT to this directory under 5.13.0 (documents and languages)
rm -rf ./${QT_VERSION}/clang_64/{doc,phrasebooks}
# remove the directories cmake, pkgconfig, and the file libQt5Bootstrap
rm -rf ./${QT_VERSION}/clang_64/lib/{cmake,pkgconfig,libQt5Bootstrap.a}

# set +e do not exit immediaately if a pipeline
set +e
# remove file types listed below
for v in *.jsc *.log *.pro *.pro.user *.qmake.stash *.qmlc .DS_Store *_debug* *.dSYM *.la *.prl; do
	find . -maxdepth 8 -name ${v} -exec rm -rf {} \;
done
# set -e exit immediaately if a pipeline
set -e

# make directory _bin under 5.13.0/clang_64
mkdir -p ./${QT_VERSION}/clang_64/_bin
# move the below files to _bin directory
for v in macdeployqt moc qmake qmlcachegen qmlimportscanner qt.conf rcc uic; do
	mv ./${QT_VERSION}/clang_64/bin/${v} ./${QT_VERSION}/clang_64/_bin/
done
# remove 5.13.0/clang_64?bin and move/rename the newly created _bin to 5.13.0/clang_64?bin
rm -rf ./${QT_VERSION}/clang_64/bin && mv ./${QT_VERSION}/clang_64/_bin ./${QT_VERSION}/clang_64/bin

## for testing and comparison of files
## mkdir -p bin.bak && rsync -avz ./${QT_VERSION}/clang_64/bin ./${QT_VERSION}/clang_64/bin.bak
## find type = file and the name not equip qt.conf the execute strip
## strip discards all symbols from object files -x Remove non-global symbols reducing file size
find ./${QT_VERSION}/clang_64/bin -type f ! -name "qt.conf" -exec strip -x {} \;




## mv the QT Root to Qt_orig before running the patch
mv $QT_ROOT/Qt $QT_ROOT/Qt_orig

## run patch.go from here and check insde patch.go for comments
## to patch qmake and QtCore
go run ./patch.go

gzip -n ./${QT_VERSION}/clang_64/lib/QtWebEngineCore.framework/Versions/Current/QtWebEngineCore

du -sh ./5*

#$(go env GOPATH)/bin/qtsetup
