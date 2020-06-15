#!/bin/bash
#################################################################
# Novell Inc.
# 1800 South Novell Place
# Provo, UT 84606-6194
# CoPyRiGhT=(c) Copyright 2008, Novell, Inc. All rights reserved
# Script Name: highutiljava.sh 
# Description: This script will gstack the java (tomcat/iManager) process the amount of times specified when loading the script.
#              After each gstack is taken and written the script pauses 10 seconds before grabing the next gstack. 
#              It writes gstack output information to the /root/ directory Example:  /root/gstack1.log - gstack5.log if you want 5 gstacks.
#              This script does not core the associated service or daemon!
# 
# Version: 1.2.0
# Creation Date: Tue Nov 28 2017
# Created by: Randy Steele - Novell Technical Services
# Modified by: David Robb - Dedicated Support Engineer
# Updated on: 12/12/2012   Added Top Stats for ndsd PID 
# Updated on: 28/11/2017   Reconfigured to capture gstacks of java/tomcat6/iManager issues
#                                                                
#################################################################

### Variables ###
	echo -ne "How many gstacks do you want the script to gather (Example: 5): "
	read GSTACKLOOPS
	echo -ne "How long do you want the script to sleep in seconds between each gstack (Example: 10): "
	read GSTACKSLEEPTIME
	echo -e "$@" "You have set the script to grab $GSTACKLOOPS gstacks. Note: Between each gstack taken the script will pause for $GSTACKSLEEPTIME seconds."
        OF=/tmp/novell/gstackoutput.log
	#NDSCONFDIR=/etc/opt/novell/eDirectory/conf/
	#LOGDIR=`cat $NDSCONF |grep n4u.server.log-file`
	#echo $LOGDIR 	
	#ndstrace -l 1> /dev/null &
	#NDSTRACEPID=$!
	#sleep 5
	#ndstrace -c "set ndstrace=nodebug"
	#ndstrace -c "ndstrace time tags ldap recm"
	#ndstrace -c "ndstrace file on"


### Functions ###
log (){
	echo -e "$@"
	echo -e "$@" >>$OF
}

logscreen (){
	echo -e "$@"
}

logdate (){
	echo `/bin/date` >>$OF
}
createDir(){
        if [ ! -d /tmp/novell ]
        then
                /bin/mkdir -p /tmp/novell && echo "Created /tmp/novell directory for outputfiles"
        else    echo "Novell directory already created for outputfiles"
        fi
}
        echo " "

createDir
        echo " "


	
while (true)
do	
	# PATHTOCONF=/etc/opt/novell/eDirectory/conf/nds.conf
	PIDDIR='/var/run/'
	# VARDIR=`/bin/cat $PATHTOCONF |grep -i "vardir" |awk -F = '{print $2}'`
	#echo $VARDIR
	# NDSD_PID=`/bin/cat $VARDIR/ndsd.pid`
	JAVA_PID=`/bin/cat $PIDDIR/novell-tomcat6.pid`
	echo $JAVA_PID
	GSTACKCOUNTER=0
	while [ $GSTACKCOUNTER -lt $GSTACKLOOPS ]
	do
		GSTACKCOUNTER=`expr $GSTACKCOUNTER + 1`
		GSTACKLOGS=/tmp/novell/gstack$GSTACKCOUNTER.log
		logdate
		log "[*] Grabbing a gstack and writing to $GSTACKLOGS for the java process PID# $JAVA_PID " 
		/bin/date >>$GSTACKLOGS
		log "***Start writing Top stats for java PID $JAVA_PID***"
		/usr/bin/top -b -n1 -H -p $JAVA_PID >>$GSTACKLOGS
		log "" >>$GSTACKLOGS
		log "-----------------top -H per thread %CPU of java process----------------" >>$GSTACKLOGS
		/usr/bin/top -b -n1 -H -p $JAVA_PID | grep java >>$GSTACKLOGS
		log "[*] Finished writing Top stats for java PID $JAVA_PID successfully! "
		log "***Start gathering CPU INFO per thread using PS command"
		log "[*] Finished writing CPU information Per Thread using PS command successfully"
		echo "-------------CPU % Per Thread Data--------------" >>$GSTACKLOGS
		/bin/ps -C java -L -o pid,tid,nlwp,pcpu,pmem,vsz,stat >>$GSTACKLOGS
		#echo "" >>$OF
		echo "" >>$OF
		#echo "-----------------Start of gstack thread data-----------------" >>$OF
		log "***Start of gstack data writing***"
		echo "--------------- Start of gstack thread data --------------" >>$GSTACKLOGS
		/usr/bin/gstack $JAVA_PID >>$GSTACKLOGS
		echo "---------------- Finished gstack thread data ---------------" >>$GSTACKLOGS
		log "[*] Finished writing $GSTACKLOGS log successfully! "
		log "[*] Sleeping for $GSTACKSLEEPTIME seconds! "
		sleep $GSTACKSLEEPTIME
	done
	echo "" >>$OF     #NEW LINE 
	log "--------------------------------------------------------------------" 
	echo "" >>$OF 
	#logdate
	#log "##### Forcing a GCORE of the ndsd process PID#$NDSD_PID in PWD $PWD ##### " 
	#/usr/bin/gcore $NDSD_PID
	#echo "" >>$OF
	#logdate 
	#log "[*]------ Finished writing the gcore file core.$NDSD_PID -----"
	#log "[*]------ Using novell-getcore to bundle the core file ------ " 
	#/bin/pwd >>/tmp/pwd.txt
	#PWD=`/bin/pwd` >/dev/null
	#/opt/novell/eDirectory/bin/novell-getcore -b $PWD/core.$NDSD_PID
	log "[*]------ Finished gathering all data requirements --------- "
	logscreen ""
	log "*** PLEASE GATHER AND SEND THE FOLLOWING DATA FILES BELOW ***"
	log ""
	#log "[*] Please send the following log file $OF "
	#log "[*] Please send the following log files found in $OF/gstack1.log - /root/gstack5.log "
	#ndstrace -c "ndstrace file off"
	#kill -INT $NDSTRACEPID
	#log "[*] Please send the core file bundle written in the current $PWD directory. Example of the core bundle filename would be core_20120827_132613_linux_ndsd_sles10sp4.tar.gz (core_currentdate_currenttime_linux_ndsd_servername.tar.gz) "   
	
	log "[*] Please send the following log file $OF "
	log "[*] Please send the following log files found in /tmp/novell/gstack1.log - /tmp/novell/gstack$GSTACKLOOPS.log "
	#log "[*] Please send the ndstrace log file found in /var/opt/novell/eDirectory/log/ndstrace.log "
	exit
done

