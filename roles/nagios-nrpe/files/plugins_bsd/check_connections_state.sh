#!/bin/sh

STATE=0
MAIN_CONNECTION_PINGABLE_IP="31.170.8.95"
MAIN_CONNECTION_GATEWAY="IP"
MAIN_CONNECTION_IP="IP"
SECOND_CONNECTION_PINGABLE_IP="31.170.8.243"
INFO_MAIN_CONNECTION="IP - Description"
INFO_SECOND_CONNECTION="IP - Description"
CURRENT_GATEWAY=$(/usr/bin/netstat -nr | /usr/bin/grep "default" | /usr/bin/awk '{print $2}')

IS_GATEWAY_IN_FILE=1
IS_VPN_USING_MAIN_CONNECTION=1
IS_PF_USING_MAIN_CONNECTION=1
CHECK_CARP=0

if [ "${CHECK_CARP}" = 1 ]; then
    CARP_STATUS=$(/sbin/ifconfig carp0 | /usr/bin/grep "status" | /usr/bin/awk '{print $2}')
    if [ "$CARP_STATUS" = "backup" ]; then
            echo "No check, I'm a backup"
            exit 0
    fi
fi

/sbin/ping -c1 -w1 ${MAIN_CONNECTION_PINGABLE_IP} >/dev/null 2>&1
if [ $? = 0 ]; then
    if [ "${CURRENT_GATEWAY}" != "${MAIN_CONNECTION_GATEWAY}" ]; then
        echo "Main connection is UP but not used as gateway !"
        STATE=2
    fi
else
    echo "Main connection (${INFO_MAIN_CONNECTION}) is down"
    STATE=2
    IS_GATEWAY_IN_FILE=0
    IS_VPN_USING_MAIN_CONNECTION=0
    IS_PF_USING_MAIN_CONNECTION=0
fi

/sbin/ping -c1 -w1 ${SECOND_CONNECTION_PINGABLE_IP} >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "Second connection (${INFO_SECOND_CONNECTION}) is down"
    STATE=2
fi

if [ "${IS_GATEWAY_IN_FILE}" = 1 ]; then
    /usr/bin/grep -q "${MAIN_CONNECTION_GATEWAY}" /etc/mygate
    if [ $? != 0 ]; then
        echo "Main connection is not set in /etc/mygate"
        STATE=2
    fi
fi

if [ "${IS_VPN_USING_MAIN_CONNECTION}" = 1 ]; then
    /sbin/ipsecctl -sa | /usr/bin/grep -q "${MAIN_CONNECTION_IP}"
    if [ $? != 0 ]; then
        echo "VPN is not using the main connection !"
        STATE=2
    fi
fi

if [ "${IS_PF_USING_MAIN_CONNECTION}" = 1 ]; then
    /sbin/pfctl -sr | /usr/bin/grep "route-to" | /usr/bin/grep -q "${MAIN_CONNECTION_GATEWAY}"
    if [ $? != 0 ]; then
        echo "PF is not using the main connection !"
        STATE=2
    fi
fi

if [ "${STATE}" = 0 ]; then
    echo "OK - Main connection is UP and used, second connection is UP"
fi

exit ${STATE}
