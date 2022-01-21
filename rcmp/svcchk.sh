#!/bin/sh
# Process Monitor
# Restart process when it has gone down
#
# ----------------------------------------------
# Created by Phil Desjardins - C Division 
# 2009 Original script to restart LUM
#
# Modified by Kevin Malinowski - K Divison
# February 2, 2010 Includes additional services
# and documentation.
# Email Notification added February 12, 2010 by
# Kevin Malinowski - K Division
# Documentation updated February 15, 2010 by
# Kevin Malinowski - K Division
# Updated 09-MAY-2010 to reflect this is a Domain
# server - changed gwpoa to gwmta. Also changed to
# reflect that since the GW8 upgrade, the rcgrpwise
# status result is now 'running', not 'done'.
# ----------------------------------------------
#
# This script will check to see if the status of
# a process is "running". If the process is not
# "running" it will then attempt to stop the 
# process. It will wait for 5 seconds and then
# confirm that there is no longer a pid for the 
# process. If a pid still exists it will
# determine the pid and kill the process. Once
# the process has been killed it will restart
# process.
#
# Note: NDSD does not return the standard 
#       status of "running" or "done", therefore the NDSD
#       script is different than what would be
#       used for other processes/services/daemons.
# ---------------------------------------------
#
# Each section of the script is configured to 
# evaluate the error condition and if that condition
# is met, send an email to the address defined in the 
# email parameters section.
#
# Note:  This does require that the relayhost value
#        is configured in the /etc/postfix/main.cf
#        configuration file.
#        eg. relayhost=[smtp.rcmp-grc.gc.ca]
#        (the square brackets are required)
#
# ---------------------------------------------
#
# This process can be scheduled with cron to 
# check on a regular basis.
#
# An example of a crontab entry to run this 
# script every 15 minutes would be:
#
# */15 * * * * sh /path/to/svcchk.sh > /dev/null 2>&1
#
# The > /dev/null 2>&1 ensures that any output
# of the script is not sent to the internal 
# mail box of the user configured to run the
# script. As well, the 2>&1 ensures that any 
# error codes generated are sent to the bit 
# bucket as well.
#
# --------------------------------------------
#
#
# --------------------------------------------
# Define eMail Parameters
# --------------------------------------------
#
emailTO=pr-dcg@rcmp-grc.gc.ca
mailmsg="/tmp/mailmsg.txt"

# --------------------------------------------
# LUM process check
# --------------------------------------------
#
/etc/init.d/namcd status | grep running
  if [ $? != 0 ]; then
# Send Email message
		subj=" `hostname` LUM service was down"
		echo "NAMCD on `hostname` was not running on `date`." > $mailmsg
		/bin/mail -s "$subj" "$emailTO" -r "--LUM--" < $mailmsg
		rm /tmp/mailmsg.txt 
# Restart Service 		
        /etc/init.d/namcd stop
        read -t5
        ps -A | grep namcd
        while [ $? = 0 ]; do 
           kill -9 ` ps -A | grep namcd | awk '{print $1}'`
           read -t2
           ps -A | grep namcd
         done
         /etc/init.d/namcd start
  fi
#
# --------------------------------------------
# NDSD process check
# --------------------------------------------
#
/etc/init.d/ndsd status | grep -i tree
  if [ $? != 0 ]; then
# Send Email message
		subj=" `hostname` NDSD service was down"
		echo "NDSD on `hostname` was not running on `date`." > $mailmsg
		/bin/mail -s "$subj" "$emailTO" -r "--NDSD--" < $mailmsg
		rm /tmp/mailmsg.txt 
# Restart Service   
  		/etc/init.d/ndsd stop
  		read -t25
  		ps -A | grep ndsd
  		while [ $? = 0 ]; do
  			kill -9 `ps -A | grep ndsd | awk '{print $1}'`
  			read -t2
  			ps -A | grep ndsd
  		done
        /etc/init.d/ndsd restart
  fi
#
# --------------------------------------------
# GW Domain process check
# --------------------------------------------
#
/etc/init.d/grpwise status | grep running
  if [ $? != 0 ]; then
# Send Email message
		subj=" `hostname` GroupWise service was down"
		echo "GroupWise on `hostname` was not running on `date`." > $mailmsg
		/bin/mail -s "$subj" "$emailTO" -r "--GroupWise--" < $mailmsg
		rm /tmp/mailmsg.txt 
# Restart Service   
        /etc/init.d/grpwise stop
        read -t5
        ps -A | grep gwmta
        while [ $? = 0 ]; do 
           kill -9 ` ps -A | grep gwmta | awk '{print $1}'`
           read -t2
           ps -A | grep gwmta
         done
         /etc/init.d/grpwise start
  fi 
  exit
