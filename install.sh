#!/bin/bash

sudo cp ./vbox-bridge.sh /usr/bin/
sudo chmod 700 /usr/bin/vbox-bridge.sh
sudo chown root:admin /usr/bin/vbox-bridge.sh
sudo cp ./com.vbox.bridge.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/com.vbox.bridge.plist
sudo launchctl load /Library/LaunchDaemons/com.vbox.bridge.plist