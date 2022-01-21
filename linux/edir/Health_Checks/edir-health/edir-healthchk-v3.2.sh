#!/bin/bash

##############################################################################################
##  To automate user admin and password entry please create a file called userinfo.txt
##  in the same directory as this script.  If there is no file created the following ADMNUSER
##  variable will be used and you will be prompted to enter the password
##
##  Example of userinfo.txt if server has three instances of eDirectory configured
##  The file must have the typefull name of the user and then the password for that user
##  CN=admin.O=novell password
##  CN=admin2.O=novell password
##  CN=admin3.O=novell password
##
##  Script will create the directory /tmp/mf.  If it exists it will delete the
##  the contents of /tmp/mf/*.  The script also creates the directory /tmp/mf-chk.  If exists
##  the script will delete the contents of /tmp/mf-chk/*
##
##  After running the script the collected log files are located
##  /tmp/mf
##  The tar files of all the logs are located in
##  /tmp/mf-chk
##  The tar files in /tmp/mf-chk are all that is needed to be provided after running the
##  script.
##############################################################################################
##############################################################################################
# eDir user
#ADMNUSER="admin.novell"
ADMNUSER="CN=admin.O=novell"
# Set TIME_SYNC to 1 to run time sync check.  Set to 0 to disable or 1 to enable
TIME_SYNC=1
# Set HOST_FILE_CHECK to 1 to check host file.  Set to 0 to disable or 1 to enable
HOST_FILE_CHECK=1
# Set REPLICA_SYNC to 1 to run replica sync check.  Set to 0 to disable or 1 to enable
REPLICA_SYNC=1
# Set CHK_DISK_SPACE to the minimum size (in Gigabytes) before a warning is listed: Default 5
CHECK_DISK_SPACE=5
#Include Rich's file - Set to 0 to disable or 1 to enable
EDIR_FILES=1
# Set RESET_LOG to 1 to reset the health check log.  Set to 0 to disable or 1 to enable
RESET_LOG=1
# Set TIME_SYNC to 1 to run time sync check.  Set to 0 to disable or 1 to enable
#TIME_SYNC=0
# Set OBIT_CHECK to 1 to check for obits.  Set to 0 to disable or 1 to enable
OBIT_CHECK=1
# Set EXREF_CHECK to 1 to check for external references.  Set to 0 to disable or 1 to enable
EXREF_CHECK=1
# Amount of seconds used to let ndsrepair -E run
SLEEP_TIME=15
# Retrieve Server Index Definitions
INDEX_DEF=1

#######################################################################################
#Colors
RED='\e[1;31m' #Bold Red
red='\e[31m' #Bold Red
GREEN='\e[1;32m' #Bold Green
YELLOW='\e[33m' #Yellow
URED='\e[4;91m' #Underline Red
UGREEN='\e[4;92m' #Underline Green
BOLD='\e[1m'  #Bold
UBOLD=`tput bold; tput smul` #Underline Bold
#`tput sgr0`
STRIKE='\e[9m' # Strike
BLINKON='\e[5m' # Blinking
NC='\e[0m' # No Color - default

# check if user is root
if [[ $EUID -ne 0 ]]; then
        echo "You must be root to run this script"
        exit 1
fi

#######################################################################################
#                                VARIABLES
#######################################################################################
# Script Info
SCRIPT_NAME=edir-healthcheck
SCRIPT_VERSION=3.2
SCRIPT_BINARY_VERSION=320

# kill script function
die(){ echo "$@" 1>&2 ; exit 999; }

# Quick sanity check
[ ! -x /sbin/ifconfig ] && die "ifconfig command not found."
[ ! -x /sbin/pidof ] && echo "pidof command not found."
[ ! -x /bin/logger ] && LOGTOSYSLOG=0 && echo "logger command not found."
[ ! -x /bin/hostname ] && echo "hostname command not found."
[ ! -x /bin/mktemp ] && echo "mktemp command not found"
[ ! -x /usr/bin/basename ] && echo "basename command not found"

# IPADDR get ip address.
IPADDR=$(/sbin/ifconfig | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'|head -1) #> /dev/null 2>&1

# $SERVER_NAME and $DOMAIN is a variable for populating the alert email as to the server and domain
SERVER_NAME=`/usr/bin/perl -e '$srv = \`/bin/hostname\`; print uc($srv);'`
DOMAIN=`/usr/bin/perl -e '$dom = \`/bin/dnsdomainname\`; print uc($dom);'`

# Set host, hostipaddr, and resolveipaddr
HOST=`/bin/hostname`
HOSTS_IPADDR=$(grep -m1 $IPADDR /etc/hosts |awk '{ print $1}') #> /dev/null 2>&1
RESOLV_IPADDR=$(grep -m1 $IPADDR /etc/resolv.conf |awk '{ print $2}')

# Check if SLES or Redhat server
if [ -f /etc/SuSE-release ]; then suse_release=$(cat /etc/SuSE-release); fi
if [ -f /etc/redhat-release ]; then redhat_release=$(cat /etc/redhat-release); fi

# log location

createDir(){
    if [ ! -d /tmp/mf ]
     then
     /bin/mkdir -p /tmp/mf && echo "Created /tmp/mf directory for outputfiles"
     else    echo "MF directory already created for outputfiles"; rm /tmp/mf/*
    fi
    if [ ! -d /tmp/mf-chk ]
     then
     /bin/mkdir -p /tmp/mf-chk && echo "Created /tmp/mf-chk directory for tar files"
     else    echo "MF-CHK directory already created for tar files"; rm /tmp/mf-chk/*
    fi

}

osLog(){
    LOG=/tmp/mf/$HOST-OS.log
}
edirLogs(){
#    echo "inside SetLogs"
    EDIR_SERV=$(ndsconfig get --config-file ${INSTANCE_LINE} | grep n4u.nds.server-name | awk -F= '{print $2}')
    LOG=/tmp/mf/${EDIR_SERV}-edir-healthchk.log
##    DSREPAIR_LOG=${LOG_DIR}/ndsrepair.log
##    MESSAGES_LOG=/var/log/messages
##    NDSD_LOG=${LOG_DIR}/ndsd.log
##    #NDSD_LOG=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.log-file |grep -v ^$)
##    LOGGER="/bin/logger -t ndsd_health_check"
}
# Logging to screen and logfile function
log(){
#    setLogs
    echo -e "$@"
    echo -e "$@"|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" >> $LOG
}

seteDirInstanceVars(){

   if [ -f userinfo.txt ]; then
##     echo "test (awk "NR==$INSTANCE_LINE_NUM" userinfo.txt | awk '{print $1}')"
     ADMNUSER=$(awk "NR==$INSTANCE_LINE_NUM" userinfo.txt | awk '{print $1}')
     ADMNUSER_LDAP=$(awk "NR==$INSTANCE_LINE_NUM" userinfo.txt | awk '{print $1}' | tr . ,)
     ADMPASS=$(awk "NR==$INSTANCE_LINE_NUM" userinfo.txt | awk '{print $2}')
     USERINFO=1
##     echo $ADMNUSER
##     echo $ADMPASS
     else
       ADMNUSER_LDAP=$(echo $ADMNUSER | tr . ,)
       USERINFO=0
       log "${RED}${BLINKON}No USERINFO.TXT file created in script directory.  Using admin variable in script and you will be prompted for the admin password${NC}"
       sleep 2
   fi

# Check if eDir is installed and running, if so set variables
if [ -d /etc/opt/novell/eDirectory/conf/.edir ]; then # &&  test `pidof ndsd`; then
    #if [ `pidof ndsd|awk -F " " '{ print $1 }'` -gt "0" ]; then
    DS_VERSION=$(ndsstat --config-file ${INSTANCE_LINE} |awk /'Product/ {print $6,$7,$8}')
    DS_BINARY=$(ndsstat --config-file ${INSTANCE_LINE} |awk /'Binary/ {print $3}')
    DS_SERVER=$(ndsstat --config-file ${INSTANCE_LINE} |awk /'Server/ {print $3}')
    EDIR_SERV=$(ndsconfig get --config-file ${INSTANCE_LINE} | grep n4u.nds.server-name | awk -F= '{print $2}')
    IMON_IP=$(ndsconfig get --config-file ${INSTANCE_LINE} | grep https.server.interfaces | awk -F'=|@' '{print $2}')
    IMON_PORT=$(ndsconfig get --config-file ${INSTANCE_LINE} | grep https.server.interfaces | awk -F'=|@' '{print $3}')
    EDIR_SERV_CONTEXT_LDAP=$(ndsstat --config-file ${INSTANCE_LINE} | awk /'Server Name:/ {print $3}' | tr . , | sed 's/^\s*.//g' | sed 's/,T=.*$//g' | sed "s/CN=${EDIR_SERV},//g")

sleep 1
    if [ $USERINFO -eq 1 ]; then
        LDAPS_PORT=$(ldapconfig get --config-file ${INSTANCE_LINE} -a $ADMNUSER -w $ADMPASS | grep ldapInterfaces: | awk -F"ldaps://" '{print $2}' | awk -F":" '{print $2}')
    else
        log "Please enter $ADMNUSER_LDAP password for index on $EDIR_SERV collection"
        LDAPS_PORT=$(ldapconfig get --config-file ${INSTANCE_LINE} -a $ADMNUSER | grep ldapInterfaces: | awk -F"ldaps://" '{print $2}' | awk -F":" '{print $2}')
    fi
    CONF_DIR=$(grep -m1 ^n4u.server.configdir ${INSTANCE_LINE} | awk -F"configdir=" '{print $2}'|grep -v ^$)
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        CONF_DIR=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.configdir --config-file ${INSTANCE_LINE} | awk -F"configdir=" '{print $2}'|grep -v ^$);
        fi
    fi

    VAR_DIR=$(grep -m1 ^n4u.server.vardir ${INSTANCE_LINE} | awk -F"vardir=" '{print $2}'|grep -v ^$)
    if [ $? -eq "1" ];then
        if test `pidof ndsd`; then
        VAR_DIR=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.vardir --config-file ${INSTANCE_LINE} | awk -F"vardir=" '{print $2}'|grep -v ^$);
        fi
    fi
    LOG_DIR=$(grep -m1 ^n4u.server.log-file ${INSTANCE_LINE} | awk -F"log-file=" '{print $2}' | awk -F"log" '{print $1}'|grep -v ^$)\log
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        LOG_DIR=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.log-file --config-file ${INSTANCE_LINE} | awk -F"log-file=" '{print $2}' | awk -F"log" '{print $1}'|grep -v ^$)\log;
        fi
    fi
    LOG_FILE=$(grep -m1 ^n4u.server.log-file ${INSTANCE_LINE} | awk -F"log" '{print $1}'|grep -v ^$)\log;
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        LOG_FILE=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.log-file --config-file ${INSTANCE_LINE} | awk -F"log" '{print $1}'|grep -v ^$)\log
        fi
    fi
    DIB_DIR=$(grep -m1 ^n4u.nds.dibdir ${INSTANCE_LINE} | awk -F"dibdir=" '{print $2}'|grep -v ^$);
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        DIB_DIR=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.nds.dibdir --config-file ${INSTANCE_LINE} | awk -F"dibdir=" '{print $2}'|grep -v ^$)
        fi
    fi
    NCP_INTERFACE=$(grep -m1 ^n4u.server.interfaces ${INSTANCE_LINE} |awk -F"interfaces=" '{print $2}' |cut -f 1 -d @ |grep -v ^$);
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        NCP_INTERFACE=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.interfaces --config-file ${INSTANCE_LINE} |awk -F"interfaces=" '{print $2}' |cut -f 1 -d @ |grep -v ^$)
        fi
    fi
    NDSD_PID=$(cat ${VAR_DIR}/ndsd.pid)

fi # END Check if eDir is installed, if so set variables

}
chkDiskSpace(){
    df -H | grep -vE '^udev|_admin|tmpfs|pool|cdrom|Filesystem' | awk '{ print $4 "  " $1 "  " $6}' | while read op;
    do
        log "    Size Filesystem Mounted"
        log "    $op"
        ug=$(echo $op | awk '{ print $1}' | sed 's/G//g' )
        partition=$(echo $op | awk '{ print $2 }' )
        RES=`echo "$ug >= $CHECK_DISK_SPACE" | bc`
        if [[ $RES == "0" ]]; then
            WARNING_NUMBER=("${WARNING_NUMBER[@]}" "$C")
            log "    $partition is low on disk space ($ug G)\n"
        else
            log "    ${GREEN}GOOD${NC}\n"
        fi
    done
}

# Top of script, display server info
serverInfo(){
    clear
        log "\n${RED}=========================== ${NC}${BOLD}$SCRIPT_NAME $SCRIPT_VERSION${RED} ============================${NC}"
        log "Health Check on server: $(hostname)"
        log "Date: $(date) "
        log "IP Address: $IPADDR"
        log "---------------------------------------------------------------------------"
        log "Kernel Information: `uname -smr`"
        [ -f /etc/SuSE-release ] && log $suse_release
        [ -f /etc/redhat-release ] && log $redhat_release
        [ -f /etc/novell-release ] && log $novell_release
        if [ -d /etc/opt/novell/eDirectory/conf/.edir ]; then
        log "---------------------------------------------------------------------------"
        log ""; fi
        log "${RED}===========================================================================${NC}"
     echo
     echo "####################################################################################" >>$LOG
     /bin/date >>$LOG
     echo "#####  ULIMIT  #####">>$LOG
     ulimit -a >> $LOG
     echo "####################################################################################" >>$LOG
     /bin/date >>$LOG
     echo "#####  FREE MEMORY STATS  #####">>$LOG
     /usr/bin/free -m >>$LOG
     echo "####################################################################################" >>$LOG
}

tar-OS-files(){
tar -czvf /tmp/mf-chk/${HOST}-OS-data.tar.gz /tmp/mf/${HOST}* > /dev/null 2>&1
log "${RED}===========================================================================${NC}"
log " "
log "$GREEN Collected files are located in /tmp/mf-chk/${HOST}-OS-data.tar.gz $NC"
log " "
log "${RED}===========================================================================${NC}"
log " "

}

# Perform the Health Check
healthCheck(){
((C=1)) # Set Count to 1
declare -a ERROR_NUMBER
declare -a ERROR_NDS
declare -a ERROR_DNS
declare -a ERROR_XAD
declare -a ERROR_KDC
declare -a ERROR_SMB
declare -a ERROR_SYSVOL
declare -a ERROR_GPO
declare -a ERROR_DOMAINCNTRL
declare -a ERROR_MESSAGES
declare -a ERROR_PASS
declare -a WARNING_NUMBER
declare -a FIXED_NUMBER

log "\n${RED}=========================== ${NC}${BOLD}INSTANCE - $INSTANCE_LINE ${RED} ============================${NC}"
log "Health Check on server: $(hostname)"
log "eDir Server: $DS_SERVER"
log "eDir Version: $DS_VERSION"
log "eDir Binary: $DS_BINARY"
log "${RED}===========================================================================${NC}"


# Check disk space
log "$C)  Checking Disk Space is greater than ${BOLD}"$CHECK_DISK_SPACE"G${NC}"
chkDiskSpace

if [ $TIME_SYNC -eq 1 ]; then
# check eDirectory time is in sync
((C++))
log "$C)  Checking eDirectory Time Synchronization using command ${BOLD}ndsrepair -T${NC}"
    edirtimesync=$(/opt/novell/eDirectory/bin/ndsrepair -T | grep -s "Total errors: 0")
    if [ "$edirtimesync" == "" ]; then
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: Time Not in Sync ${NC}"
        log "    Check the /etc/ntp configuration"
        log "    Last Error in ndsrepair.log"
        log "    $(cat /var/opt/novell/eDirectory/log/ndsrepair.log |grep -B1 ERROR: | tail -n1)${NC}"
        log "    Check /var/log/messages for errors regarding ntpd\n"
    else
        log "    ${GREEN}GOOD${NC}\n"
    fi
fi # END time sync section

if [ $REPLICA_SYNC -eq 1 ]; then
# check eDirectory synchronization
((C++))
log "$C)  Checking eDirectory Replica Synchronization using command ${BOLD}ndsrepair -E${NC}"
    log "Sleeping for $SLEEP_TIME seconds"
    sleep $SLEEP_TIME
    edirreportsync=$(/opt/novell/eDirectory/bin/ndsrepair -E --config-file ${INSTANCE_LINE} | grep -s "Total errors: 0")
    sleep 1
    if [ "$edirreportsync" == "" ]; then
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: Replicas not synchronized${NC}"
        log "    $edirreportsync"
        log "    Look up the error(s) reported in the ndsrepair.log at http://novell.com/support\n"
    else
        log "    ${GREEN}GOOD${NC}\n"
    fi
    #rm $TMP_FILE_TRACE
fi # END replica sync section

if [ $OBIT_CHECK -eq 1 ]; then
# check eDirectory obituaries
((C++))
log "$C)  Checking for eDirectory Obituaries using command ${BOLD}ndsrepair -C -Ad -a${NC}"
    edircheckobits=$(/opt/novell/eDirectory/bin/ndsrepair --config-file ${INSTANCE_LINE} -C -Ad -a | grep -s "Found: 0 total obituaries in this DIB")
    if [ "$edircheckobits" == "Found: 0 total obituaries in this DIB, " ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        log "    ${RED}ERROR: Unprocessed Obits exist${NC}"
        log "    See TID 7011536 Obituary Troubleshooting"
        log "    See TID 7002659 How to progress stuck obituaries"
        log "    $(tail -n4 ${LOG_DIR}/ndsrepair.log)${NC}\n"
    fi
fi # END obit check

if [ $EXREF_CHECK -eq 1 ]; then
# check external references
((C++))
log "$C)  Checking for eDirectory External References using command ${BOLD}ndsrepair -C${NC}"
    sleep .5
    edircheckexref=$(/opt/novell/eDirectory/bin/ndsrepair --config-file ${INSTANCE_LINE} -C | grep -s "Total errors: 0")
    if [ "$edircheckexref" == "" ]; then
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: External Reference Check reports errors${NC}"
        log "    Look up the error(s) reported in the ndsrepair.log at http://novell.com/support"
        log "    Last Error in ndsrepair.log"
        log "    $(cat /var/opt/novell/eDirectory/log/ndsrepair.log |grep ERROR:)${NC}\n"
    else
        log "    ${GREEN}GOOD${NC}\n"
    fi
fi # END check external references

if [ $HOST_FILE_CHECK -eq 1 ]; then
# check that the nds4.server.interfaces matches that in the /etc/hosts
((C++))
log "$C)  Checking the ip address assigned to the ncpserver is correct - ${BOLD}$IPADDR${NC}"
    sleep .5
    if [ "$NCP_INTERFACE" == "$IPADDR" ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: n4u.server.interfaces does not match address ${NC}"
        #sed -i 's/$NCP_INTERFACE/$IPADDR/g' /etc/sysconfig/network/ifcfg-eth0
        #sed -i 's/$NCP_INTERFACE/$IPADDR/g' /etc/hosts
        log "    Novell Documentation http://www.novell.com/documentation/oes11/oes_implement_lx/?page=/documentation/oes11/oes_implement_lx/data/ipchange.html\n"
    fi

# check that the servers ip address is listed in the /etc/hosts.conf
((C++))
log "$C)  Checking the ip address in the /etc/hosts file is correct - ${BOLD}$IPADDR = $HOSTS_IPADDR${NC}"
    sleep .5
    if [ "$IPADDR" == "$HOSTS_IPADDR" ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: ip address in /etc/hosts is incorrect ${NC}"
        log "    Correct the ip address in the /etc/hosts file then run SuSEconfig\n"
    fi
fi # END host file check

# check that the loopback address is listed in the /etc/hosts.conf
((C++))
log "$C) Checking for the 127.0.0.1 loopback address in the /etc/hosts file - ${BOLD}grep ^127.0.0.1 /etc/hosts${NC}"
    sleep .5
    grep -s ^127.0.0.1 /etc/hosts > /dev/null 2>&1;
    if [ $? -eq "0" ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: loopback address is not listed in the /etc/hosts ${NC}"
        log "    ADD 127.0.0.1 localhost is in the /etc/hosts file then run SuSEconfig\n"
    fi

# check that the loopback address is listed in the /etc/hosts.conf
((C++))
log "$C) Checking that 127.0.0.2 loopback address is not in the /etc/hosts file - ${BOLD}grep ^127.0.0.2 /etc/hosts${NC}"
    sleep .5
    grep -s ^127.0.0.2 /etc/hosts > /dev/null 2>&1;
    if [ $? -eq "1" ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: 127.0.0.2 loopback address is listed in the /etc/hosts ${NC}"
        log "    Rem out 127.0.0.2 in the /etc/hosts file then run SuSEconfig\n"
    fi

# EDIR_FILES Section
if [ $EDIR_FILES -eq 1 ]; then
((C++))
log "${RED}===========================================================================${NC}"
log " "
log "$C) Collecting needed files${NC}"
     OF=/tmp/mf/${EDIR_SERV}-hlthdata.log
     cp ${CONF_DIR}/nds.conf /tmp/mf/${EDIR_SERV}-nds.conf
     cp ${DIB_DIR}/_ndsdb.ini /tmp/mf/${EDIR_SERV}-_ndsdb.ini
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     echo "#####  TOP STATS FOR NDSD  #####">>$OF
     /usr/bin/top -b -n1 -p $(pgrep -d',' ndsd) >>$OF
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     echo "#####  PID for INSTANCE ${INSTANCE_LINE} is $NDSD_PID  #####" >>$OF
     echo " " >>$OF
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     echo "#####  ndsconfig get  #####">>$OF
     ndsconfig get --config-file ${INSTANCE_LINE} >>$OF
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     echo "#####  ndsrepair -E  #####">>$OF
     ndsrepair -E --config-file ${INSTANCE_LINE} >>$OF
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     echo "#####  ndsrepair -c threads  #####">>$OF
     ndstrace --config-file ${INSTANCE_LINE} -c threads >>$OF
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     echo "#####  ndsrepair -T  #####">>$OF
     ndsrepair -T --config-file ${INSTANCE_LINE} >>$OF
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     echo "#####  ENVIRON file for Instance ${INSTANCE_LINE}  #####">>$OF
     strings /proc/${NDSD_PID}/environ >>$OF
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     echo "#####  LIMITS file for Instance ${INSTANCE_LINE}  #####">>$OF
     strings /proc/${NDSD_PID}/limits >>$OF
     echo "####################################################################################" >>$OF
     /bin/date >>$OF
     ndscheck -D -q -F /tmp/mf/${EDIR_SERV}-dibdata.log --config-file ${INSTANCE_LINE} 2>/dev/null
     if [ $USERINFO -eq 1 ]; then
       echo "user: ${ADMNUSER}"
       ndscheck -a ${ADMNUSER} -w ${ADMPASS} -q -F /tmp/mf/${EDIR_SERV}-ndscheck.log --config-file ${INSTANCE_LINE} 2>/dev/null 
       echo "#####  ldapconfig get  #####">>$OF
       ldapconfig get --config-file /etc/opt/novell/eDirectory/conf/nds.conf -a ${ADMNUSER} -w ${ADMPASS} >>$OF
       echo "####################################################################################" >>$OF
     else
       ndscheck -a ${ADMNUSER} -q -F /tmp/mf/${EDIR_SERV}-ndscheck.log --config-file ${INSTANCE_LINE} 2>/dev/null
       echo "#####  ldapconfig get  #####">>$OF
       ldapconfig get --config-file /etc/opt/novell/eDirectory/conf/nds.conf -a ${ADMNUSER} >>$OF
       echo "####################################################################################" >>$OF
     fi
#     echo "#####eDir Transaction ID Percentage#####">>$OF
# Charter only     /home/techops/bin/edir_headroom >>$OF
     log "${RED}===========================================================================${NC}"
     log " "
#     log "Please enter password for imon data collection"
     if [ $USERINFO -eq 1 ]; then
       /usr/bin/curl -s -k -u ${ADMNUSER}:${ADMPASS} https://${IMON_IP}:${IMON_PORT}/nds/agent/data?config=SyncCtl > /tmp/mf/${EDIR_SERV}-imon-sync.htm

       /usr/bin/curl -s -k -u ${ADMNUSER}:${ADMPASS} https://${IMON_IP}:${IMON_PORT}/nds/agent/data?config=BackCtl > /tmp/mf/${EDIR_SERV}-imon-backg.htm

       /usr/bin/curl -s -k -u ${ADMNUSER}:${ADMPASS} https://${IMON_IP}:${IMON_PORT}/nds/agent/data?config=CacheCtl > /tmp/mf/${EDIR_SERV}-imon-cache.htm
     else
       log "Please enter password for imon data collection"
       /usr/bin/curl -s -k -u ${ADMNUSER} https://${IMON_IP}:${IMON_PORT}/nds/agent/data?config=SyncCtl > /tmp/mf/${EDIR_SERV}-imon-sync.htm

       /usr/bin/curl -s -k -u ${ADMNUSER} https://${IMON_IP}:${IMON_PORT}/nds/agent/data?config=BackCtl > /tmp/mf/${EDIR_SERV}-imon-backg.htm

       /usr/bin/curl -s -k -u ${ADMNUSER} https://${IMON_IP}:${IMON_PORT}/nds/agent/data?config=CacheCtl > /tmp/mf/${EDIR_SERV}-imon-cache.htm
     fi
# charter only     /home/techops/bin/edir_headroom >>$OF
     ndsstat -s --config-file ${INSTANCE_LINE} > /tmp/mf/${EDIR_SERV}-ndsstat-s.txt
     ndsstat -r --config-file ${INSTANCE_LINE} > /tmp/mf/${EDIR_SERV}-ndsstat-r.txt

     if [ $INDEX_DEF -eq 1 ]; then
       echo "user: ${ADMNUSER}"
       if [ $USERINFO -eq 1 ]; then
         echo "" | openssl s_client -showcerts -connect ${IMON_IP}:${LDAPS_PORT} 2> /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > cert.pem
         LDAPTLS_CACERT=cert.pem /opt/novell/eDirectory/bin/ldapsearch -H ldaps://$IMON_IP:$LDAPS_PORT -D $ADMNUSER_LDAP -w $ADMPASS -b $EDIR_SERV_CONTEXT_LDAP cn=$EDIR_SERV DN indexDefinition >>$OF
       else
         log "Please enter $ADMNUSER_LDAP password for index on $EDIR_SERV collection"
         echo "" | openssl s_client -showcerts -connect ${IMON_IP}:${LDAPS_PORT} 2> /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > cert.pem
         LDAPTLS_CACERT=cert.pem /opt/novell/eDirectory/bin/ldapsearch -H ldaps://$IMON_IP:$LDAPS_PORT -D $ADMNUSER_LDAP -W -b $EDIR_SERV_CONTEXT_LDAP cn=$EDIR_SERV DN indexDefinition >>$OF
       fi
#sleep 60
     fi
      echo "####################################################################################" >>$OF

    sleep 1
fi
# END EDIR_FILES

if test "${#ERROR_NUMBER[@]}" == "0"; then log "Total number of errors: ${BOLD}${#ERROR_NUMBER[@]}${NC}"; fi
if test "${#WARNING_NUMBER[@]}" != "0"; then log "Total number of warnings: ${yellow}${#WARNING_NUMBER[@]}${NC}"; fi
if test "${#WARNING_NUMBER[@]}" -gt "1"; then TASKS=tasks; else TASKS=task; fi
if test "${#WARNING_NUMBER[@]}" != "0"; then log "Warnings reported on $TASKS: ${yellow}${WARNING_NUMBER[@]}${NC}"; fi
if test "${#ERROR_NUMBER[@]}" -gt "1"; then TASKS=tasks; else TASKS=task; fi
if test "${#ERROR_NUMBER[@]}" != "0"; then log "Errors reported on $TASKS: ${RED}${ERROR_NUMBER[@]}${NC}"; fi
if test "${#FIXED_NUMBER[@]}" != "0"; then log "Total number of errors fixed: ${GREEN}${#FIXED_NUMBER[@]}${NC}"; fi
if test "${#FIXED_NUMBER[@]}" -gt "1"; then TASKS=tasks; else TASKS=task; fi
if test "${#FIXED_NUMBER[@]}" != "0"; then log "Fixes reported on $TASKS: ${GREEN}${FIXED_NUMBER[@]}${NC}"; fi

echo Log file is: $LOG
}
#mv $LOG /tmp/novell/${EDIR_SERV}_healthchk.log
tar-edir-files(){
tar -czvf /tmp/mf-chk/${EDIR_SERV}-EDIR-data.tar.gz /tmp/mf/${EDIR_SERV}* > /dev/null 2>&1
log "${RED}===========================================================================${NC}"
log " "
log "${GREEN} Collected files are located in /tmp/mf-chk/${EDIR_SERV}-EDIR-data.tar.gz ${NC}"
log " "
log "${RED}===========================================================================${NC}"
log " "

}

while (true)
do
    createDir
    INSTANCE_COUNT=`cat /etc/opt/novell/eDirectory/conf/.edir/instances.0 | wc -l`
    filename=/etc/opt/novell/eDirectory/conf/.edir/instances.0
    INSTANCE_LINE_NUM=1
#    echo "INSTANCE_COUNT=${INSTANCE_COUNT}"
    INSTANCE_COUNTER=0
    osLog
    serverInfo
    tar-OS-files
    while [ $INSTANCE_COUNTER -lt $INSTANCE_COUNT ]
    do
        while read INSTANCE_LINE; do
#        echo "Line $INSTANCE_LINE"
        INSTANCE_COUNTER=`expr $INSTANCE_COUNTER + 1`
#        echo "INSTANCE_COUNT=$INSTANCE_COUNT"
#        echo "INSTANCE_COUNTER=$INSTANCE_COUNTER"
        edirLogs
        EDIR_STATE=$(ndsstat --config-file ${INSTANCE_LINE} 2>&1 | awk '{print $1}')
        if [ "$EDIR_STATE" == "Failed" ]; then
          log "${RED}===========================================================================${NC}"
          log " "
          log "${RED} skipping $INSTANCE_LINE since it is not running ${NC}"
          log " "
          log "${RED}===========================================================================${NC}"
#          echo "$RED skipping $INSTANCE_LINE since it is not running $NC"
          tar-edir-files
          continue 
        fi
        seteDirInstanceVars
        healthCheck
        tar-edir-files
        INSTANCE_LINE_NUM=$((INSTANCE_LINE_NUM+1))
        done < $filename
    done
    echo -e "${GREEN}===========================================================================${NC}"
    echo " "
    echo -e "${GREEN}${BLINKON} Collection completed!!! "
    echo -e "${GREEN} Please provide all tar files located in /tmp/mf-chk/ ${NC}"
    echo " "
    ls -al /tmp/mf-chk/* 
    echo " "
    echo -e "${GREEN}===========================================================================${NC}"

    exit

done
