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

function free_user_id {
  # Find a free user-ID >= 100 (should be < 1000 so it's not a normal user)
  local FREE_USER_ID=100
  while grep --quiet "^.*:.*:${FREE_USER_ID}:.*:.*:.*:" etc/passwd; do
    let FREE_USER_ID++
  done
  echo ${FREE_USER_ID}
}

function free_group_id {
  # Find a free group-ID >= 120 (should be < 1000 so it's not a normal group)
  local FREE_GROUP_ID=120
  while grep --quiet "^.*:.*:${FREE_GROUP_ID}:" etc/group; do
    let FREE_GROUP_ID++
  done
  echo ${FREE_GROUP_ID}
}

# Set up groups.
if ! grep --quiet '^gdm:' etc/group; then
  chroot . /usr/sbin/groupadd \
    -g $(free_group_id) \
    gdm 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^gdm:' etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/var/lib/gdm:[a-z/]*$' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "gdm"; then
    echo "Updating unprivileged user" 1>&2
  else
    echo -e "Changing unprivileged user \e[1m${OLD_USER}\e[0m" 1>&2
  fi
  chroot . /usr/sbin/usermod \
    -d '/var/lib/gdm' \
    -u ${USER_ID} \
    -s /bin/false \
    -g gdm \
    ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user" 1>&2
  chroot . /usr/sbin/useradd \
    -c 'GDM Daemon Owner' \
    -u $(free_user_id) \
    -g gdm \
    -s /bin/false \
    -d '/var/lib/gdm' \
    gdm 2> /dev/null
fi

chroot . usermod -a -G audio gdm &&
chroot . usermod -a -G video gdm

#config etc/pam.d/gdm-autologin.new
#config etc/pam.d/gdm-fingerprint.new
#config etc/pam.d/gdm-launch-environment.new
#config etc/pam.d/gdm-password.new
#config etc/pam.d/gdm-pin.new
#config etc/pam.d/gdm-smartcard.new
config etc/gdm/custom.conf.new

chroot . chown -R gdm:gdm /var/lib/gdm /var/cache/gdm /var/log/gdm
chroot . chmod 0755 /var/lib/gdm /var/cache/gdm /var/log/gdm

chroot . /usr/bin/dconf update

chroot . chown -R root:gdm /var/run/gdm
chroot . chmod 1777 /var/run/gdm

if [ -x /usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database -q usr/share/applications >/dev/null 2>&1
fi

if [ -e usr/share/icons/hicolor/icon-theme.cache ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache usr/share/icons/hicolor >/dev/null 2>&1
  fi
fi
if [ -e usr/share/glib-2.0/schemas ]; then
  if [ -x /usr/bin/glib-compile-schemas ]; then
    /usr/bin/glib-compile-schemas usr/share/glib-2.0/schemas >/dev/null 2>&1
  fi
fi
