#!/usr/bin/env zsh
# Settings for interactive shells only
#
# Load order reminder: zshenv, zprofile, zshrc, zlogin
# Global versions of each are evaluated before user dotfiles

if [[ -z "${ZDOTDIR}" ]]; then
  echo -e "Error: ZDOTDIR environment variable not configured. Aborting further .zshrc configuration.\n" >&2
  return 1
fi

# Configure and initialize completion system
zstyle ':completion:*:*:*:*:*files' ignored-patterns 'app.json'
zstyle ':completion:*' completer _complete _ignored _prefix
autoload -Uz compinit
compinit -d "${ZDOTDIR}/.zcompdump"

# First try Homebrew completion locations if available
if [[ -n "${HOMEBREW_PREFIX}" ]]; then
  brew_completions=(
    "${HOMEBREW_PREFIX}/share/zsh/site-functions"
    "${HOMEBREW_PREFIX}/share/zsh-completions"
  )

  for dir in "${brew_completions[@]}"; do
    if [[ -d "${dir}" ]]; then
      fpath=("${dir}" $fpath)
    fi
  done
else
  # Fallback to common system locations if Homebrew isn't available
  # TODO - Validate on latest FreeBSD and Windows MSYS2
  system_completions=(
    "/usr/local/share/zsh-completions"
    "/usr/local/share/zsh/site-functions"
    "/usr/share/zsh/site-functions"
    "/usr/share/zsh/vendor-completions"
  )

  for dir in "${system_completions[@]}"; do
    if [[ -d "${dir}" ]]; then
      fpath=("${dir}" $fpath)
    fi
  done
fi

local fpath_local="${ZDOTDIR}/functions"
local compdir_local="${ZDOTDIR}/completions"
if [[ ! -f "${compdir_local}/.generated" ]]; then
  echo -e "Shell completion cache not found. Run 'zsh-update-completions' to generate it.\n" >&2
fi
# Prepend function and completion dirs to any of the ones found above
fpath=("${fpath_local}" "${compdir_local}" $fpath)
autoload -Uz "${fpath_local}"/*(N.:t) # Handle the dir being empty, match only local files, return just the filenames

# Load aliases. Functions are autoloaded by name
[[ -f "${ZDOTDIR}/.aliases.zsh" ]] && source "${ZDOTDIR}/.aliases.zsh"

# .devtools.zsh has already been loaded by .zshenv, just need to activate hooks
autoload -U add-zsh-hook

# uv
if (( "${+commands[uv]}" )); then
  add-zsh-hook chpwd uv-autoactivate
  uv-autoactivate  # Run once when shell starts
fi

# volta
if (( "${+commands[volta]}" )); then
  add-zsh-hook chpwd volta-autohint
  volta-autohint # Run once when shell starts
fi

# Shell history config
# Explicitly NOT exported, so a nested non-zsh shell like bash doesn't clobber the history
# A lesson learned from https://github.com/stapelberg/configfiles
typeset +x HISTFILE="${ZDOTDIR}/.zsh_history"

# Load a lot of history, but save everything
# TODO: Some kind of auto-archive to prevent it from ever getting this large?
# This is just to avoid ever losing a log entry
typeset -x HISTSIZE=1000000
typeset -x SAVEHIST=10000000

# (These are at the end, in case something irritating above overrode them)
# Set emacs keybindings; vi mode is missing too many vim motions, unfortunately
bindkey -e
# Unbind default Ctrl-S / Ctrl-Q behavior
stty stop undef
stty start undef
# Ctrl-S becomes the inverse of Ctrl-R
bindkey '^S' history-incremental-search-forward

# Configure line-editor in a portable way
# .zshenv unsets GLOBAL_RCS, so no OS default will handle this
zmodload zsh/terminfo 2>/dev/null
typeset -g -A key
# Bind standard editing keys to appropriate terminfo entries
[[ -n "$terminfo[kbs]" ]] && key[Backspace]=$terminfo[kbs]
[[ -n "$terminfo[kdch1]" ]] && key[Delete]=$terminfo[kdch1]
[[ -n "$terminfo[khome]" ]] && key[Home]=$terminfo[khome]
[[ -n "$terminfo[kend]" ]] && key[End]=$terminfo[kend]
[[ -n "$terminfo[kcuu1]" ]] && key[Up]=$terminfo[kcuu1]
[[ -n "$terminfo[kcud1]" ]] && key[Down]=$terminfo[kcud1]
[[ -n "$terminfo[kcbt]" ]] && key[ShiftTab]=$terminfo[kcbt]
# Map available keys to line-editor behaviors
[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search
[[ -n ${key[ShiftTab]} ]] && bindkey "${key[ShiftTab]}" reverse-menu-complete

# Ensure terminal is in application mode when ZLE is active
# Required for terminfo cursor/keypad strings to match actual terminal output
# (Lack of this is why old vim ":!somecmd" subprocesses had terrible input handling)
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  # The explicit TTY redirect here bypasses the standard ZLE output tracker
  # Without this, it's possible to get the white-background `%` output from
  # zsh's PROMPT_SP feature during transitions, or at shell startup
  function enable_app_mode() { echoti smkx >$TTY 2>/dev/null }
  function disable_app_mode() { echoti rmkx >$TTY 2>/dev/null }

  # Convert to ZLE widgets to avoid conflict with the zle-line-init namespace
  zle -N enable_app_mode
  zle -N disable_app_mode

  add-zle-hook-widget line-init enable_app_mode
  add-zle-hook-widget line-finish disable_app_mode
fi

# Classic prompt with suffix of the final component of the working dir path
typeset -x PROMPT='%n@%m %1~ %# '
