#!/bin/bash

# Name:         vbox-bridge 
# Version:      0.0.2
# Release:      1
# License:      Open Source
# Group:        System
# Source:       N/A
# URL:          http://lateralblast.com.au/
# Distribution: UNIX
# Vendor:       Lateral Blast
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Shell script to stop/start VirtualBox bridge interface on OS X

gwdev=`netstat -rn |grep default |awk '{print $6}' |head -1`
bridgeip="192.168.2.1"
bridgenm="255.255.255.0"
bridgebc="192.168.2.255"
 
stop() {
  echo "Stopping VirtualBox Bridge interfaces and NATing..."
  sudo pkill natd
  sudo /sbin/ipfw delete 100 divert natd ip from any to any via $gwdev
  sudo sysctl -w net.inet.ip.forwarding=0
  sudo ifconfig $gwdev down
  sudo route delete default -interface bridge0 -ifscope bridge0
  sudo ifconfig bridge0 deletem $gwdev
  sudo ifconfig bridge0 down
  sudo ifconfig bridge0 unplumb
  sudo ifconfig $gwdev up
  sudo kextunload -b org.virtualbox.kext.VBoxUSB
  sudo kextunload -b org.virtualbox.kext.VBoxNetFlt
  sudo kextunload -b org.virtualbox.kext.VBoxNetAdp
  sudo kextunload -b org.virtualbox.kext.VBoxDrv
  echo "Done."
}
 
start() {
  echo "Starting VirtualBox Bridge interfaces and NATing..."
  sudo kextload /Library/Extensions/VBoxDrv.kext -r /Library/Extensions/
  sudo kextload /Library/Extensions/VBoxNetFlt.kext -r /Library/Extensions/
  sudo kextload /Library/Extensions/VBoxNetAdp.kext -r /Library/Extensions/
  sudo kextload /Library/Extensions/VBoxUSB.kext -r /Library/Extensions/
  sudo ifconfig bridge0 plumb
  sudo ifconfig bridge0 addm $gwdev
  sudo ifconfig bridge0 inet $bridgeip netmask $bridgenm broadcast $bridgebc up
  sudo route add default -interface bridge0 -ifscope bridge0 -cloning
  sudo sysctl -w net.inet.ip.forwarding=1
  sudo /sbin/ipfw add 100 divert natd ip from any to any via $gwdev
  sudo /usr/sbin/natd -interface $gwdev -use_sockets -same_ports -unregistered_only -dynamic -clamp_mss -enable_natportmap -natportmap_interface $gwdev
  echo "Done."
}
 
case "$1" in
  stop)
    stop 
    ;;
  start)
    start 
    ;;
  restart)
    stop 
    sleep 8 
    start 
    ;;
  *)
    echo "Usage:"
    echo ""
    echo "Restart VirtualBox Bridge interface and NAT: vbox-bridge restart"
    echo "Start VirtualBox Bridge interface and NAT:   vbox-bridge start"
    echo "Stop VirtualBox Bridge interface and NAT:    vbox-bridge stop"
    echo ""
esac
