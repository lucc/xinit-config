#!/bin/sh
# ~/.xinitrc file by luc
# vim: filetype=sh

dir=${XDG_CONFIG_HOME:-$HOME/.config}/xinit

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
  xmodmap $dir/Xmodmap
}
setup_colors () {
  xrdb -merge $dir/Xresources
}
cbatticon_power_manager () {
  # use cbatticon as a simple power manager
  (cbatticon \
    --low-level 10 \
    --command-critical-level "sh -c 'check-suspend.sh -d 30'" &)
}
load_ssh_keys () {
  SSH_ASKPASS=$HOME/bin/pass-as-ssh-askpass.sh \
    ssh-add $HOME/.ssh/*id_rsa < /dev/null
}

start_awesome () {
  source_global_xinit
  setup_keyboard
  setup_colors
  cbatticon_power_manager &
  (sleep 60 && load_ssh_keys) &
  #firefox &
  #xterm &
  exec awesome
}
start_openbox () {
  source_global_xinit
  setup_keyboard
  setup_colors
  cbatticon_power_manager
  exec openbox
}
start_xmonad () {
  source_global_xinit
  setup_keyboard
  setup_colors
  cbatticon_power_manager &
  exec xmonad
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
  openbox) start_openbox;;
  xfce)    CMD=xfce4-session;;
  xmonad)  start_xmonad;;
esac

exec $CMD
