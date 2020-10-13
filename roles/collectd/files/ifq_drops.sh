#!/bin/ksh

echo "PUTVAL $(hostname)/ifq_drops/count N:$(sysctl net.inet.ip.arpq.drops | awk -F= '{print $NF}')"
