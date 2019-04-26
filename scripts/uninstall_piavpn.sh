#!/bin/bash

# unistall piavpn 

# check for systemctl
SYSTEMCTL_EXIST="true"
if ! command -v systemctl >/dev/null; then
   ln -s /bin/true /bin/systemctl
   SYSTEMCTL_EXIST="false"
fi

# run piavpn uninstaller as user
UNINSTALL=/opt/piavpn/bin/pia-uninstall.sh
if [ -x $UNINSTALL ]; then
  bash -c "echo Y | sudo -u $(logname) $UNINSTALL  2>&1 | perl -pe 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r/\n/g'; echo" 
fi

# tidy up
if [ "$SYSTEMCTL_EXIST" = "false" ]; then
   rm /bin/systemctl 2>/dev/null
fi
echo "DONE!"

   
