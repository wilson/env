#!/usr/bin/env zsh
# Environment config for otherwise-unhandled utilities
# Loaded from .zshenv
#
# Do NOT put API keys in this file!
#

# Prefer ADC to API keys with GCP
unset GOOGLE_API_KEY
unset GEMINI_API_KEY

# Add gcloud extensions to path if present
google_cloud_bin_dir="/opt/homebrew/share/google-cloud-sdk/bin" 
if [[ -d "${google_cloud_bin_dir}" ]]; then
  path=($path "${google_cloud_bin_dir}")
fi

# LM Studio CLI (lms)
# TODO - Move this to XDG_CONFIG_HOME if possible
local lmstudio_bin_dir="${HOME}/.lmstudio/bin"
if [[ -d "${lmstudio_bin_dir}" ]]; then
  path=($path "${lmstudio_bin_dir}")
fi

