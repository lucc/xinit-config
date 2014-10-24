# ~/.xinitrc file by luc
# vim: filetype=sh

arch_xinit_scel () {
  #!/bin/sh
  #
  # ~/.xinitrc
  #
  # Executed by startx (run your window manager from here)

  if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
      [ -x "$f" ] && . "$f"
    done
    unset f
  fi

  # exec gnome-session
  # exec startkde
  # exec startxfce4
  # ...or the Window Manager of your choice
}

load_xmodmap () {
  (sleep 1 && xmodmap ~/.Xmodmap) &
  xmodmap ~/.Xmodmap
}

# we build up a variable to be exec'ed at the end of the script
CMD=

# first start some important background programs

# how will i handle ssh stuff?

# TODO

# last we start the wm/de

## this does not seem to work
#case "${1:-awesome}" in
#  awesome) CMD=awesome;;
#  gnome)   CMD=gnome-session;;
#  lxde)    CMD=lxsession;;
#  openbox) CMD=openbox;;
#  xfce)    CMD=xfce4-session;;
#esac

arch_xinit_scel

case `uname | tr A-Z a-z` in
  linux)
    CMD=awesome
    exec $CMD
    ;;
  darwin)
    xterm
    ;;
esac
