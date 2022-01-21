#!/bin/bash
LOGFILE=/root/logs/log.log

date | tee -a $LOGFILE
uptime | tee -a $LOGFILE
mount | tee -a $LOGFILE

echo "Make your command here." | tee -a $LOGFILE
echo "All standard output and error will get teed to the same log." | tee -a $LOGFILE

echo -e "=============================================================" >> $LOGFILE

exit

