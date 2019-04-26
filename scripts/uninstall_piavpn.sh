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
	#x-terminal-emulator -e bash -c "sudo -u $(logname) $UNINSTALL" 2>/dev/null 1>/dev/null
    "$UNINSTALL" 
fi

# tidy up
if [ "$SYSTEMCTL_EXIST" = "false" ]; then
   rm /bin/systemctl 2>/dev/null
fi

   
