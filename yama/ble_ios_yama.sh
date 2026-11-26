#!/bin/bash
# 26 Kas (#8224): iPhone'da yüzük bağlanınca çökme. @capacitor-community/bluetooth-le 6.x iOS kodu
# deviceMap/callbackMap iş parçacığı güvenli değil: tarama + iQIBLA yeniden-kurma yazmaları sırasında
# Device nesnesi serbest kalıyor -> EXC_BAD_ACCESS (upstream #779, #803; 8.0.2-8.1.3'te düzeltildi).
# Capacitor 6'da kalırken yalnız iOS Swift kaynağı 8.4.0 ile değiştirilir (Cap 6 API'leri, CAPBridgedPlugin).
set -euo pipefail
K="$(cd "$(dirname "$0")/.." && pwd)"; P="$K/node_modules/@capacitor-community/bluetooth-le"
[ -d "$P" ] || { echo "eklenti yok: $P"; exit 1; }
rm -rf "$P/ios"; mkdir -p "$P/ios"; cp -r "$K/yama/bluetooth-le-ios/Sources" "$P/ios/Sources"
cp "$K/yama/bluetooth-le-ios/CapacitorCommunityBluetoothLe.podspec" "$P/CapacitorCommunityBluetoothLe.podspec"
echo "BLE iOS yaması uygulandı (8.4.0 Swift):"; ls "$P/ios/Sources/BluetoothLe"
