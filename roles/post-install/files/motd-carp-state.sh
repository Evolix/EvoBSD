#!/bin/sh

if [ ! -f /etc/motd-original ]; then
    cp /etc/motd /etc/motd-original
fi

if [ ! -f /tmp/carp.state ]; then
    # Replace OpenBSD version in motd after each boot for it to be up to date after an upgrade
    sed -i "1 s/^.*$/$(head -1 \/var\/run\/dmesg.boot)/" /etc/motd-original
    echo "unknown" > /tmp/carp.state
fi

ifconfig carp0 | grep -q master
master=$?
ifconfig carp0 | grep -q backup
backup=$?

if [ "$master" -eq 0 ]; then
    if [ $(cat /tmp/carp.state) = "master" ]; then
        # We already were master, no change
        exit 0
    fi
cat /etc/motd-original - << EOF > /etc/motd
    __  ______   _____________________
   /  |/  /   | / ___/_  __/ ____/ __ \ 
  / /|_/ / /| | \__ \ / / / __/ / /_/ /
 / /  / / ___ |___/ // / / /___/ _, _/
/_/  /_/_/  |_/____//_/ /_____/_/ |_|

EOF
echo "master" > /tmp/carp.state
elif [ "$backup" -eq 0 ]; then
    if [ $(cat /tmp/carp.state) = "backup" ]; then
        # We already were backup, no change
        exit 0
    fi
cat /etc/motd-original - << EOF > /etc/motd
    ____  ___   ________ ____  ______ 
   / __ )/   | / ____/ //_/ / / / __ \ 
  / __  / /| |/ /   / ,< / / / / /_/ /
 / /_/ / ___ / /___/ /| / /_/ / ____/ 
/_____/_/  |_\____/_/ |_\____/_/      

EOF
echo "backup" > /tmp/carp.state
else
    # No CARP
    exit 0
fi
