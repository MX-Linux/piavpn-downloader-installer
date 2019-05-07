#!/bin/bash

set -x

# PIAVPN 64bit only
#
[ "$(dpkg --print-architecture)" = "amd64" ] || exit 1
FLN=$(curl -s https://www.privateinternetaccess.com/pages/download \
    | grep -A3 -E 'filename.*pia-linux[0-9.-]+[.]run' \
    | grep -m1 -Eo 'pia-linux[0-9.-]+[.]run')
# get piavpn
#
echo "Downloading Private Internet Access for Linux 64bit : $FLN"
rm /tmp/pia-linux.run 2>/dev/null
sudo -u $(logname) 	curl -RL https://installers.privateinternetaccess.com/download/${FLN} -o /tmp/pia-linux.run
[ -f /tmp/pia-linux.run ] || { echo "ERROR: Download of '$FLN' failed file "; exit 3; }

# get checksum
#
CHK="$(curl -s https://www.privateinternetaccess.com/pages/download \
     | grep -A10 -E 'filename.*pia-linux[0-9.-]+[.]run' \
     | grep -m1 -E 'checksum' | sed -nE 's/.*>([a-z0-9]{64})<.*/\1/p')"
[ ${#CHK} -ne 64 ] && { echo "Checksum-ERROR: Missing checksum"; exit 2; }

rm /tmp/pia-linux.run.sha256   2>/dev/null
echo "$CHK /tmp/pia-linux.run"  > /tmp/pia-linux.run.sha256
sha256sum -c /tmp/pia-linux.run.sha256 || { echo "Checksum-ERROR"; exit 1; }

# check for systemctl
SYSTEMCTL_EXIST="true"
command -v systemctl >/dev/null || { ln -s /bin/true /bin/systemctl;  SYSTEMCTL_EXIST="false"; }

# run installer as user
chmod 755 /tmp/pia-linux.run

#bash -c "sudo -u $(logname) /tmp/pia-linux.run --accept --nox11 2>&1 | perl -pe 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r/\n/g'; echo" 
# 
#su - $(logname) -s/bin/bash -c "env XAUTHORITY=/home/$(logname)/.Xauthority gksudo -D '/tmp/$FLN' /bin/true || exit 1; /tmp/pia-linux.run --accept --nox11  2>&1 | perl -pe 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r/\n/g'; echo "

su - $(logname) -c /bin/bash <<BASH
	env XAUTHORITY=/home/$(logname)/.Xauthority gksudo -D '/tmp/$FLN' /bin/true || exit 1
	/tmp/pia-linux.run --accept --nox11  2>&1 | perl -pe 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r/\n/g'
	echo
BASH

# tidy up
[ "$SYSTEMCTL_EXIST" = "false" ] &&  rm /bin/systemctl
rm /tmp/pia-linux.run        2>/dev/null
rm /tmp/pia-linux.run.sha256 2>/dev/null
echo "DONE!"
