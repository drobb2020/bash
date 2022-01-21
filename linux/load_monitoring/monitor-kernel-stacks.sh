#!/bin/sh
NDSDPID=$(pgrep ndsd); echo -e "Starting monitoring of Runnable threads kernel stack on \"$(date)\"" >> /tmp/proclog.txt ; for ((;;)); do find /proc -name stat -type f -exec sh -c 'STATUS=$(cut -d " " -f 3 $0); case "$STATUS" in "R") DIRNAME=$(dirname $0); echo -e "\n$(date)";cut -d " " -f 2 $0;echo ${DIRNAME}/stack; cat ${DIRNAME}/stack; esac' {} \;; sleep 1; done  >> /tmp/proclog.txt
