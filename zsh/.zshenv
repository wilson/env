#!/usr/bin/env zsh
# Settings for all zsh instances (interactive and non-interactive)
#
# Load order reminder: zshenv, zprofile, zshrc, zlogin
# Global versions of each are evaluated before user dotfiles

# Always use XDG style, even on legacy platforms
# Two sets of braces here to support stripping a trailing slash if present
# This would only occur on a misconfigured platform, but this normalizes it
typeset -gx XDG_CONFIG_HOME="${${XDG_CONFIG_HOME:-${HOME}/.config}%/}"
typeset -gx XDG_DATA_HOME="${${XDG_DATA_HOME:-${HOME}/.local/share}%/}"
# Not a standard, but helps maintain consistency across this config
typeset -gx XDG_LOCAL_HOME="${XDG_DATA_HOME:h}"

# The only zsh file in $HOME is a symlink to this .zshenv
# The symlink only needs to be followed on initial shell launch, subshells will inherit this
typeset -x ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# Block the OS (macOS in particular) from running /etc/zshrc or /etc/zprofile and mangling the PATH later on
# Ignores global rc files on other platforms as well, which may have similar behaviors
unsetopt GLOBAL_RCS

# Ensure path and PATH contain only unique entries
typeset -U path PATH

# Core utility env variables
typeset -x EDITOR="nvim"
typeset -x VISUAL="${EDITOR}"
typeset -x PAGER="less"
# less config equivalent to: "--shift 5 --no-init --clear-screen --RAW-CONTROL-CHARACTERS
# --chop-long-lines --squeeze-blank-lines --quit-if-one-screen --hilite-search
# --hilite-unread --tilde +--ignore-case"
typeset -x LESS="5XcRSsFgw~+i"
typeset -x LC_CTYPE="en_US.UTF-8"
typeset -x LANG="en_US.UTF-8"

# MacOS-specific config
if [[ $OSTYPE == darwin* ]]; then
  local macos_path_helper="/usr/libexec/path_helper"
  if [[ -x "${macos_path_helper}" ]]; then
    # Configure Apple's base system paths (including /etc/paths.d/)
    eval "$(${macos_path_helper} -s)"
  fi

  # Prevent .DS_Store files in archives
  typeset -x COPYFILE_DISABLE=true

  # Include brew bindir in PATH if it exists.
  # (HOMEBREW_PREFIX is used by .devtools.zsh as well)
  # Deliberately no support for non-standard Homebrew install locations
  if [[ -x /opt/homebrew/bin/brew ]]; then
    typeset -x HOMEBREW_PREFIX="/opt/homebrew"
    if [[ -d "${HOMEBREW_PREFIX}" ]]; then
      path=("${HOMEBREW_PREFIX}/bin" $path)
      typeset -xi HOMEBREW_AUTO_UPDATE_SECS=43200 HOMEBREW_API_AUTO_UPDATE_SECS=300 HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=7
      typeset -x HOMEBREW_NO_EMOJI="true" HOMEBREW_NO_ENV_HINTS="true"
    fi
  fi
fi

# Initialize all language support.
[[ -f "${ZDOTDIR}/.devtools.zsh" ]] && source "${ZDOTDIR}/.devtools.zsh"
# Miscellaneous utilities that aren't worth their own supporting file
# (Includes cloud-related tools)
[[ -f "${ZDOTDIR}/.misctools.zsh" ]] && source "${ZDOTDIR}/.misctools.zsh"

# Add XDG local bin path if present
# Last on purpose
if [[ -d "${XDG_LOCAL_HOME}/bin" ]]; then
  path=("${XDG_LOCAL_HOME}/bin" $path)
fi
