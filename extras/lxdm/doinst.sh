config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

config etc/lxdm/LoginReady.new
config etc/lxdm/PostLogin.new
config etc/lxdm/PostLogout.new
config etc/lxdm/PreLogin.new
config etc/lxdm/PreReboot.new
config etc/lxdm/PreShutdown.new
config etc/lxdm/lxdm.conf.new
config etc/lxdm/xinitrc.new

