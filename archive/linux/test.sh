#!/bin/bash
MEM=$(cat /proc/meminfo | grep MemTotal | cut -f 8 -d " ")
MEMG=$(echo "scale=3; $MEM/1000000" | bc)
UDEVNEWVAL=$(echo "(128 +(125 * $MEMG)) * 2" | bc | cut -f 1 -d ".")

echo "udev values will be increased to: $UDEVNEWVAL"

for i in $(cat /etc/sysconfig/udev | grep UDEVD_MAX_CHILDS | cut -f 2 -d "=")
    do
	udevarray[$i]="$i"
    done

echo "Current values are: ${udevarray[@]}"

for i in ${udevarray[@]}
   do
       sed -i "s/$i/$UDEVNEWVAL/g" /etc/sysconfig/udev
   done

exit
