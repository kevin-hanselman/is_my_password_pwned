#!/bin/bash

set -eo pipefail

prog=$(basename "$0")

fatal() {
    echo >&2 "$prog: $1"
    exit 1
}

echo "Type one password per line."
echo "To process every password in a file: cat passwords.txt | $prog"
echo " or probably: cat passwords.txt | ./$prog"

while read password
do
   hash=$(printf "%s" "$password" | openssl sha1 | awk '{print $NF}')
   hash_prefix=$(echo "$hash" | cut -c -5)
   hash_suffix=$(echo "$hash" | cut -c 6-)
   response=$(curl -s "https://api.pwnedpasswords.com/range/$hash_prefix") \
       || fatal 'Failed to query the Pwned Passwords API'
   count=$( echo "$response" \
                | grep -i "$hash_suffix" \
                | cut -d':' -f2 \
                | grep -Eo '[0-9]+' \
                || echo 0)
   if [ "$count" -gt 0 ]; then
       echo "PWNED ($count): $password"
   elif [ "$count" -eq 0 ]; then
       echo "OK: $password OK"
   fi
done
