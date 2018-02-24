#!/bin/bash 

set -eo pipefail

case "$1" in
    -h|--help)
        echo "usage: $(basename "$0") [password (or you will be prompted)]"
        exit 0
        ;;
esac

echo 'Reminder: This tool does not check password strength!'

if [ -n "$1" ]; then
    password="$1"
else
    echo -n "Type a password to check: "
    read -r -s password
    echo
fi
set -u

hash=$(echo -n "$password" | sha1sum | awk '{print $1}')
unset password
hash_prefix=$(echo "$hash" | cut -c -5)
hash_suffix=$(echo "$hash" | cut -c 6-)

echo "Hash prefix: $hash_prefix"
echo "Hash suffix: $hash_suffix"
echo
echo 'Looking up your password...'

raw_count=$(curl -s "https://api.pwnedpasswords.com/range/$hash_prefix" | grep -i "$hash_suffix" | cut -d':' -f2 || true)

# Remove carriage return
if [ ${raw_count:(-1):1} == $'\r' ]; then
	count=${raw_count::-1}
else
	count=$raw_count
fi

printf "Your password appears in the Pwned Passwords database %u time(s).\\n" "$count"

if [ "$count" -ge 100 ]; then
    echo 'Your password is thoroughly pwned! DO NOT use this password for any reason!'
elif [ "$count" -ge 20 ]; then
    echo 'Your password is pwned! You should not use this password!'
elif [ "$count" -gt 0 ]; then
    echo 'Your password is pwned, but not ubiquitous. Use this password at your own risk!'
elif [ "$count" -eq 0 ]; then
    echo "Your password isn't pwned, but that doesn't necessarily mean it's secure!"
fi
