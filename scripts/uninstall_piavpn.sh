#!/bin/bash

# unistall piavpn

# check for systemctl
SYSTEMCTL_EXIST="true"
if ! command -v systemctl >/dev/null; then
  ln -s /bin/true /bin/systemctl
  SYSTEMCTL_EXIST="false"
fi

# stop sysvinit piavpn daemon

if pidof /sbin/init >/dev/null && [ -x /etc/init.d/piavpn ]; then
   # stop piavpn if running
   if /etc/init.d/piavpn status >/dev/null 2>&1; then
      echo "Stopping piavpn ..."
      /etc/init.d/piavpn stop
   fi
fi

# run piavpn uninstaller as user
UNINSTALL=/opt/piavpn/bin/pia-uninstall.sh
if [ -x $UNINSTALL ]; then
   su - $(logname) -c /bin/bash <<BASH
   env XAUTHORITY=/home/$(logname)/.Xauthority gksudo -D 'piavpn uninstaller' /bin/true || exit 1
   echo Y | $UNINSTALL  2>&1 | perl -pe 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r/\n/g'
   echo
BASH
fi

# tidy up
if [ "$SYSTEMCTL_EXIST" = "false" ]; then
  rm /bin/systemctl 2>/dev/null
fi
echo "DONE!"


