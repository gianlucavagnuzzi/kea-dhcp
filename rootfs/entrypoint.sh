#!/bin/bash
set -x

: ${path_list:="
/path/foo
"}

function _dirs {
DEST_PATH="/data"

echo "--------------------------------------"
echo " Moving persistent data in $DEST_PATH "
echo "--------------------------------------"

for path_name in $path_list; do
 if [ ! -e ${DEST_PATH}${path_name} ]; then
  if [ -d $path_name ]; then
   rsync -Ra ${path_name}/ ${DEST_PATH}/
  else
   rsync -Ra ${path_name} ${DEST_PATH}/
  fi
 else
  echo "---------------------------------------------------------"
  echo " No NEED to move anything for $path_name in ${DEST_PATH} "
  echo "---------------------------------------------------------"
 fi
rm -rf ${path_name}
ln -s ${DEST_PATH}${path_name} ${path_name}
done
}

function _main {
 [ -e /run/kea/kea-dhcp4.kea-dhcp4.pid ] && rm /run/kea/kea-dhcp4.kea-dhcp4.pid
 [ ! -e /var/run/kea ] && mkdir -p /var/run/kea
 [ -e "/var/lib/kea/kea-dhcp4.conf" ] || cp "/template/kea-dhcp4.conf" "/var/lib/kea/"
 [ -e "/var/lib/kea/kea-dhcp6.conf" ] || cp "/template/kea-dhcp6.conf" "/var/lib/kea/"
 export CMDv6="kea-dhcp6 -c /var/lib/kea/kea-dhcp6.conf"

chown -R _kea: "/var/lib/kea"
}

custom_bashrc() {
cat <<'EOF'
export LS_OPTIONS="--color=auto"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -la'
alias l='ls $LS_OPTIONS -lA'

# prompt SOLO per shell interattive
if [[ $- == *i* ]]; then
  if [ "$(id -u)" -eq 0 ]; then
    PS1="\[\e[35m\][\[\e[31m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]# "
  else
    PS1="\[\e[35m\][\[\e[33m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]$ "
  fi
  export PS1
fi
EOF
}

setup_bashrc() {
  for home in /root /home/*; do
    [ -d "$home" ] || continue
    bashrc="$home/.bashrc"

    # crea se manca
    [ -f "$bashrc" ] || touch "$bashrc"

    # evita duplicazioni
    grep -q '### CUSTOM BASHRC ###' "$bashrc" && continue

    {
      echo ''
      echo '### CUSTOM BASHRC ###'
      custom_bashrc
    } >> "$bashrc"
  done
}

_main
setup_bashrc

# If any arguments were passed (i.e., CMD from Dockerfile), store them in CMD
[ "$#" -gt 0 ] && CMD="$@"

[ "$DHCP4" = "0" ] && export CMD=""
if [ "$DHCP6" = "1" ]; then
 [ -z "$CMD" ] && export CMD=$CMDv6 || $CMDv6 &
fi

[ -z "$CMD" ] && echo "Warning! DHCP not selected." && exit

# Ensure terminal state is restored and cursor is visible when the container exits
trap 'stty sane 2>/dev/null; tput cnorm 2>/dev/null' EXIT

# print cmd that will be executed
echo "Starting: $*" >&2

# Split CMD into proper arguments and execute
set -- $CMD
exec "$@"
