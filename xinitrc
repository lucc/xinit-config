#!/bin/sh -x
# ~/.xinitrc file by luc
# vim: filetype=sh

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
  setxkbmap de
  xmodmap ~/.homesick/repos/xinit/Xmodmap
}

setup_colors () {
  xrdb -merge ~/.homesick/repos/xinit/Xresources
  xrdb -merge ~/.homesick/repos/xinit/solarized.xterm
}

start_awesome () {
  source_global_xinit
  setup_keyboard
  setup_colors
  cbatticon &
  firefox &
  xterm &
  exec awesome
}

# TODO how will i handle ssh stuff?

# last we start the wm/de
case `uname | tr A-Z a-z` in
  linux) CMD=awesome;;
  darwin) CMD=xterm;;
esac

case "${1:-$CMD}" in
  awesome) start_awesome;;
  gnome)   CMD=gnome-session;;
  lxde)    CMD=lxsession;;
  openbox) CMD=openbox;;
  xfce)    CMD=xfce4-session;;
esac

exec $CMD
