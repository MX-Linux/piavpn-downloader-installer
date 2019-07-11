#!/bin/bash

# modified pia-unistall.sh script

# Overwrite PATH with known safe defaults
PATH="/usr/bin:/usr/sbin:/bin:/sbin"


function removeDaemon() {
  local daemon=piavpn
  case $(sudo -H readlink /proc/1/exe) in
    *init)
      rm /etc/systemd/system/${daemon}.service   2>/dev/null
      rm /etc/systemd/system/*/${daemon}.service 2>/dev/null
      ;;
    *systemd)
      rm /etc/rc[0-6S].d/[SK][0-9][0-9]${daemon} 2>/dev/null
      rm /etc/init.d/${daemon}                   2>/dev/null
      rm /etc/init.d/${daemon}.dpkg-dist         2>/dev/null
      ;;
    esac
}

function uninstallApp() {
  local uninstaller=/opt/piavpn/bin/pia-uninstall.sh
  [ -x $uninstaller ] || return
  echo "Y" | $uninstaller | stripColor
}

function stripColor {
  sed -r -e "s/\x1B\[[0-9;]+[fhHmlpKABCDj]|\x1B\[[suK]|\x08//g"
}

removeDaemon

uninstallApp
