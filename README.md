# Is my password pwned?
Find out how often your password appears in [Troy Hunt's Pwned Passwords
database](https://www.troyhunt.com/ive-just-launched-pwned-passwords-version-2/).

This script uses [the k-anonymity
API](https://blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/)
to keep your password from leaving your computer, and it's written in concise
Bash for transparency and portability.

This script no longer accepts passwords via command line arguments. This usage
would expose passwords in your [shell's
history](https://www.tecmint.com/history-command-examples/), or to people in
view of your computer screen. Clearly, you can still pipe passwords to the
script, but doing so is strongly discouraged.

## Usage Examples

```
$ ./pwned_pass.sh

REMINDER: This tool does not check password strength!

Type a password and hit Enter (leave empty to exit):
Hash prefix: 5baa6
Hash suffix: 1e4c9b93f3f0682250b6cf8331b7ee68fd8

Looking up your password...
Your password appears in the Pwned Passwords database 3645804 time(s).
Your password is thoroughly pwned! DO NOT use this password for any reason!
```

```
$ cat passwords.txt | ./pwned_pass.sh -q
5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8    3645804
8843d7f92416211de9ebb963ff4ce28125932878    11958
5c6d9edc3a951cda763f650235cfc41a3fc23fe8    203116
```
