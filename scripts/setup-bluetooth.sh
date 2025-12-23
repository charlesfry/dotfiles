#!/usr/bin/env bash
set -Eeuo pipefail

# Repo root is always parent of scripts/
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$REPO_DIR/config/hypr/scripts/bluetooth"
mkdir -p "$OUTPUT_DIR"

# -------------------------
# Detect top-level Bluetooth devices
# -------------------------
DEVICES=$(busctl tree org.bluez \
    | grep -oE '/org/bluez/hci[0-9]+/dev_[0-9A-F_]{17}' \
    | sort -u)

if [[ -z "$DEVICES" ]]; then
    echo "⚠️ No Bluetooth devices found."
    exit 0
fi

# -------------------------
# Device selection
# -------------------------
declare -a SELECTED=()

echo "Found Bluetooth devices:"
for DEVICE in $DEVICES; do
    NAME=$(busctl get-property org.bluez "$DEVICE" org.bluez.Device1 Name | tr -d '"')
    echo "  - $DEVICE ($NAME)"
done

echo
echo "Select devices to manage: Type 'y' to add, 'n' to skip, 'a' to add all remaining."

for DEVICE in $DEVICES; do
    NAME=$(busctl get-property org.bluez "$DEVICE" org.bluez.Device1 Name | tr -d '"')
    yn=""
    read -rsn1 -p "Add $DEVICE ($NAME)? [Y]es/[No]/[A]ll " yn </dev/tty || true
    echo
    echo    # move to a new line after the key press
    case $yn in
        [Yy]*) SELECTED+=("$DEVICE") ;;
        [Aa]*)
            SELECTED=($DEVICES)
            echo "✅ All devices selected."
            break
            ;;
        [Nn]*) ;;
        *) echo "⚠️ Invalid input, skipping $DEVICE." ;;
    esac
done

if [[ "${#SELECTED[@]}" -eq 0 ]]; then
    echo "⚠️ No devices selected. Exiting."
    exit 0
fi

# -------------------------
# Generate connect/disconnect scripts
# -------------------------
CONNECT_SCRIPT="$OUTPUT_DIR/connect_all.sh"
DISCONNECT_SCRIPT="$OUTPUT_DIR/disconnect_all.sh"

echo "#!/usr/bin/env bash" > "$CONNECT_SCRIPT"
echo >> "$CONNECT_SCRIPT"
echo "#!/usr/bin/env bash" > "$DISCONNECT_SCRIPT"
echo >> "$DISCONNECT_SCRIPT"

for DEVICE in "${SELECTED[@]}"; do
    # Get the name of the device for comments
    NAME=$(busctl get-property org.bluez "$DEVICE" org.bluez.Device1 Name | tr -d '"')
    
    # Add a comment with the device name above each command
    echo "# $NAME" >> "$CONNECT_SCRIPT"
    echo "busctl call org.bluez \"$DEVICE\" org.bluez.Device1 Connect" >> "$CONNECT_SCRIPT"
    echo >> "$CONNECT_SCRIPT"

    echo "# $NAME" >> "$DISCONNECT_SCRIPT"
    echo "busctl call org.bluez \"$DEVICE\" org.bluez.Device1 Disconnect" >> "$DISCONNECT_SCRIPT"
    echo >> "$DISCONNECT_SCRIPT"
done

chmod +x "$CONNECT_SCRIPT" "$DISCONNECT_SCRIPT"

# -------------------------
# Summary
# -------------------------
echo
echo "✅ Scripts generated in $OUTPUT_DIR:"
echo "   connect_all.sh — connect all selected devices"
echo "   disconnect_all.sh — disconnect all selected devices"

echo
echo "Selected devices:"
for DEVICE in "${SELECTED[@]}"; do
    NAME=$(busctl get-property org.bluez "$DEVICE" org.bluez.Device1 Name | tr -d '"')
    echo "  - $DEVICE ($NAME)"
done
