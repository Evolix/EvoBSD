#!/bin/sh

# Use : ./check_ipsecctl_critiques.sh
# check_ipsecctl.sh must be installed
# Do not forget to also set variables under "Additional check with ping" : $VPNS + Definition of destination IPs + IPs in "case $vpn in"
# If needed, you can custom "local_ip" if the local IP used for ipsec is not the default one, or if multiples IP are use (e.g. "local_ip=192.0.2.[12]" if 192.0.2.1 and 192.0.2.2 are both used).

# Variables

CHECK_IPSECCTL="/usr/local/libexec/nagios/plugins/check_ipsecctl.sh"
STATUS=0
VPN_KO=""

default_int=$(route -n show -inet | grep default | awk '{ print $8 }' | grep -v pppoe0)
default_ip=$(ifconfig $default_int | grep inet | head -1 | awk '{ print $2 }')

# No check if CARP backup

carp=$(/sbin/ifconfig carp0 2>/dev/null | /usr/bin/grep 'status' | cut -d' ' -f2)

if [ "$carp" = "backup" ]; then
    echo "It's alright I'm just a backup!"
    exit 0
fi

# First check that isakmpd is running

if ! /usr/sbin/rcctl check isakmpd >/dev/null; then
    echo "CRITICAL : The isakmpd daemon is down. Start it with : rcctl start isakmpd && ipsecctl -f /etc/ipsec.conf"
    STATUS=2
fi

# Make sure "0.0.0.0" is not configured

if /sbin/ipsecctl -sa | grep -qF 0.0.0.0; then
    echo "CRITICAL : Configuration error on client side, \"0.0.0.0\" is configured and makes the network to bug. Check with \"ipsecctl -sa | grep -F 0.0.0.0\" which VPN is affected and shut it down, and contact the client or the VPN provider to solve the problem."
    STATUS=2
fi

# Check with "ipsecctl -sa"

for vpn in $(cat /etc/ipsec.conf | grep -v "^#" | awk '{print $2}'); do
    vpn=$(basename $vpn .conf\")
    local_ip=$default_ip
    remote_ip=$(grep -E "remote_ip" /etc/ipsec/${vpn}.conf | grep -v "^#" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
    $CHECK_IPSECCTL $local_ip $remote_ip "$vpn" > /dev/null
    if [ $? -ne 0 ]; then
        STATUS=2
        VPN_KO="$VPN_KO $vpn"
    fi
done

# Additional check with ping because "ipsecctl -sa" is not enough, only if previous checks didn't fail

if [ $STATUS -eq 0 ]; then

    # Definition of VPNs to be checked
    VPNS="A_from_vlan1 A_from_vlan2 B_from_vlan1 C_from_vlan2"

    # Definition of destination IPs (client side) to ping for each VPN
    A_from_vlan1_IP="192.168.1.1"
    A_from_vlan2_IP="192.168.2.1"

    B_from_vlan1_IP="172.16.1.1"

    C_from_vlan2_IP="10.0.1.1"

    for vpn in $VPNS; do
        # dst_ip takes the value of VPNS_IP
        eval dst_ip=\$${vpn}_IP
    
        # Definition of the source IP of the ping according to the source network used (our side, adjust the -I option)
        case $vpn in
            *vlan1*) ping -q -i 0.1 -I 192.168.5.5 -c 3 -w 1 $dst_ip >/dev/null ;;
            *vlan2*) ping -q -i 0.1 -I 172.16.2.5  -c 3 -w 1 $dst_ip >/dev/null ;;
        esac
    
        if [ $? -ne 0 ]; then
            VPN_KO="$VPN_KO $vpn"
        fi
    done
fi

if [ -n "$VPN_KO" ]; then
    echo "VPNs down:$VPN_KO"
    exit 2
else
    if [ "$STATUS" -eq 0 ]; then
        echo "ALL VPN(s) UP(s)"
        exit 0
    else
        exit $STATUS
    fi
fi
