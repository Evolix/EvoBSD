#!/bin/ksh

echo "PUTVAL $(hostname)/dns_stats/count N:$(doas /bin/cat /var/log/daemon | grep "server stats" | grep -v "requestlist max" | awk '{print $13}' | tail -1)"
