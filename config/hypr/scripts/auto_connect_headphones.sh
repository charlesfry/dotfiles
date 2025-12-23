#!/usr/bin/env bash

DEVICE="/org/bluez/hci1/dev_14_3F_A6_58_85_44"

CONNECTED=$(busctl get-property org.bluez "$DEVICE" org.bluez.Device1 Connected | awk '{print $2}')

if [ "$CONNECTED" = "true" ]; then
  busctl call org.bluez "$DEVICE" org.bluez.Device1 Disconnect
else
  busctl call org.bluez "$DEVICE" org.bluez.Device1 Connect
fi
