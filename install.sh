#!/bin/sh
set -eu

DOTFILES_DIR="${HOME}/.dotfiles"

if [ ! -d "${DOTFILES_DIR}" ]; then
  echo "Error: Expected source directory ${DOTFILES_DIR} was not found." >&2
  exit 1
fi

CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}"

link_target() {
  src="${1}"
  dst="${2}"
  mkdir -p "$(dirname "${dst}")"
  ln -sfn "${src}" "${dst}"
}

for pkg in "${DOTFILES_DIR}"/*/; do
  [ ! -d "${pkg}" ] && continue

  # Strip trailing slash for cross-platform symlink consistency.
  pkg="${pkg%/}"
  pkg_name=$(basename "${pkg}")

  link_target "${pkg}" "${CONFIG_DIR}/${pkg_name}"

  case "${pkg_name}" in
    zsh)
      link_target "${pkg}/.zshenv" "${HOME}/.zshenv"
      ;;
  esac
done

# Normalize uname output, particularly a concern on Windows with MSYS2.
platform_string="$(uname -s)"
case "${platform_string}" in
  Linux*)   platform="Linux" ;;
  Darwin*)  platform="Darwin" ;;
  FreeBSD*) platform="FreeBSD" ;;
  MSYS_NT*) platform="MSYS2" ;;
  *)        platform="Unknown" ;;
esac

post_install_script="${DOTFILES_DIR}/post_install.${platform}.sh"

if [ -x "${post_install_script}" ]; then
  "${post_install_script}"
fi
