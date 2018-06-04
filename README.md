# Is my password pwned?
Find out how often your password appears in [Troy Hunt's Pwned Passwords database](https://www.troyhunt.com/ive-just-launched-pwned-passwords-version-2/).

Uses [the k-anonymity API](https://blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/) to keep your password from leaving your PC.

Original one was written in concise Bash for transparency and portability.

```
$ ./pwned_pass.sh
Reminder: This tool does not check password strength!
Type a password to check:
Hash prefix: 5baa6
Hash suffix: 1e4c9b93f3f0682250b6cf8331b7ee68fd8

Looking up your password...
Your password appears in the Pwned Passwords database 3303003 time(s).
Your password is thoroughly pwned! DO NOT use this password for any reason!
```

### C# version

re-writen using C# then compiled for windows, get it in C# folder, download exe at your own risk.

### UWP version

vs2017 project under UWP folder, you can download it from [Microsoft Store](https://www.microsoft.com/en-us/p/is-my-password-pwned/9nxpr153j0x4) which is available on x86/x64/arm.
