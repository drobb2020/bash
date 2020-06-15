#!/bin/bash
MEM=$(cat /proc/meminfo | grep MemTotal | cut -f 8 -d " ")
MEMG=$(echo "scale=3; $MEM/1000000" | bc)
UDEVNEWVAL=$(echo "(128 +(125 * $MEMG)) * 2" | bc | cut -f 1 -d ".")

UDEV1=$(cat /etc/sysconfig/udev | grep -w UDEVD_MAX_CHILDS | cut -f 2 -d "=")

UDEV2=$(cat /etc/sysconfig/udev | grep -w UDEVD_MAX_CHILDS_RUNNING | cut -f 2 -d "=")

echo "The current udev value for max childs is: $UDEV1"
echo "The current udev value for max childs running is: $UDEV2"
echo "The new value for both will be: $UDEVNEWVAL"

sed -i "s/UDEVD_MAX_CHILDS=$UDEV1/UDEVD_MAX_CHILDS=$UDEVNEWVAL/" /etc/sysconfig/udev
sed -i "s/UDEVD_MAX_CHILDS_RUNNING=$UDEV2/UDEVD_MAX_CHILDS_RUNNING=$UDEVNEWVAL/" /etc/sysconfig/udev
