#!/bin/bash

APP_DATA_DIR="$HOME/.codeprofiles/"
PROFILES_DIR="$APP_DATA_DIR/profiles/"
INSTALL_DIR="/opt/codeprofiles"
BINARY_INSTALL_DIR="/usr/local/bin"
CURRENT_DIR="$(pwd)"


if [ -d "$INSTALL_DIR" ];
then 
    rm -r $INSTALL_DIR
fi
sudo mkdir $INSTALL_DIR

sudo cp "$CURRENT_DIR/profiles.sh" $INSTALL_DIR/
sudo chmod +x "$INSTALL_DIR/profiles.sh" 

sudo cp -R "$CURRENT_DIR/visuals/" "$INSTALL_DIR/"

sudo chmod -R 777 "$INSTALL_DIR"
sudo chmod -R a=rw "$INSTALL_DIR/visuals"

sudo cat > /usr/share/applications/codeprofiles.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Code Profiles
Comment=VS Code profile manager.
Exec=bash $INSTALL_DIR/profiles.sh
Icon=$INSTALL_DIR/visuals/icon.png
Terminal=true
StartupNotify=false
EOF

sudo chmod u+x /usr/share/applications/codeprofiles.desktop

sudo cp "$CURRENT_DIR/binaries/codeprofiles" $BINARY_INSTALL_DIR/
sudo chmod +x "$BINARY_INSTALL_DIR/codeprofiles" 