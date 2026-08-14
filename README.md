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

-----
*© 02026 Wilson Bilkovich*
