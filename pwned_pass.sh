#!/usr/bin/env bash

set -euo pipefail

prog=$(basename "$0")

print_usage() {
    echo "$prog"
    echo
    echo '  -h, --help      print this help text and exit'
    echo '  -q, --quiet     suppress non-essential output'
    echo
}

prompt() {
    if [ -z "$quiet" ]; then
        echo
        echo -n 'Type a password and hit Enter (leave empty to exit): '
    fi
}

wipe_password_var() {
    # obfuscate plaintext password, appeasing Bash by removing null characters
    password=$(head -c 256 /dev/urandom | tr '\0' 'x')
    unset password
}

check_if_pwned() {
    # $password is a global variable so we can easily wipe it via a Bash trap
    local password_hash
    local hash_prefix
    local hash_suffix
    local count
    password_hash=$(printf "%s" "$password" | openssl sha1 | awk '{print $NF}')

    wipe_password_var

    hash_prefix=$(echo "$password_hash" | cut -c -5)
    hash_suffix=$(echo "$password_hash" | cut -c 6-)

    if [ -z "$quiet" ]; then
        echo "Hash prefix: $hash_prefix"
        echo "Hash suffix: $hash_suffix"
        echo
        echo 'Looking up your password...'
    fi

    response=$(curl -fsS "https://api.pwnedpasswords.com/range/$hash_prefix")

    count=$(echo "$response" \
            | grep -i "$hash_suffix" \
            | cut -d':' -f2 \
            | grep -Eo '[0-9]+' \
            || echo 0)

    if [ -z "$quiet" ]; then
        echo "Your password appears in the Pwned Passwords database $count time(s)."

        if [ "$count" -ge 100 ]; then
            echo 'Your password is thoroughly pwned! DO NOT use this password for any reason!'
        elif [ "$count" -ge 20 ]; then
            echo 'Your password is pwned! You should not use this password!'
        elif [ "$count" -gt 0 ]; then
            echo 'Your password is pwned, but not ubiquitous. Use this password at your own risk!'
        elif [ "$count" -eq 0 ]; then
            echo "Your password isn't pwned, but that doesn't necessarily mean it's secure!"
        fi
    else
        echo "$password_hash    $count"
    fi

}

trap wipe_password_var EXIT

quiet=
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            print_usage
            exit 0
            ;;
        -q|--quiet)
            quiet=yes
            ;;
        *)
            print_usage
            echo "Unrecognized argument: '$arg'"
            echo 'Note: For security reasons, this script no longer accepts passwords via command-'
            echo 'line arguments. Please use the prompt or pipe a file into this script.'
            exit 1
            ;;
    esac
done

if [ -z "$quiet" ]; then
    echo
    echo 'REMINDER: This tool does not check password strength!'
fi
prompt

while read -r -s password; do
    [ -n "$password" ] || exit 0
    [ -n "$quiet" ] || echo
    check_if_pwned
    prompt
done < /dev/stdin
