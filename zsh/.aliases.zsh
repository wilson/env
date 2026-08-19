#!/bin/zsh
# Aliases only, no functions or exports
# Always use long-form options when possible, no reason to be doubly-concise
# Use the `topcmds` function periodically to devise more aliases based on frequent invocations

# Allows aliases to work with sudo
# Use with caution, prefer explicit `sudo -i` sessions
alias sudo='sudo '

# Editors
alias nv='neovide --fork --reuse-instance'
alias v="${VISUAL:-nvim}"

# ls config
# (Irritatingly color support is not fully portable)
if [[ "${OSTYPE}" == darwin* || "${OSTYPE}" == freebsd* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
# Only POSIX short flags are portable
alias ll='ls -halF'
alias lt='ll -tr'
alias lS='ll -Sr'

# Aliases for use with zsh Glob Qualifiers.
# See `man zshexpn`, e.g. `l *.mkv(m-2Om)`
alias l='print -l'
alias recent='print -l *(m-2Om.DN)'
alias recentr='print -l **/*(m-2Om.N)'
alias recentl='lt *(m-2.DN)'
alias recentlr='lt **/*(m-2.N)'

# Git
# Some options here are now redundant given the expected global Git config
# This is intentional as documentation and "belt and suspenders" safety
alias ga='git add'
alias gau='git add --update'
alias gc='git commit --verbose'
alias gca='git commit --amend --reset-author --no-edit'
alias gcl='git clone --verbose --no-progress'
alias gco='git checkout --no-guess'
alias gd='git diff --histogram'
alias gdc='git diff --histogram --cached'
alias gfp='git fetch --all --prune'
alias gl='git log --color --oneline --decorate'
alias glp='git log --color --patch --abbrev-commit --histogram --relative-date --pretty=medium --ws-error-highlight=all --diff-filter=ad --ignore-space-at-eol'
alias gls='git log --color --patch --abbrev-commit --relative-date --name-status'
alias gp='git push'
alias gpr='git pull --rebase --ff-only'
alias gst='git status --short --branch'
alias gwc='git whatchanged'

# Legacy SCM nostalgia
alias sst="svn st --ignore-externals | grep -v ^X | sed -e $'s/^[R~DC].*/\e[31m&\e[0m/g' | sed -e $'s/^A.*/\e[32m&\e[0m/g' | sed -e $'s/^M.*/\e[33m&\e[0m/g'"

# Ruby/Rails nostalgia
alias ber='bundle exec rake'
alias ri='noglob ri' # Ruby scope syntax often involves meaningful zsh characters
alias ri-build='gem rdoc --all --no-rdoc --ri --overwrite'
alias rig='ri --gems'

# rsync
alias rsn='rsync --exclude=.DS_Store --recursive --human-readable --links --times --verbose --partial --progress'
alias rsv='rsn --rsh="ssh -v"'
alias rsn-normalized='rsn --chmod=D755,F644'
alias rsn-setgid='rsn --chmod=Dg+s,ug+w,Fo-w,a-x'

# Misc utilities
alias ddpids='ps -a|grep " dd "|grep -v grep|cut -d" " -f1'
alias ddstatus='kill -s INFO $(ddpids)'
alias dlist='diskutil list'
alias flactags='metaflac --export-tags-to=-'
alias rando='random-string'
alias rm-art='eyeD3 --remove-images **/*.mp3'
alias yt='yt-dlp --batch-file=- --quiet --cookies-from-browser=chrome --merge-output-format=mkv --console-title --default-search=auto --add-metadata --ignore-config --ignore-errors  --geo-bypass --no-playlist --playlist-random --hls-prefer-native --restrict-filenames --no-mtime --no-progress'
if (( ${+commands[udunits2]} )); then
  # https://docs.unidata.ucar.edu/udunits/current/udunits2prog.html
  alias unit='udunits2 -U' # Unicode UTF-8 output
fi

# Smooth Video Player
# Relies on having an "svp" profile in the mpv config file
# TODO - Test on more than just macOS
if (( ${+commands[mpv]} )); then
  alias svp='DYLD_FALLBACK_LIBRARY_PATH=/opt/homebrew/lib mpv --profile=svp'
fi
