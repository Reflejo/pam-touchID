PAM TouchID
-----------
A PAM plugin for authenticating using biometric information (touch ID) written in Swift.

<img src="https://cloud.githubusercontent.com/assets/232113/20745146/c5bd64d0-b694-11e6-8963-cc6f6a16d1f8.gif" alt="Demo" width="640" />

Installation
------------

1. `$ sudo make install`
2. Edit `/etc/pam.d/sudo` to include as the first line: `auth sufficient pam_touchid.so reason="execute a command as root"`

_Note that you might have other `auth`, don't remove them._
