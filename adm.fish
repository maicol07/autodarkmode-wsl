#!/usr/bin/fish

# TODO: Split files into config, functions, logging

# Script to switch program themes based on windows theme in WSL
# Author: Sayandip Dutta

# Usage:
#   1. Without argument
#       $ source adm.sh
#         If called without argument, theme is set according to windows registry value
#
#   2. With argument (Intended to be called by AutoDarkMode)
#       $ source adm.sh 0
#      OR
#       $ source adm.sh 1
#         Valid arguments are 0 (Dark) or 1 (Light).

# pass command line argument to functions.sh
if test \( (count $argv) -ne 0 \) -a \( $argv[1] -eq 0 -o $argv[1] -eq 1 \)
    source (dirname "$0")/functions.fish $argv[1]
else
    source (dirname "$0")/functions.fish
end

# Set program connfig paths
set -l LAZYGIT_CONFIG ~/.config/lazygit/{config.yml,light.yml,dark.yml}
# NVIM_CONFIG=(~/.config/nvim/lua/user/{colorscheme.lua,tokyonight.light.lua,tokyonight.dark.lua})
set -l BAT_CONFIG ~/.config/bat/{bat.conf,light.conf,dark.conf}
# TMUX_CONFIG=(~/.config/tmux/{tokyonight.tmux,tokyonight_day.tmux,tokyonight_night.tmux})
set -l GLOW_CONFIG ~/.config/glow/{glow.yml,light.yml,dark.yml}
# IPYTHON_CONFIG=(~/.ipython/profile_default/{ipython_config.py,light.py,dark.py})
set -l GTKTHEME_CONFIG Fluent

# Corresponding functions are defined in ./functions.sh
linkconfig $LAZYGIT_CONFIG soft
linkconfig $BAT_CONFIG soft
linkconfig $GLOW_CONFIG soft
# linkconfig "${IPYTHON_CONFIG[@]}" soft
# linkconfig "${TMUX_CONFIG[@]}" soft
# tmux source-file "${TMUX_CONFIG[1]}"


# linkconfig "${NVIM_CONFIG[@]}" hard
# set_open_nvim_theme

gtktheme "$GTKTHEME_CONFIG"
