#!/bin/bash

# A script to gather  rug/zypper configuration at different stages of patching

echo "Rug Products" >> /root/rug_info-"$(date +%H%M)".txt
rug pd >> /root/rug_info-"$(date +%H%M)".txt
sleep 1
echo "Rug Service List" >> /root/rug_info-"$(date +%H%M)".txt
rug sl >> /root/rug_info-"$(date +%H%M)".txt
sleep 1
echo "Rug Catalogs" >> /root/rug_info-"$(date +%H%M)".txt
rug ca >> /root/rug_info-"$(date +%H%M)".txt

exit 0
