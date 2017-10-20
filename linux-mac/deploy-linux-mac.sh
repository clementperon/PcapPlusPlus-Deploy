#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then XCODE_VER=$($(xcode-select -print-path)/usr/bin/xcodebuild -version | head -n1 | awk '{print $2}') ; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then OS_VER=mac-os-$(sw_vers -productVersion)-xcode-$XCODE_VER; fi

DIST_DIR_NAME=pcapplusplus-$(cat Deploy/latest_release.version)-$OS_VER-gcc-$(cat gcc.version)

mv Dist $DIST_DIR_NAME

NEW_FIRST_LINE="PCAPPLUSPLUS_HOME := /your/PcapPlusPlus/folder"

sudo sed -i.bak $SED_PARAMS "1s|.*|$NEW_FIRST_LINE|" $DIST_DIR_NAME/mk/PcapPlusPlus.mk && sudo rm $DIST_DIR_NAME/mk/PcapPlusPlus.mk.bak

sudo sed -i.bak $SED_PARAMS "s|"$(PCAPPLUSPLUS_HOME)/Dist"|"$(PCAPPLUSPLUS_HOME)"|" $DIST_DIR_NAME/mk/PcapPlusPlus.mk && sudo rm $DIST_DIR_NAME/mk/PcapPlusPlus.mk.bak

sudo cp ../PcapPlusPlus-Deploy/READMEs/README.release.linux_mac $DIST_DIR_NAME/README.release

sudo mkdir $DIST_DIR_NAME/example-app
sudo cp Examples/Tutorials/Tutorial-HelloWorld/main.cpp $DIST_DIR_NAME/example-app
sudo cp Examples/Tutorials/Tutorial-HelloWorld/1_packet.pcap $DIST_DIR_NAME/example-app
sudo cp ../PcapPlusPlus-Deploy/linux-mac/Makefile.non_windows $DIST_DIR_NAME/example-app/Makefile
sudo cp mk/install.sh $DIST_DIR_NAME/
sudo cp mk/uninstall.sh $DIST_DIR_NAME/
sudo printf "\necho Installation complete!" >> $DIST_DIR_NAME/install.sh
sudo printf "\necho Uninstallation complete!" >> $DIST_DIR_NAME/uninstall.sh

sudo tar -zcvf $DIST_DIR_NAME.tar.gz $DIST_DIR_NAME/
curl --upload-file ./$DIST_DIR_NAME.tar.gz https://transfer.sh/$DIST_DIR_NAME.tar.gz
