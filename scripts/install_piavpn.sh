#!/bin/bash

# PIAVPN 64bit only
#

case $(sudo -H readlink /proc/1/exe) in
  *systemd)
    INIT="--systemd"
    ;;
  *init)
    INIT="--sysvinit"
    ;;
    *)
    INIT="--sysvinit"
    ;;
esac


FLN=$(curl -s https://www.privateinternetaccess.com/pages/download \
    | grep -A3 -E 'filename.*pia-linux[0-9.-]+[.]run' \
    | grep -m1 -Eo 'pia-linux[0-9.-]+[.]run')

# get piavpn
echo "Downloading Private Internet Access for Linux 64bit : $FLN"

rm /tmp/pia-linux.run 2>/dev/null

sudo -H -u $(logname) curl -RL  -o /tmp/pia-linux.run \
      https://installers.privateinternetaccess.com/download/${FLN} 

if [ -f /tmp/pia-linux.run ]; then
  echo "[ OK ] downloaded '$FLN'"
else
  echo "[ ERROR ] Download of '$FLN' failed file "
  exit 1
fi

# get checksum
CHK="$(curl -s https://www.privateinternetaccess.com/pages/download \
     | grep -A10 -E 'filename.*pia-linux[0-9.-]+[.]run' \
     | grep -m1 -E 'checksum' | sed -nE 's/.*>([a-z0-9]{64})<.*/\1/p')"
     
if [ ${#CHK} -ne 64 ]; then
   echo "[ ERROR ] Missing checksum"
   exit 2
fi

rm /tmp/pia-linux.run.sha256   2>/dev/null

echo "$CHK /tmp/pia-linux.run" > /tmp/pia-linux.run.sha256
chown $(logname):$(logname) /tmp/pia-linux.run.sha256

echo "Verify downloaded installer with SHA256-Checksum"

if sha256sum -c /tmp/pia-linux.run.sha256; then
   echo "[ OK ] Checksum verfified"
else
   echo "[ ERRROR ] Checksum verfication failed"
   exit 3
fi

chmod 755 /tmp/pia-linux.run
rm /tmp/pia-linux.run.log    2>/dev/null
rm /tmp/pia-linux.run.ready  2>/dev/null
EXTRACT_DIR=/tmp/pia-linux.extract 
rm -r $EXTRACT_DIR 2>/dev/null

sudo -H -u $(logname) touch /tmp/pia-linux.run.log 

echo ""
echo "Installing PIAVPN ..."

case $(command -v ssh-askpass 2>/dev/null) in
  *askpass)
      SUDO_ASKPASS=/usr/bin/ssh-askpass
      sudo -AH -u $(logname)  bash -c 'env NO_AT_BRIDGE=1 SUDO_ASKPASS=/usr/bin/ssh-askpass sudo -Av; /tmp/pia-linux.run --keep --target '$EXTRACT_DIR' --accept --noprogress --nox11 -- '$INIT' | sed -r -e "s/\x1B\[[0-9;]+[fhHmlpKABCDj]|\x1B\[[suK]|\x08//g"'
      ;;

  *)
      sudo -H -u $(logname) x-terminal-emulator -e bash -c "/tmp/pia-linux.run --keep --target $EXTRACT_DIR  --accept --noprogress --nox11 -- $INIT 2>&1 | tee /tmp/pia-linux.run.log ; touch /tmp/pia-linux.run.ready;"
      for i in {1..300}; do 
        sleep 1
        [ ! -e /tmp/pia-linux.run.ready ] && continue
        break
      done
      cat /tmp/pia-linux.run.log | sed -r -e "s/\x1B\[[0-9;]+[fhHmlpKABCDj]|\x1B\[[suK]|\x08//g"
      ;;
esac

function echoPass() {
    printf '\xE2\x9C\x94 %s\n' "$@"
}


case "$INIT" in
  *systemd)
    if [ -d /etc/init.d ] && [ -f $EXTRACT_DIR/installfiles/piavpn.sysvinit.service ]; then
      cp $EXTRACT_DIR/installfiles/piavpn.sysvinit.service /etc/init.d/piavpn
      ln -nsf ../init.d/piavpn /etc/rc0.d/K01piavpn
      ln -nsf ../init.d/piavpn /etc/rc1.d/K01piavpn
      ln -nsf ../init.d/piavpn /etc/rc2.d/S02piavpn
      ln -nsf ../init.d/piavpn /etc/rc3.d/S02piavpn
      ln -nsf ../init.d/piavpn /etc/rc4.d/S02piavpn
      ln -nsf ../init.d/piavpn /etc/rc5.d/S02piavpn
      ln -nsf ../init.d/piavpn /etc/rc6.d/K01piavpn
      chmod 755 /etc/init.d/piavpn
      echoPass "Created piavpn sysvinit service"
    fi
    ;;
  *init)
    if [ -d /etc/systemd/system ]; then
      cp $EXTRACT_DIR/installfiles/piavpn.service /etc/systemd/system/piavpn.service 
      ln -nsf /etc/systemd/system/piavpn.service /etc/systemd/system/multi-user.target.wants/piavpn.service
      echoPass "Created piavpn systemd service"
    fi
    
    ;;
esac

# tidy up
rm /tmp/pia-linux.run        2>/dev/null
rm /tmp/pia-linux.run.sha256 2>/dev/null
rm /tmp/pia-linux.run.log    2>/dev/null
rm /tmp/pia-linux.run.ready  2>/dev/null
rm -r $EXTRACT_DIR 2>/dev/null
echo "DONE!"
