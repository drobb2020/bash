#!/bin/bash
REL=0.1-3

WHO=$(whoami)
IP1=$(/bin/ip a s | grep -w "inet" | grep -v 127 | awk '{print $2;}')
SPACE=`df -h | grep /dev/mapper | awk '{print $5}' | grep % | grep -v Use | sort -n | tail -1 | cut -d "%" -f1 -`
ALTVAL="80"
PN=`df -h | grep /dev/mapper | awk '{print $1, $5}' | awk '{print $NF,$0}' | sort -n | cut -f2- -d' ' | tail -1 | awk '{print $1}' | cut -f4 -d"/"`
PROCCOUNT=`ps -Afl | wc -l`
PROCCOUNT=`expr $PROCCOUNT - 5`
GROUPZ=`groups`
 
if [[ $GROUPZ == *users* ]]; then
  ENDSESSION=`cat /etc/security/limits.conf | grep "@users" | grep maxlogins | awk {'print $4'}`
  PRIVLAGED="Local User Account"
elif [ $WHO == root ]; then
  ENDSESSION="Unlimited"
  PRIVLAGED="Super User Account"
else
  ENDSESSION="Unlimited"
  PRIVLAGED="LUM-Enabled User Account"
fi

if [[ $SPACE == $ALTVAL ]]; then
  DA="The Linux Partition: $PN is at $SPACE % full!"
else
  DA="Linux partition space usage is normal"
fi

clear
echo -e "\033[1;32m
\033[37;1m                   CAS-DEV Tree\033[37;1m
\033[0;35m+++++++++++++++++: \033[0;37mSystem Data\033[0;35m :+++++++++++++++++++
+  \033[0;37mHostname \033[0;35m= \033[1;32m`hostname`
\033[0;35m+   \033[0;37mAddress \033[0;35m= \033[1;32m$IP1
\033[0;35m+    \033[0;37mKernel \033[0;35m= \033[1;32m`uname -r`
\033[0;35m+    \033[0;37mUptime \033[0;35m= \033[1;32m`uptime | awk '{print $3, $4, $5;}'| sed -e 's/,//'`
\033[0;35m+       \033[0;37mCPU \033[0;35m= \033[1;32m4x Intel(R) Xeon(R) E5620 @ 2.40GHz
\033[0;35m+    \033[0;37mMemory \033[0;35m= \033[1;32m`cat /proc/meminfo | grep MemTotal | awk {'print $2'}` kB
\033[0;35m++++++++++++++++++: \033[0;37mUser Data\033[0;35m :++++++++++++++++++++
+  \033[0;37mUsername \033[0;35m= \033[1;32m`whoami`
\033[0;35m+ \033[0;37mPrivlages \033[0;35m= \033[1;32m$PRIVLAGED
\033[0;35m+  \033[0;37mSessions \033[0;35m= \033[1;32m`who | grep $USER | wc -l` of $ENDSESSION Connections
\033[0;35m+ \033[0;37mProcesses \033[0;35m= \033[1;32m$PROCCOUNT of `ulimit -u` MAX
\033[0;35m++++++++++++++: \033[0;37mDisk Space Alert\033[0;35m :+++++++++++++++++
+\033[0;37mDisk Usage \033[0;35m= \033[1;32m$DA
\033[0;35m+++++++++++++: \033[0;37mHelpful Information\033[0;35m :+++++++++++++++
\033[0;35m+     \033[0;37mAdmin \033[0;35m= \033[1;32mcalvin.hamilton@rcmp-grc.gc.ca
\033[0;35m+       \033[0;37mDSE \033[0;35m= \033[1;32mdrobb@novell.com
\033[0;35m+++++++++++++++++++++++++++++++++++++++++++++++++++
\033[37;1m`cat /etc/motd-maint`
\033[37;1m`cat /etc/motd-chglg`
\e[0m"
