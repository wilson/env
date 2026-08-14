# Environment Config Files

Cross-platform "dotfiles", currently supports:
- FreeBSD
- MacOS
- Linux
- Windows (MSYS2)

## Installaton

- Check out this repository into `~/.dotfiles`
- Execute `~/.dotfiles/install.sh`

If running on a supported platform, the matching `post_install.PLATFORM_NAME.sh` script will be executed.  
These exist to ensure that the configured packages are present.

All scripts are idempotent.

All subdirectories are automatically linked to the standard XDG config location, typically `~/.config`, with the exception of `home`.  
The `home` directory contents are instead linked directly into `$HOME` with a leading dot.  
This is to support "legacy" packages that only look in the user's homedir for their config file/dir.

-----
*© 02026 Wilson Bilkovich*
