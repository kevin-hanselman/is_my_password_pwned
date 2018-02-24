#!/bin/bash

set -eo pipefail

prog=$(basename "$0")

fatal() {
    echo >&2 "$prog: $1"
    exit 1
}

password=
case "$1" in
    -h|--help)
        echo "usage: $prog [password (or you will be prompted)]"
        exit 0
        ;;
    *)
        password=$1
        ;;
esac

echo 'Reminder: This tool does not check password strength!'

if [ -z "$password" ]; then
    printf "Type a password to check: "
    read -r -s password
    echo
fi
set -u

hash=$(printf "%s" "$password" | openssl sha1 | awk '{print $NF}')
    
unset password
hash_prefix=$(echo "$hash" | cut -c -5)
hash_suffix=$(echo "$hash" | cut -c 6-)

echo "Hash prefix: $hash_prefix"
echo "Hash suffix: $hash_suffix"
echo
echo 'Looking up your password...'

response=$(curl -s "https://api.pwnedpasswords.com/range/$hash_prefix") \
    || fatal 'Failed to query the Pwned Passwords API'

if [ $(uname) == "Linux" ]; then
    count=$( echo "$response" \
                 | grep -i "$hash_suffix" \
                 | cut -d':' -f2 \
                 | grep -Po '\d+' \
                 || echo 0)
elif [ $(uname) == "Darwin" ]; then
    count=$( echo "$response" \
                 | grep -i "$hash_suffix" \
                 | cut -d':' -f2 \
                 | grep -Eo '\d+' \
                 || echo 0)
fi

printf "Your password appears in the Pwned Passwords database %d time(s).\\n" "$count"

if [ "$count" -ge 100 ]; then
    echo 'Your password is thoroughly pwned! DO NOT use this password for any reason!'
elif [ "$count" -ge 20 ]; then
    echo 'Your password is pwned! You should not use this password!'
elif [ "$count" -gt 0 ]; then
    echo 'Your password is pwned, but not ubiquitous. Use this password at your own risk!'
elif [ "$count" -eq 0 ]; then
    echo "Your password isn't pwned, but that doesn't necessarily mean it's secure!"
fi
