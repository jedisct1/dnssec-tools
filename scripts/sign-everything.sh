#! /bin/sh

LDNS_SIGNZONE_WRAPPER="./ldns-signzone.sh"

find . -type f -name "*.zone" -print | {
  while read zonefile_; do
    zonefile=$(basename "$zonefile_")
    zone=$(echo "$zonefile" | sed 's/.zone$//')
    keyfiles=$(ls "K${zone}."*.key 2>/dev/null)
    [ -z "$keyfiles" ] && continue
    keys=$(echo "$keyfiles" | sed s/.key//)
    echo "Signing $zone"
    "$LDNS_SIGNZONE_WRAPPER" -o "$zone" -n "$zonefile" $keys
  done
}
