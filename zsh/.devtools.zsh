#!/usr/bin/env zsh
# Development tool configuration for zsh
# This file is sourced by .zshenv
# NOTE: Relies on `HOMEBREW_PREFIX` being set by .zshenv to indicate Homebrew support on the current platform

# Mise shims dir isn't exported to the PATH by default
typeset -x MISE_SHIMS_DIR="${XDG_DATA_HOME}/mise/shims"
if [[ -d "${MISE_SHIMS_DIR}" ]]; then
  path=("${MISE_SHIMS_DIR}" $path)
fi

# XDG relocation for Rust tools
typeset -x CARGO_HOME="${XDG_DATA_HOME}/cargo"
typeset -x RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

# Cargo PATH setup
local cargo_bin_dir="${CARGO_HOME}/bin"
if [[ -d "${cargo_bin_dir}" ]]; then
  path=("${cargo_bin_dir}" $path)
fi

# Volta Environment Setup
typeset -x VOLTA_HOME="${XDG_CONFIG_HOME}/volta"
if [[ -d "${VOLTA_HOME}" ]]; then
  path=("${VOLTA_HOME}/bin" $path)
else
  if (( ${+commands[volta]} )); then
    echo "Volta is installed, but VOLTA_HOME dir was not found at ${VOLTA_HOME}" >&2
  fi
fi

# Overkill Ruby PATH precision.
# Only proceed if we have Homebrew and its Ruby isn't already first in PATH
if [[ -n "${HOMEBREW_PREFIX}" ]]; then
  # Expected Ruby binary directory
  local ruby_bin_dir="${HOMEBREW_PREFIX}/opt/ruby/bin"

  if [[ -x "${ruby_bin_dir}/ruby" ]]; then
    # Set Ruby development flags
    typeset -x LDFLAGS="-L${HOMEBREW_PREFIX}/opt/ruby/lib"
    typeset -x CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/ruby/include"
    typeset -x PKG_CONFIG_PATH="${HOMEBREW_PREFIX}/opt/ruby/lib/pkgconfig"

    # Only perform expensive setup if the PATH was actually wrong.
    if [[ ! "${commands[ruby]}" -ef "${ruby_bin_dir}/ruby" ]]; then

      # Get user gems based on Ruby version
      if ruby_version=$("${ruby_bin_dir}/ruby" -e 'puts Gem.ruby_version' 2>/dev/null); then
        # Find system gems directory
        system_gems_bin=$(find "${HOMEBREW_PREFIX}/lib/ruby/gems" -maxdepth 1 -type d 2>/dev/null | sort -V | tail -n 1)/bin

        user_gems_bin="${XDG_DATA_HOME}/gem/ruby/${ruby_version}/bin"

        # Set GEM_HOME to user directory
        typeset -x GEM_HOME="${XDG_DATA_HOME}/gem/ruby/${ruby_version}"

        # Force Ruby paths to the very beginning of PATH
        path=("${ruby_bin_dir}" "${user_gems_bin}" "${system_gems_bin}" $path)
      else
        echo "Unable to determine Ruby version, aborting Ruby/RubyGems PATH setup" >&2
      fi
    fi
  fi
fi

if (( ${+commands[ri]} )); then
  typeset -x RI='-f ansi --no-gems'
fi

# UV Python setup
local uv_python_version_dir=$(find-latest-python)
if [[ -n "${uv_python_version_dir}" && -x "${uv_python_version_dir}/bin/python3" ]]; then
  path=("${uv_python_version_dir}/bin" $path)
fi

# Add dotnet tools if present
# TODO - Can this be moved to XDG_CONFIG_HOME?
dotnet_local_path="${HOME}/.dotnet/tools"
if [[ -d "${dotnet_local_path}" ]]; then
  path=("${dotnet_local_path}" $path)
fi
dotnet_shared_path="/usr/local/share/dotnet"
if [[ -d "${dotnet_shared_path}" ]]; then
  path=("${dotnet_shared_path}" $path)
fi

# Java setup - will use Java 11 if available, otherwise latest
unset JAVA_HOME
java_home_util="/usr/libexec/java_home"
if [[ -x "${java_home_util}" ]]; then
  # Try Java 11 first, fall back to latest if not found
  typeset -x JAVA_HOME=$($java_home_util -F -v 11 2>/dev/null || $java_home_util 2>/dev/null)
  # Add to PATH only if Java is actually installed
  if [[ -n "${JAVA_HOME}" && -d "${JAVA_HOME}" ]]; then
    path=("${JAVA_HOME}/bin" $path)
  fi
fi
