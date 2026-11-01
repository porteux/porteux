#!/bin/sh
KDEDIRS=/usr
export KDEDIRS

if [ -d /usr/libexec/kf6 ]; then
  PATH="$PATH:/usr/libexec/kf6"
fi
export PATH

if [ -z "$XDG_CONFIG_DIRS" ]; then
  XDG_CONFIG_DIRS=/etc/xdg
fi

if [ -d /etc/kde/xdg ]; then
  XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS:/etc/kde/xdg
fi

export XDG_CONFIG_DIRS
