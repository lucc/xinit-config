#!/bin/sh
# ~/.xinitrc file by luc
# vim: filetype=sh

dir=${XDG_CONFIG_HOME:-$HOME/.config}/xinit

ask_yes () {
  zenity --question --timeout 3 --text "$1"
  case $? in
    0|5) return 0;;
    1) return 1;;
    *) echo Unknown return value from zenity. >&2; return 2;;
  esac
}
ask_no () {
  zenity --question --timeout 3 --text "$1"
  case $? in
    0|5) return 1;;
    1) return 0;;
    *) echo Unknown return value from zenity. >&2; return 2;;
  esac
}
set_env () {
  # The custom theme variables used by other scripts (awesome rc files and
  # colorscheme.sh).
  export THEME=${THEME:-SOLARIZED}
  export theme=${theme:-solarized}
  export TONE=${TONE:-DARK}
  export tone=${tone:-dark}
}
setup_urxvt () {
  #export RXVT_SOCKET="$ddir/urxvt/urxvtd-`hostname`"
  export RXVT_SOCKET=$(systemctl --user show-environment | sed -n 's/^XDG_RUNTIME_DIR=//p')/urxvtd.socket
  #systemctl --user start urxvtd.socket
}
setup_firefox_plugins () {
  cdir=${dir%/*}
  _profile_export_vimperator_init () {
    export VIMPERATOR_INIT="source $cdir/vimperator/vimperatorrc"
    export VIMPERATOR_RUNTIME="$cdir/vimperator"
  }
  _profile_export_pentadactyl_init () {
    export PENTADACTYL_INIT="source $cdir/pentadactyl/pentadactylrc"
    export PENTADACTYL_RUNTIME="$cdir/pentadactyl"
  }
  _profile_export_vimperator_init
}
source_global_xinit () {
  # copied from the arch linux default xinitrc file.
  if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
      [ -x "$f" ] && . "$f"
    done
    unset f
  fi
}
setup_keyboard () {
  setxkbmap -option terminate:ctrl_alt_bksp -layout de
  xmodmap "$dir/Xmodmap"
}
setup_colors () {
  xrdb -merge -DTONE="$TONE" -DTHEME="$THEME" "$dir/Xresources"
}
cbatticon_power_manager () {
  # use cbatticon as a simple power manager
  cbatticon \
    --low-level 10 \
    --command-critical-level "sh -c 'check-suspend.sh -d 30'" &
}
load_ssh_keys () {
  SSH_ASKPASS=$(which pass-as-ssh-askpass.sh) \
    ssh-add "$HOME"/.ssh/*id_rsa < /dev/null
}
autostart () {
  sleep 20 && systemctl --user start mpd-notification &
  firefox &
}

# first call some general initialisation code that should be run for every
# environment
set_env
setup_urxvt
setup_firefox_plugins
source_global_xinit
setup_keyboard
setup_colors
ask_yes "Do you want a full start?" && autostart &
sleep 60 && load_ssh_keys &

# select the correct programm to exec (and optionally call additional init
# functions)
if [ $# -eq 0 ]; then
  # select the default WM/DE for different systems
  case $(uname | tr A-Z a-z) in
    linux) set awesome;;
    darwin) set xterm;;
  esac
fi
if [ $# -eq 1 ]; then
  # run some WM/DE specific init functions and set the command to exec
  case "$1" in
    awesome|openbox|xmonad) cbatticon_power_manager &;;
    gnome) set gnome-session;;
    kde) set startkde;;
    lxde)
      if which startlxde; then set startlxde
      else set lxsession
      fi;;
    xfce)
      if which startxfce4; then set startxfce4
      else set xfce4-session
      fi;;
  esac
fi

# start the window manager or desktop environment
exec "$@"
