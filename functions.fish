#!/usr/bin/fish

if ! type -q getopts
    echo "getopts not found. Please install it with fisher: https://github.com/jorgebucaran/getopts.fish"
    exit 1
end

# log path
set LOGPATH (dirname (status --current-filename))/log/admlog.log
# restrict log file to last 1000 lines
# HACK: echo $(cmd) instead of cmd, because we are trying to modify the file inplace
# Thus the output of tail command needs to be loaded in memory
echo "$(tail -n 1000 $LOGPATH)" > $LOGPATH

# Log the time
begin
    echo "====================="
    date
    echo "====================="
end >> $LOGPATH

# Get current windows theme
# If theme==dark, $WINTHEME == 0, else 1

# if arg is 0 or 1 set it as WINTHEME
# Otherwise, find out wintheme value from windows registry
if test (count $argv) -ne 0
    and test \( $argv[1] -eq 0 -o $argv[1] -eq 1 \)
    # convert command line arg to int
    set WINTHEME (math $argv[1] + 0)
    echo "INFO: Called from AutoDarkMode with arg $WINTHEME" >> $LOGPATH
else
    set KEY 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    set PROP AppsUseLightTheme
    set LIGHT (powershell.exe -NoProfile -Command Get-ItemPropertyValue "$KEY" -Name "$PROP" | tr -d "\r")
    set WINTHEME (math $LIGHT + 0)
    echo "INFO: Called from Startup. Registry value $WINTHEME" >> $LOGPATH
end

if test $WINTHEME -eq 0
    set MODE dark
else
    set MODE light
end

# If a regular (i.e. non symlink) config file does not exist
# set theme by linking with appropriate theme file based on $WINTHEME
# takes four arguments:
#   $1 -> config path of a program
#   $2 -> corresponding light theme file
#   $3 -> corresponding dark theme file
#   $4 -> hard | soft | copy
#                    If hard is supplied as 4th arg, creates hard link
#                    If soft is supplied as 4th arg, creates symlink
#                    If copy is supplied as 4th arg, copies the file
function linkconfig
    set -l config_file $argv[1]
    set -l light_conf_file $argv[2]
    set -l dark_conf_file $argv[3]
    set -l mode $argv[4]
    # if first arg exists, unlink
    if test -e $config_file
        # unlink $config_file
    end
    set target ([ "$WINTHEME" -eq 0 ] && echo $dark_conf_file || echo $light_conf_file)
    switch $mode
        case hard
            ln "$target" "$config_file"
        case soft
            ln -s "$target" "$config_file"
        case copy
            cp "$target" "$config_file"
        case '*'
            echo "ERROR: Invalid mode $mode" >> $LOGPATH
            return
    end
    echo "INFO: Switched $config_file theme to $target" >> $LOGPATH
end

# look for any socket of the pattern /tmp/nvim_*/sock
# If present, remote-send set bg command
# set_open_nvim_theme() {
#     match=0
#     # HACK: ONLY WORKS FOR ZSH (https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers)
#     # set nullglob option for single glob pattern using N
#     # NOTE: POSIX generalized option: if (ls /tmp/nvim_*.sock) > /dev/null 2>&1 ; then "exists" ; fi
#     for socket in /tmp/nvim_*.sock(N); do
#         match=1
#         nvim --server "$socket" --remote-send ":set bg=${MODE}<cr>"
#     done
#     [ "$match" -eq 0 ] && echo "WARNING: Neovim not running" >>$LOGPATH
# }

# Takes one argument, i.e the name of the theme, e.g. `Adwaita`
# Switches wslg flavour to light or dark
function gtktheme
    # set --universal GTK_THEME "$1:$MODE"
    if test $WINTHEME -eq 0
        # Switch to dark theme
        gsettings set org.gnome.desktop.interface gtk-theme Fluent-dark
        gsettings set org.gnome.desktop.wm.preferences theme Fluent-dark
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark
        # jj -v "dukedark-tc" -o .config/micro/settings.json colorscheme
    else
        # Switch to light theme
        gsettings set org.gnome.desktop.interface gtk-theme Fluent-light
        gsettings set org.gnome.desktop.wm.preferences theme Fluent-light
        gsettings set org.gnome.desktop.interface color-scheme prefer-light
        # jj -v "dukelight-tc" -o .config/micro/settings.json colorscheme
    end
    echo "Switched GTK_THEME to $MODE" >> $LOGPATH
end
