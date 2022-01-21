#!/bin/bash

# Version 1.4.8.3 - January 20, 2022 - Minor code corrections
# Version 1.4.8.2 - July 7 2021 - Changed eDirectory disk space recommendations - Gino
# Version 1.4.8 - Mar 29 2021 - Added check for ndsrepair running, will wait upto 30 sec before skipping
# Version 1.4.8 - Mar 25 2021 - Added check for root, and fixed NDS Instance variable
# Version 1.4.7.1 - Mar 24 2021 - Bug hunt and formatting fixes
# Version 1.4.7 - Mar 24 2021 - Reconfigured for RedHat and custom location of NDS
# Version 1.4.6.1 - Mar 24 2021 - Fixed Diskchecking
# Version 1.4.6 - Mar 23 2021 - Added Dib cache checking
# Version 1.4.5.1 - Mar 22 2021 - Minor corrections to coredumpctl commands
# Version 1.4.5 - Mar 22 2021 - Corrected calculation of available memory on SLES11.
# Version 1.4.4 - Mar 19 2021 - Corrected DIB size vs Free Disk Check - added SystemD coredump check 
# Version 1.4.3 - Mar 19 2021 - Changed IDM checks to add versions and changed Diskpspace check to compare it with the size of the DIB
# Version 1.4.1 - Mar 19 2021 - Minor corrections
# Version 1.4 - Mar 19 2021 - Added OS Section to collect version and patch info. Updated memory section to use /proc/meminfo rather than free.
# Version 1.3 - Jan 12 2018 - Changed ndsstat command so that it wil work on SlES12 as well. 
# Version 1.2 - Jan 11 2018 - Gave options for different Disk Space checks. 
#			                - Added NDS Threads Check
#                           - Fixed error when listing core files and they don't exist
#                           - Added check for IDM and cache file sizes
# Version 1.1 - Jan 10 2018 - Added logic to control whether or not emails wil be sent

#*******************Variables that need to be customized for your Env****************

#Send an email or just Log the event, Options are 1 (to send emails and log events) and 0 (to not send emails) If 1 is selected then valid email address is needed below
SendEmail=0

#Email address to send reports to. To add another recipient, within the quotes add a ; to the list and then add the other email address. 
EmailTo="EnterEmailAddressHere"

#The size of free space to check for on the eDir volume This is in Kilobytes ....2000000 = 2G
# CHECK_DISK_SPACE=2000000

#The location of where you want the log to be put. The log gets recreated after every run
#LOG=/var/log/NDS_Health.txt

#DiskSpace Method option - Found that depending on OS and disk layout that this would output incorrect data. So I incorporated the 2 scenarios I ran into.
#If you enter a 1 then Diskspace check 1 will kick off, if you select a 2 then Diskspace check 2 will kickoff. 
# To determine which works best for you compare the results of this script with a manual output of the "df /var/opt/novell/eDirectory" on your server.
#
# If neither work right and you can not fix the script you can enter a 0 to prevent the DiskSpace check from running
DiskSpaceMethod=2

#*************************End Customizable Variables ****************************************

#*************************Variables used by script****************************************
HOST=$(/bin/hostname)
# IPADDR=$(/sbin/ifconfig | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'|head -1) #> /dev/null 2>&1
EmailSubject="HealthCheck on Server $HOST"
Divider="#############################################"
#The location of where you want the log to be put. The log gets recreated after every run
LOG=/var/log/NDS_Health-$HOST.txt

#*************************End Variables Used by Script******************************

#***********************Check user running script is Root***************************
if [[ $EUID -ne 0 ]]; then
        echo "You must be root to run this script"
        exit 1
fi
#*************************End of user check******************************

#*******************Setup Logfile and email data in logfile**************************

if [ -f "$LOG" ]; then
	rm "$LOG"
	echo -e "From: ""$HOST";
	echo -e "To: " "$EmailTo";
	echo -e "Subject: " "$EmailSubject";
	echo -e  "\t";
	echo -e "\teDirectory Health Check Results";
	echo "$Divider" >> "$LOG"
else
	echo -e "From: " "$HOST";
	echo -e "To: " "$EmailTo";
	echo -e "Subject: " "$EmailSubject";
	echo -e "\t";
	echo -e "\teDirectory Health Check Results";
	echo $Divider >> "$LOG"
fi

#******************************Health Checks***************************************
INSTANCE=$(ndsconfig get | grep Instance | awk '{ print $4 }' | cut -f 1-6 -d '/')
CONFIG=$(ndsconfig get | grep configdir | cut -f 2 -d '=')

# Check if eDir is installed and running, if so set variables
if [ -d "$CONFIG"/.edir ]; then # &&  test `pidof ndsd`; then
  DS_VERSION=$(/opt/novell/eDirectory/bin/ndsstat |awk /'Product/ {print $6,$7,$8}')
  DS_BINARY=$(/opt/novell/eDirectory/bin/ndsstat |awk /'Binary/ {print $3}')
  DS_SERVER=$(/opt/novell/eDirectory/bin/ndsstat |awk /'Server/ {print $3}')
  NCP_INTERFACE=$(grep -m1 ^n4u.server.interfaces "$INSTANCE"/nds.conf |awk -F"interfaces=" '{print $2}' |cut -f 1 -d @ |grep -v ^$);
  if [ $? -eq "1" ]; then
    if test "$(pidof ndsd)"; then
      NCP_INTERFACE=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.interfaces |awk -F"interfaces=" '{print $2}' |cut -f 1 -d @ |grep -v ^$) 
    fi
  fi
  if [ -z "$DS_BINARY" ]; then
		echo "eDirectory does not appear to be running" >> "$LOG"
    sendmail -vt < "$LOG"
    exit 1
  else
		echo "NDSServer: " "$DS_SERVER";
		echo "Edir Version: " "$DS_VERSION" "$DS_BINARY";
		echo "Network Address: " "$NCP_INTERFACE" >> "$LOG"
  fi
fi
# END Check if eDir is installed

# Check OS Version and Patch Status
echo "$Divider";
echo "";
echo -e "\tChecking OS Version....";
echo "" >> "$LOG"

OS=$(grep PRETTY_NAME /etc/os-release | awk '{ print $2 }' FS='=')
OSM=$(grep -w ID /etc/os-release | awk '{ print $2 }' FS='=' | sed 's/\"//g')
OSV=$(grep -w VERSION /etc/os-release | awk '{ print $2}' FS='=' | awk '{ print $1}' FS='-' | sed 's/\"//g' | cut -f 1 -d ".")
LAST_PATCH=$(rpm -qa --last | awk '{ print $2, $3, $4, $5, $6 }' | uniq | sort | awk 'END{print}')

if [ "$OSM" = "sles" ]; then
	PATCH=$(/usr/bin/zypper --non-interactive --no-gpg-checks patch-check | awk 'END{print}')
else
	PATCH=$(/usr/bin/yum check-update --security | awk 'END{print}')
fi

echo "${DS_SERVER} is running $OS.";
echo "The server was last patched on $LAST_PATCH.";
echo "There are $PATCH for this server.";
echo "$Divider" >> "$LOG"

# End of OS Checks

# Check Memory Usage 

echo "$Divider";
echo -e "\n";
echo -e "\tChecking Memory Usage....";
echo -e "\n" >> "$LOG"

AllowedFreeMem=10
MemTotal=$(grep MemTotal /proc/meminfo | awk '{ print $2 }')
MemFree=$(grep MemFree /proc/meminfo | awk '{ print $2 }')

if [ "$OSV" -eq 7 ] || [ "$OSV" -eq 8 ] || [ "$OSV" -eq 12 ] || [ "$OSV" -eq 15 ]; then
	MemAvail=$(grep MemAvailable /proc/meminfo | awk '{ print $2 }')
else
	MemCache=$(grep -w Cached /proc/meminfo | awk '{ print $2 }')
	MemBuff=$(grep Buffers /proc/meminfo | awk '{ print $2 }')
	MemAvail=$(("$MemFree" + "$MemCache" + "$MemBuff"))
fi

PercentageFree=$(("$MemTotal" / "$MemAvail"))
SwapTotal=$(grep SwapTotal /proc/meminfo | awk '{ print $2 }')
SwapFree=$(grep SwapFree /proc/meminfo | awk '{ print $2 }')
SwapUsed=$(("$SwapTotal" - "$SwapFree"))
SwapCalc=$(("$SwapUsed" / "$SwapTotal"))
SwapPercentUsed=${SwapCalc%.*}
AllowedSwapUsed=60

# Memory Information
if [ "$PercentageFree" -gt $AllowedFreeMem ]; then
		echo "**THE SERVER IS RUNNING LOW ON MEMORY**";
		echo "You have less than 10% Free memory and should consider increasing the installed memory";
		echo -e "\n";
		echo "There is a total of $MemTotal kB of memory with only $MemFree kB free";
		echo -e "\n";
		echo "There is a total of $MemAvail kB available on this server at this time.";
		echo "Run the free command or cat /proc/meminfo to check actual values";
		echo -e "\n" >> "$LOG"
else
		echo -e "\n";
		echo "Memory seems fine";
		echo "You have more than the minimum of 10% True Free Memory";
		echo -e "\n";
		echo "Total memory is $MemTotal kB";
		echo "Free memory is $MemAvail kB - this includes cache and buffers";
		echo -e "\n" >> "$LOG"
fi

# Swap information
echo $Divider;
echo -e "\n";
echo -e "\tChecking Swap Memory Usage....";
echo -e "\n" >> "$LOG"
	
if [ "$SwapPercentUsed" -gt $AllowedSwapUsed ]; then
	echo "**THE SERVER APPEARS TO BE USING SWAP MEMORY**";
	echo "The server is using more than 60% of swap memory";
	echo "This indicates that the server may be low on physical memory, or a process may be misbehaving. Running an additional tool called smem will provide details of swap usage.";
	echo -e "\n" >> "$LOG"
else
	echo "Swap memory usage appears fine.";
	echo "The server is using less than 60% of the configured swap memory.";
	echo "Total swap space is $SwapTotal kB";
	echo "Swap space free is $SwapFree kB";
	echo -e "\n" >> "$LOG"
fi

sleep 1

# Check Timesync 
Check=TimesyncCheck
echo $Divider;
echo -e "\n";
echo -e "\tRunning Timesync test....";
echo -e "\n" >> "$LOG"

COUNTER=30
while [  $COUNTER -gt 1 ]; do
    RepairRunningCount=$(pgrep -c ndsrepair)
    if [ "$RepairRunningCount" == 2 ]; then
        echo "Repair is still running, will wait upto to "$COUNTER " more seconds to perform "$Check
        sleep 1
        (( COUNTER=COUNTER-1 ))
    else
        (( COUNTER=0 ))
    fi	
done

edirtimesync=$(/opt/novell/eDirectory/bin/ndsrepair -T | grep -s "Total errors: 0")
 
if [ "$edirtimesync" == "" ]; then
	echo "Found Timesync Errors:";
	echo -e "\n" >> "$LOG"
	
	COUNTER=30
	while [  $COUNTER -gt 1 ]; do
        RepairRunningCount=$(pgrep -c ndsrepair)
        if [ "$RepairRunningCount" == 2 ]; then
            echo "Repair is still running, will wait upto to $COUNTER more seconds to perform $Check"
            sleep 1
            (( COUNTER=COUNTER-1 ))
        else
            (( COUNTER=0 ))
        fi	
	done
	
	/opt/novell/eDirectory/bin/ndsrepair -T |grep -i -B1 error >>"$LOG"
	
	echo " " >> "$LOG"
else
	echo -e "\n";
	echo "Time is in Sync";
	echo -e "\n" >> "$LOG"
fi

# Replica Sync
Check=ReplicaSync
echo $Divider;
echo -e "\n";
echo -e "\tRunning Replica Sync Test....";
echo -e "\n" >> "$LOG"

	COUNTER=30
	while [  $COUNTER -gt 1 ]; do
        RepairRunningCount=$(pgrep -c ndsrepair)
        if [ "$RepairRunningCount" == 2 ]; then
            echo "Repair is still running, will wait upto to "$COUNTER " more seconds to perform "$Check
            sleep 1
            (( COUNTER=COUNTER-1 ))
        else
            (( COUNTER=0 ))
        fi	
	done

    edirsync=$(/opt/novell/eDirectory/bin/ndsrepair -E | grep -s "Total errors: 0")

    if [ "$edirsync" == "" ]; then
        echo "Found Replica Sync Errors";
        echo -e "\n" >> "$LOG"
	
	COUNTER=30
	while [  $COUNTER -gt 1 ]; do
        RepairRunningCount=$(pgrep -c ndsrepair)
        if [ "$RepairRunningCount" == 2 ]; then
            echo "Repair is still running, will wait upto to "$COUNTER " more seconds to perform "$Check
            sleep 1
            (( COUNTER=COUNTER-1 ))
        else
            (( COUNTER=0 ))
        fi
	done

	/opt/novell/eDirectory/bin/ndsrepair -E | grep Server;
	echo -e "\n";
	echo "Run /opt/novell/eDirectory/bin/ndsrepair -E on the server for more info.";
	echo "These may be transitional and will clear after 1 hour";
	echo -e "\n" >> "$LOG"
else
	echo -e "\n";
	echo "Replicas are in Sync";
	echo -e "\n" >> "$LOG"
fi

# OBITUARY Check
Check=ObituaryCheck
echo $Divider;
echo -e "\n";
echo -e "\tRunning OBIT Check...";
echo -e "\n" >> "$LOG"

COUNTER=30
while [  $COUNTER -gt 1 ]; do
    RepairRunningCount=$(pgrep -c ndsrepair)
    if [ "$RepairRunningCount" == 2 ]; then
        echo "Repair is still running, will wait upto to "$COUNTER " more seconds to perform "$Check
        sleep 1
        (( COUNTER=COUNTER-1 ))
    else
        (( COUNTER=0 ))
    fi
done

edircheckobits=$(/opt/novell/eDirectory/bin/ndsrepair -C -Ad -a | grep -s "Found: 0 total obituaries in this DIB")

if [ "$edircheckobits" == "Found: 0 total obituaries in this DIB, " ]; then
	echo -e "\n";
	echo "No Obits found";
	echo -e "\n" >> "$LOG"
else
	echo "Found OBITS";
	echo -e "\n" >> "$LOG"
	
	COUNTER=30
	while [  $COUNTER -gt 1 ]; do
        RepairRunningCount=$(pgrep -c ndsrepair)
        if [ "$RepairRunningCount" == 2 ]; then
            echo "Repair is still running, will wait upto to "$COUNTER " more seconds to perform "$Check
            sleep 1
            (( COUNTER=COUNTER-1 ))
        else
            (( COUNTER=0 ))
        fi
	done

	/opt/novell/eDirectory/bin/ndsrepair -C -Ad -a |grep Found: -A3;	
	echo -e "\n";
	echo "Run /opt/novell/eDirectory/bin/ndsrepair -C -Ad -a on the server to get list of Obits. ";
    echo "These may be transitional and will clear after 1 hour";
	echo -e "\n" >> "$LOG"
fi

#Check Disk Space Method 2

if [ $DiskSpaceMethod = 2 ]; then
	echo "$Divider";
	echo -e "\n";
	echo "Checking if Free Disk Space in current eDirectory Location";
	echo "is greater than 3 x the DIB plus an extra 10G for safety...";
	echo -e "\n" >> "$LOG"

    #FreeDiskSpace=`df /var/opt/novell/eDirectory/ | grep -vE 'Filesystem|mapper' | awk '{ print $4 }'`
    #PercentDisk=`df /var/opt/novell/eDirectory/ | grep -vE 'Filesystem|mapper' | awk '{ print $5 }'`
    #FreeDiskSpace=`df /var/opt/novell/eDirectory/ | grep dev | awk '{ print $4 }'`
    #SizeOfDib=`du -c /var/opt/novell/eDirectory/data/dib/nds.* |grep total | awk '{ print $1 }'`

    #VARAVAIL=`df /var | awk 'END{ print $4 }'`
DIBDIR=$(/opt/novell/eDirectory/bin/ndsconfig get | grep dibdir | cut -f 2 -d '=')
DISKSPACEAVAIL=$(df "$DIBDIR" | awk 'END{ print $4 }')
SIZEDIBDIR=$(du -c "$DIBDIR" | awk 'END{ print $1 }')
REQUIREDSIZE=$(("$SIZEDIBDIR" + "$SIZEDIBDIR" + "$SIZEDIBDIR" + 10000000))
DIFFERENCEINSIZE=$(("$DISKSPACEAVAIL" - "$REQUIREDSIZE"))

#DibVSDisk=`expr $FreeDiskSpace / $SizeOfDib`
#DibVSDiskRatio=$(echo "scale=2; $FreeDiskSpace / $SizeOfDib" |bc)
#DibVSDisk=`expr $VARAVAIL / $SIZEDIBDIR`
#DibVSDiskRatio=$(echo "scale=2; $VARAVAIL / $SIZEDIBDIR" | bc)
#AcceptableDiskToDibRatio=3

	if [ "$DISKSPACEAVAIL" -gt "$REQUIREDSIZE" ]; then
		echo -e "\n";
		echo "eDirectory Disk Space is fine";
		echo "You have $DIFFERENCEINSIZE KB more space than is generally recommended";
		echo "General Recommendations are for approx 3 x the DIB with an additional 10G of space as a buffer";
		echo "Your DIB space usage is $SIZEDIBDIR KB with free space of $DISKSPACEAVAIL KB";
		echo -e "\n" >> "$LOG"
    else
		echo "POTENTIALLY LOW ON DISK SPACE FOR eDIRECTORY";
		echo -e "\n";
		echo "You have $DIFFERENCEINSIZE KB less than is generally recommended.";
		echo "General Recommendations are for approx 3 x the DIB with an additional 10G of space as a buffer";
		echo "Your DIB space usage is $SIZEDIBDIR KB with free space of $DISKSPACEAVAIL KB";
		echo -e "\n" >> "$LOG"
    fi
fi

# NDSD CACHE SIZE Checks
	echo "$Divider";
	echo -e "\n";
	echo -e "\tChecking the NDSD Cache size settings...";
	echo -e "\n" >> "$LOG"

NDSDCacheSize=$(grep -w cache "$DIBDIR"/_ndsdb.ini | cut -f 2 -d '=')
NDSDPreallocate=$(grep -w preallocatecache "$DIBDIR"/_ndsdb.ini | cut -f 2 -d '=')

# NDSDCacheSize=$(cat /var/opt/novell/eDirectory/data/dib/_ndsdb.ini |grep cache= |grep -v preall |awk -F= '{ print $2 }')
# NDSDPreallocate=$(cat /var/opt/novell/eDirectory/data/dib/_ndsdb.ini | grep preallocatecache |awk -F= '{ print $2 }')

DibSizeInBytes=$( "$SIZEDIBDIR" \* 1000 )
DibVSCacheSize=$(echo "scale=2; $NDSDCacheSize / $DibSizeInBytes" | bc)
MaxCacheSize=1000000000
AllowedDibSizeRatio=2

# check to see if preallocate is set
if [ "$NDSDPreallocate" == "true" ]; then
	echo -e "\n";
	echo "preallocatecache is set to True";
	echo -e "\n" >> "$LOG"
else
	echo "preallocatecache is not set to True";
	echo -e "\n";
	echo "recommendations are to preset the cache memory allocation, Check documentation for info on Dib Cache";
	echo -e "\n" >> "$LOG"	
fi

# Check NDSD Cache Size 
if [ "$NDSDCacheSize" -gt $MaxCacheSize ]; then
#If greater than 1G cache is too big
	echo -e "\n";
	echo "Potentially your CACHE size is too large";
	echo "Your DIB size = $DibSizeInBytes Bytes,";
	echo "your cache is = $NDSDCacheSize Bytes,";
	echo "The Cache is $DibVSCacheSize times the size of the DIB";
	echo "General Rule - Cache should be twice the size of the DIB up to 1G in size.";
	echo -e "\n";
	echo "For Dibs larger than 1G the recommendation is to use the OS file system caching to do most of the caching.";
	echo "General Rule - Cache should be twice the size of the DIB up to 1G in size.";
	echo -e "\n" >> "$LOG"
else
	#If less then 1G
	WorkingDibVSCacheSize=$(echo "scale=2; $DibVSCacheSize * 100" |bc |awk -F. '{ print $1 }' )
	WorkingAllowedDibSizeRatio=$( $AllowedDibSizeRatio \* 100 )

	if [ "$WorkingDibVSCacheSize" -gt "$WorkingAllowedDibSizeRatio" ]; then
		# Less than 1 G but greater than 2 times the DIB
		echo "Your Cache size may be too high";
		echo -e "\n";
		echo "Your DIB size = $DibSizeInBytes Bytes,";
		echo "your cache is = $NDSDCacheSize Bytes,";
		echo "The Cache is $DibVSCacheSize times the size of the DIB";
		echo "General Rule - Cache should be twice the size of the DIB up to 1G in size.";
		echo -e "\n" >> "$LOG"
	else
		# Less than 1G but and less than 2 x the DIB and smaller than the Dib
		if [ "$NDSDCacheSize" -lt "$DibSizeInBytes" ]; then
			echo "Your Cache size may be too small - check overall Memory usage and consider increasing it to 1G";
			echo -e "\n";
			echo "Your DIB size = $DibSizeInBytes Bytes,";
			echo "your cache is = $NDSDCacheSize Bytes,";
			echo "The Cache is $DibVSCacheSize times the size of the DIB";
			echo "General Rule - Cache should be twice the size of the DIB upto 1G in size.";
			echo -e "\n" >> "$LOG"
		else
			# Less than 1G and less than 2 x the DIB and larger than the Dib
			echo "Your Cache size maybe to small - consider increasing ot to 2 x the size of the DIB";
			echo "Your DIB size = $DibSizeInBytes Bytes,";
			echo "your cache is = $NDSDCacheSize Bytes,";
			echo "The Cache is $DibVSCacheSize times the size of the DIB";
			echo "General Rule - Cache should be twice the size of the DIB upto 1G in size.";
			echo -e "\n" >> "$LOG"
		fi
	fi
fi	

#Check for a Core File
echo $Divider;
echo -e "\n";
echo "Checking if core file exists";
echo -e "\n" >> "$LOG"

if [ -f /usr/bin/coredumpctl ]; then
	echo "SystemD Check of CORE files in Journal..." >> "$LOG"
	/usr/bin/coredumpctl list &>/dev/null
	ResultJournalCheck=$($?)

	#According to the man page a result of 0 means cores were found

    if [ "$ResultJournalCheck" = 0 ]; then
		echo "CORE FILES FOUND in Journal System";
		ListofCores=$(/usr/bin/coredumpctl --no-legend list)
		echo "List of Cores";
		echo "$ListofCores";
		echo -e "\n";
		echo "If the dates of the cores are old they should be deleted. If recent then contact support to have them analyzed";
		echo -e "\n" >> "$LOG"
    else
		echo -e "\n";
		echo "No Journal Core files Found";
		echo -e "\n" >> "$LOG"
    fi
fi

echo "-----------------";
echo "Checking NDSD Default location for Core Files..." >> "$LOG"

ls /var/opt/novell/eDirectory/data/dib/core.* > /dev/null 2>&1

Result=$($?)

if [ "$Result" = 0 ]; then
	echo "CORE FILES FOUND";
	ListofCores=$(ls -l "$DIBDIR"/core.*)
	echo "Cores";
	echo "$ListofCores";
	echo -e "\n";
	echo "If the dates of the cores are old they should be deleted. If recent then contact support to have them analyzed";
	echo -e "\n" >> "$LOG"
else
	echo -e "\n";
	echo "NO NDSD core files Found";
	echo -e "\n" >> "$LOG"
fi
	
#Check NDSD Thread Usage
echo "$Divider";
echo -e "\n";
echo "Checking NDS Threads...";
echo -e "\n" >> "$LOG"
		
TotalWorkers=$(ndstrace -c threads |grep Workers)
ConfigThreads=$(ndsconfig get |grep -i max-threads | awk -F= '{ print $2 }')
CurrentPeak=$(echo "$TotalWorkers" | awk -F, '{ print $3 }' |awk '{ print $2 }')
PercentofThreads=$(echo "$CurrentPeak / $ConfigThreads * 100" | scale=2 bc -l |awk -F. '{ print $1 }') 

echo "Server is configured for $ConfigThreads Threads......" >> "$LOG"
		
if [ "$PercentofThreads" -gt 75 ]; then
	echo -e "\tPOTENTIAL HIGH THREAD COUNT";
	echo -e "\n";
	echo "Current Threads are at: " "$TotalWorkers";
	echo "The current configured threads are: " "$ConfigThreads";
	echo -e "\n";
	echo "NDS has or had reached a peak of $PercentofThreads% of the configured threads";
	echo "Consider increasing thread count with ndsconfig set command";
	echo -e "\n" >> "$LOG"
else
	echo -e "\n";
	echo "Threads seem fine";
	echo -e "\n";
	echo "Current Threads are at $TotalWorkers"; 
	echo -e "\n";
	echo "NDS has or had reached a peak of $PercentofThreads% of the configured threads";
	echo -e "\n" >> "$LOG"
fi
	
#Check IDM version and Cache files
	echo "$Divider";
	echo -e "\n";
	echo "Checking if this is an IDM Server and Cache file sizes...";
	echo -e "\n" >> "$LOG"

	DirxmlRunning=$(ndstrace -c modules |grep Running |grep dxevent |awk '{ print $1 }')
	if [ -z "$DirxmlRunning" ]; then
		echo -e "\n";
		echo "IDM is not installed on this sesrver";
        echo -e "\n" >> "$LOG"
	else
		IDM_Version=$(rpm -qa |grep DXMLengnx |awk -F '-' '{ print $3 " " }')
        CacheFiles=$(find "$DIBDIR" -name '*.TAO' -exec ls -lh {} \; | awk '{ print $9 "/" $5 }' |  awk -F/ '{print $8 "--> " $9 " Bytes"}')
		# CacheFiles=$(ls -l "$DIBDIR"/*.TAO | awk '{ print $9 "/" $5 }' |awk -F/ '{print $8 "--> " $9 " Bytes : "}')
		echo -e "\tIDM is installed on this server";
		echo -e "\t\tVersion $IDM_Version";
		echo -e "\n";
		echo "List of Cache files and there sizes are:";
		echo "$CacheFiles";
		echo -e "\n";
		echo "72 bytes is considered an empty cache file. If cache files are large the driver may not be running";
		echo "or the Driver may be backlogged. Use iManager to check status of Drivers";
		echo -e "\n" >> "$LOG"
	fi
	
#List Cron Jobs
	echo "$Divider";
	echo -e "\n";
	echo "Getting List of Cron jobs...";
	echo -e "\n";
	crontab -l -u root;
	
echo "Whew got thru it all : Check log at $LOG"

#End of Script
echo "$Divider";
echo -e "\n";
echo -e "\tHealth Check is complete.";
echo "$Divider" >> "$LOG"

#Send the email 

if [ $SendEmail = 1 ]; then
	sendmail -vt < "$LOG"
else
	echo "Emails will not be sent" >> "$LOG"
fi

exit 0
