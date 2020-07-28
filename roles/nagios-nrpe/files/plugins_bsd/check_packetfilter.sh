#!/bin/sh
  
. /usr/local/libexec/nagios/utils.sh

is_pf_disabled() {
    if [ -f /etc/rc.conf.local ]; then
        grep -q "pf=NO" /etc/rc.conf.local
    else
        # If /etc/rc.conf.local does not exist, pf cannot be disabled
        # If 0 then pf is disabled, so if /etc/rc.conf.local does not exist we have to return 1 => pf is not disabled
        return 1
    fi
}

is_pf_started() {
    pfctl -si | grep -q "Status: Enabled for"
}

main() {
    if ! is_pf_disabled; then
        if is_pf_started; then
            echo "OK: PacketFilter is enabled and started."
            exit "${STATE_OK}"
        else
            echo "CRITICAL: PacketFilter is enabled but not started."
            exit "${STATE_CRITICAL}"
        fi
    else
        if is_pf_started; then
            echo "WARNING: PacketFilter is started but not enabled."
            exit "${STATE_WARNING}"
        else
            echo "CRITICAL: PacketFilter is disabled and not started."
            exit "${STATE_CRITICAL}"
        fi
    fi

}

main
