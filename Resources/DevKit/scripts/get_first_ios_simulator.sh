#!/bin/zsh

set -euo pipefail

# get first available iOS simulator using JSON parsing
SIMULATOR=$(xcrun simctl list devices available --json | python3 -c "
import sys, json
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' in runtime:
        for device in devices:
            if device.get('isAvailable', False) and 'iPhone' in device.get('name', ''):
                print(device['udid'])
                sys.exit(0)
sys.exit(1)
")

if [[ -z "$SIMULATOR" ]]; then
    echo "[-] no available iPhone simulator found" >&2
    exit 1
fi

echo "[+] using simulator: $SIMULATOR" >&2
echo "platform=iOS Simulator,id=$SIMULATOR"
