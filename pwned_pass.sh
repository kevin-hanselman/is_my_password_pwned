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
    if (( quiet == 0 )); then
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
    local api_url

    if command -v openssl >/dev/null 2>&1; then
        password_hash=$(printf "%s" "$password" | openssl sha1 | awk '{print $NF}')
    elif command -v sha1sum >/dev/null 2>&1; then
        password_hash=$(printf "%s" "$password" | sha1sum | awk '{print $1}')
    fi

    wipe_password_var

    hash_prefix="${password_hash:0:5}"
    hash_suffix="${password_hash:5}"
    api_url="https://api.pwnedpasswords.com/range/$hash_prefix"

    if (( quiet == 0 )); then
        echo "Hash prefix: $hash_prefix"
        echo "Hash suffix: $hash_suffix"
        echo
        echo 'Looking up your password...'
    fi

    if command -v curl >/dev/null 2>&1; then
        response=$(curl -fsS "${api_url}")
    else
        response=$(wget -qO- "${api_url}")
    fi

    count=$(echo "$response" \
            | grep -i "$hash_suffix" \
            | cut -d':' -f2 \
            | grep -Eo '[0-9]+' \
            || echo 0)

    if (( quiet == 0 )); then
        echo "Your password appears in the Pwned Passwords database $count time(s)."

        if (( count >= 100 )); then
            echo 'Your password is thoroughly pwned! DO NOT use this password for any reason!'
        elif (( count >= 20 )); then
            echo 'Your password is pwned! You should not use this password!'
        elif (( count > 0 )); then
            echo 'Your password is pwned, but not ubiquitous. Use this password at your own risk!'
        elif (( count == 0 )); then
            echo "Your password isn't pwned, but that doesn't necessarily mean it's secure!"
        fi
    else
        echo "$password_hash    $count"
    fi

}

trap wipe_password_var EXIT

quiet=0
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            print_usage
            exit 0
            ;;
        -q|--quiet)
            quiet=1
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

if (( quiet == 0 )); then
    echo
    echo 'REMINDER: This tool does not check password strength!'
fi
prompt

while read -rs password; do
    [[ -n "$password" ]] || exit 0
    (( quiet == 1 )) || echo
    check_if_pwned
    prompt
done < /dev/stdin
