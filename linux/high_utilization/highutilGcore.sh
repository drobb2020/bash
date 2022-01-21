#!/bin/bash
#################################################################
# Novell Inc.
# 1800 South Novell Place
# Provo, UT 84606-6194
# CoPyRiGhT=(c) Copyright 2008, Novell, Inc. All rights reserved
# Script Name: highutilnew.sh 
# Description: This script will gstack the ndsd process the amount of times specified when loading the script.
#              After each gstack is taken and written the script pauses 10seconds before grabing the next gstack. 
#              It writes gstack output information to the /root/ directory Example:  /root/gstack1.log - gstack5.log if you want 5 gstacks.
#              After the last gstack is taken the script uses gdb to gcore the NDSD process ONE time.
#              It automatically uses novell-getcore and bundles the core file in the current working directory where you ran the script from.
# 
# Version: 1.1.0
# Creation Date: Thu Dec 2 2012 
# Created by: Randy Steele - Novell Technical Services
# Updated on: 12/12/2012   Added Top Stats for ndsd PID 
#                                                                
#################################################################

### Variables ###
	echo -ne "How many gstacks do you want the script to gather (Example: 5): "
	read GSTACKLOOPS
	echo -ne "How long do you want the script to sleep in seconds between each gstack (Example: 10): "
	read GSTACKSLEEPTIME
	echo -e "$@" "You have set the script to grab $GSTACKLOOPS gstacks. Note: Between each gstack taken the script will pause for $GSTACKSLEEPTIME seconds."
        OF=/tmp/novell/gstackoutput.log

### Functions ###
createDir(){
        if [ ! -d /tmp/novell ]
        then
                /bin/mkdir -p /tmp/novell && echo "Created /tmp/novell directory for outputfiles"
        else    echo "Novell directory already created for outputfiles"
        fi
}
        createDir

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


	
while (true)
do	
	PATHTOCONF=/etc/opt/novell/eDirectory/conf/nds.conf
	VARDIR=`/bin/cat $PATHTOCONF |grep -i "vardir" |awk -F = '{print $2}'`
	#echo $VARDIR
	NDSD_PID=`/bin/cat $VARDIR/ndsd.pid`
	#echo $NDSD_PID
	GSTACKCOUNTER=0
	while [ $GSTACKCOUNTER -lt $GSTACKLOOPS ]
	do
		GSTACKCOUNTER=`expr $GSTACKCOUNTER + 1`
		GSTACKLOGS=/tmp/novell/gstack$GSTACKCOUNTER.log
		logdate
		log "[*] Grabbing a gstack and writing to $GSTACKLOGS for the ndsd process PID# $NDSD_PID " 
		/bin/date >>$GSTACKLOGS
		log "***Start writing Top stats for ndsd PID $NDSD_PID***"
		/usr/bin/top -b -n1 -p $NDSD_PID >>$GSTACKLOGS
		log "" >>$GSTACKLOGS
		log "-----------------top -H per thread %CPU of ndsd Process----------------" >>$GSTACKLOGS
		/usr/bin/top -b -n1 -H -p $(pidof ndsd) |grep ndsd >>$GSTACKLOGS
		log "[*] Finished writing Top stats for ndsd PID $NDSD_PID successfully! "
		echo "" >>$OF
		log "***Start of gstack data writing***"
		echo "***Start of gstack data writing***" >>$GSTACKLOGS
		/usr/bin/gstack $NDSD_PID >>$GSTACKLOGS
	#	echo "-------------CPU % Per Thread Data--------------" >>$GSTACKLOGS
	#	/bin/ps -C ndsd -L -o pid,tid,nlwp,pcpu,pmem,vsz,stat >>$GSTACKLOGS
	#	echo "" >>$OF
		log "[*] Finished writing $GSTACKLOGS log successfully! "
		log "[*] Sleeping for $GSTACKSLEEPTIME seconds! "
		sleep $GSTACKSLEEPTIME
	done
	echo "" >>$OF     #NEW LINE 
	log "--------------------------------------------------------------------" 
	echo "" >>$OF 
	logdate
	log "##### Forcing a GCORE of the ndsd process PID#$NDSD_PID in PWD $PWD ##### " 
	/usr/bin/gcore $NDSD_PID
	echo "" >>$OF
	logdate 
	log "[*]------ Finished writing the gcore file core.$NDSD_PID -----"
	log "[*]------ Using novell-getcore to bundle the core file ------ " 
	#/bin/pwd >>/tmp/pwd.txt
	PWD=`/bin/pwd` >/dev/null
	/opt/novell/eDirectory/bin/novell-getcore -b $PWD/core.$NDSD_PID
#CleanUP gcore and Move corebungle to /tmp/novell
	echo "Removing core.$NDSD_PID as part of Gcore cleanup!"
	COREBUNDLENAME=`ls -ltr core_*`
	rm $PWD/core.$NDSD_PID
	echo "Moving corebundle named $COREBUNDLENAME to /tmp/novell"
	/bin/mv $PWD/$COREBUNDLENAME /tmp/novell
	
	log "[*]------ Finished gathering all data requirements --------- "
	logscreen ""
	log "*** PLEASE GATHER AND SEND THE FOLLOWING DATA FILES BELOW ***"
	log ""
	log "[*] Please send the following log file /tmp/novell/gstackoutput.log "
	log "[*] Please send the following log files found in /tmp/novell/gstack1.log - /tmp/novell/gstack$GSTACKLOOPS.log "
	log "[*] Please send the core file bundle written in the current $PWD directory. Example of the core bundle filename would be core_20120827_132613_linux_ndsd_sles10sp4.tar.gz (core_currentdate_currenttime_linux_ndsd_servername.tar.gz) "
	exit
done






























