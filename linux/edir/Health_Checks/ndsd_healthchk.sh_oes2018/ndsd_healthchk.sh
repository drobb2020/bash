#!/bin/bash
#######################################################################################
# DSfWDude.com
# Script Name:          ndsd_healthchk.sh
# Description:          This script can be used to do a basic eDirectory health check.
#
# %Version:             2.1
# %Creating Date:       Thursday April 11 12:57:48 MDT 2013
# %Created by:          Rance Burker - Novell Technical Services
# %Modified on:         Fri Apr 26 12:12:26 MDT 2013
# %Modified by:         Rance Burker
# %Change log:          Added full path to ndsconfig and ifconfig
# %Modified on:         Mon Dec 23 14:26:09 MST 2013
# %Modified by:         Rance Burker
# %Change log:          Added ndsd backup options and script update option
# %Modified on:         Sat Mar 15 16:39:55 MDT 2014
# %Modified by:         Rance Burker
# %Change log:          Added configuration menu, restore option, and more options to enable or disable
# %Modified on:         Mon Feb 02 16:55:17 MST 2015
# %Modified by:         Rance Burker
# %Change log:          Fixed IP check between listening IP and /etc/hosts
# %Modified on:         Thu Aug 30 14:45:00 CEST 2018
# %Modified by:         Thomas M Mueller, thomas_michael.mueller@bechtle.com
# %Change log:          Fixed runing on OES2018/Sles12, no init V scripts in /etc/init.d, ntpd check
# Contact Information:  If you have any comments/requests/issues, please contact Rance Burker at rance@novell.com
#
#######################################################################################
#                 User Configuration Section
#######################################################################################
# Set CRON_SETTING=1 to run script as a cron job.  Run with cron switch to enable, but not hard set
CRON_SETTING=0

# Set AUTO_UPDATE=1 checks for newer version and updates. Set to 0 to disable or 1 to enable
AUTO_UPDATE=1

# ADD_JOB is the setting put into the crontab.  Must have $0 cron or $0 cron_all at the end. cron or cron_all are acceptable
ADD_JOB="0 05 * * * $0"

# Run dsbk every Sunday at 4:00 - Options are bk_dib, bk_nds, bk_dsbk, or bk_all
ADD_BACKUP_JOB="0 03 * * 0 $0 bk_dsbk"

# Backup dib and nici.  Set to 0 to disable or 1 to enable
# Setting to 1 will skip healthcheck and perform backups depending on settings below
BACKUP_NDSD=0

# ndsbackup user
ADMNUSER="admin.novell"

# Backup directory/var/opt/novell/eDirectory/backup # Backup directory
BACKUP_DIR_NDSD="/var/opt/novell/eDirectory/backup"

# Backup dib and nici directories along with conf files
BACKUP_NDS_DIB=0 

# Check for dib backup file when script finishes.  Set to 0 to disable or 1 to enable
CHECK_NDS_DIB=0

# Backup eDirectory using dsbk
BACKUP_NDS_DSBK=0

# Password used by dsbk to backup nici
NICIPASSWD="novell"

# Backup eDirectory using ndsbackup
BACKUP_NDS_NDSBACKUP=0

# Number of days to keep backups
BACKUP_KEPT="40"

# Set EMAIL_SETTING to 1 to send e-mail log when finished.  Set to 0 to disable or 1 to enable
EMAIL_SETTING=0

# Set EMAIL_ON_ERROR to 1 to send e-mail log if an error is returned.  Set to 0 or remove the 1 to disable
EMAIL_ON_ERROR=1

# Set CHK_DISK_SPACE to the minimume size (in Gigabytes) before a warning is listed: Default 5
CHECK_DISK_SPACE=5

# Set OBIT_CHECK to 1 to check for obits.  Set to 0 to disable or 1 to enable
OBIT_CHECK=1

# Set EXREF_CHECK to 1 to check for external references.  Set to 0 to disable or 1 to enable
EXREF_CHECK=1

# Set HOST_FILE_CHECK to 1 to check host file.  Set to 0 to disable or 1 to enable
HOST_FILE_CHECK=1

# Set REPLICA_SYNC to 1 to run replica sync check.  Set to 0 to disable or 1 to enable
REPLICA_SYNC=1

# Set NTP_CHECK to 1 to run ntp checks.  Set to 0 to disable or 1 to enable
NTP_CHECK=1

# Set TIME_SYNC to 1 to run time sync check.  Set to 0 to disable or 1 to enable
TIME_SYNC=1

# Set REPAIR_NETWORK_ADDR to 1 to run repair network addresses.  Set to 0 to disable or 1 to enable
REPAIR_NETWORK_ADDR=0

# Set SCHEMA_SYNC to 1 to check schema synchronization.  Set to 0 to disable or 1 to enable
SCHEMA_SYNC=0

# Use this in conjunction with SCHEMA_SYNC.  If schema sync fails it is possible the trace ended before schema sync was finished.
SYNC_TIME=40

# Set REPAIR_LOCAL_DB to 1 to run ndsrepair -R.  Set to 0 to disable or 1 to enable
REPAIR_LOCAL_DB=0

# Set DISPLAY_PARTITIONS to 1 to run ndsrepair -P.  Set to 0 to disable or 1 to enable
DISPLAY_PARTITIONS=1

# Set DISPLAY_UNKNOWN_OBJECTS to 1 to search for unknown objects, must have replica of root.  
DISPLAY_UNKNOWN_OBJECTS=1

# Set ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS to 1 so not prompted for user and password.  
# Only used if displayunknownobjects=1.  Set to 0 to disable or 1 to enable
ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS=1

# Enter a base context to start the search for unknown objects in a specific container.
# Example "ou=prc,o=novell", default will do root dse search
BASE=""

# $EMAIL_TO is the recipient of the e-mail.  For two or more addresses separate each address with a ,
EMAIL_TO="tmm@solingen-bechtle.de"

# Set RESET_LOG to 1 to reset the health check log.  Set to 0 to disable or 1 to enable
RESET_LOG=1

# Set LOGTOSYSLOG to 1 to send messages to /var/log/messages syslog
LOGTOSYSLOG=1

# END of User Configuration Section
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
#######################################################################################
# Display ASCII art
clear
echo ' ___   ___   __ __      __  ___            __                      '
echo '|   \ / __| / _|\ \    / / / _ \ __ __ ___/ /___    __  ___  __ __ '
echo '| |) |\__ \|  _| \ \/\/ / / // // // // _  // -_)_ / _|/ _ \|     |'
echo '|___/ |___/|_|    \_/\_/ /____/ \_,_/ \_,_/ \__/(_)\__|\___/|_|_|_|'
echo '                                                                   '
    echo -e "Run ${BOLD}$(basename $0) -l${NC} to list configuration options"
    echo -e "Run ${BOLD}$(basename $0) -h${NC} to see all script options"

# check if user is root
if [[ $EUID -ne 0 ]]; then
        echo "You must be root to run this script"
        exit 1
fi

#######################################################################################
#                                VARIABLES 
#######################################################################################
# Script Info
SCRIPT_NAME=ndsd_healthchk
SCRIPT_VERSION=2.0.6
SCRIPT_BINARY_VERSION=206

# kill script function
die(){ echo "$@" 1>&2 ; exit 999; }

# Quick sanity check
[ ! -x /sbin/ifconfig ] && die "ifconfig command not found." 
[ ! -x /usr/bin/mutt ] && EMAIL_ON_ERROR=0 && EMAIL_SETTING=0 && echo "mutt command not found." 
[ ! -x /sbin/pidof ] && echo "pidof command not found." 
[ ! -x /bin/logger ] && LOGTOSYSLOG=0 && echo "logger command not found." 
[ ! -x /usr/sbin/ntpq ] && NTP_CHECK=0 &&echo "ntpq command not found." 
[ ! -x /bin/hostname ] && echo "hostname command not found." 
[ ! -x /usr/bin/crontab ] && echo "crontab command not found." 
[ ! -x /bin/mktemp ] && echo "mktemp command not found" 
[ ! -x /usr/bin/basename ] && echo "basename command not found"

# IPADDR get ip address.  
IPADDR=$(/sbin/ifconfig | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'|head -1) #> /dev/null 2>&1

# $SERVER_NAME and $DOMAIN is a variable for populating the alert email as to the server and domain
SERVER_NAME=`/usr/bin/perl -e '$srv = \`/bin/hostname\`; print uc($srv);'`
DOMAIN=`/usr/bin/perl -e '$dom = \`/bin/dnsdomainname\`; print uc($dom);'`

# $EMAIL_SUB is is the subject of the email.
EMAIL_SUB="eDir Healthcheck for $SERVER_NAME at $DOMAIN ($IPADDR)"

# Set host, hostipaddr, and resolveipaddr 
HOST=`/bin/hostname`
HOSTS_IPADDR=$(grep -m1 $IPADDR /etc/hosts |awk '{ print $1}') #> /dev/null 2>&1
RESOLV_IPADDR=$(grep -m1 $IPADDR /etc/resolv.conf |awk '{ print $2}')

# check if DSfW is installed
XADINST=0
if [ -f /etc/init.d/xadsd ]; then XADINST=1; fi

# Check if SLES or Redhat server
if [ -f /etc/SuSE-release ]; then suse_release=$(cat /etc/SuSE-release); fi
#Sles 12 and newer 
if [ -f /etc/os-release ]; then suse_release=$(cat /etc/os-release|awk /'NAME/ {print $1,$2,$3,$5,$6,$7,$8,$9}'); fi
if [ -f /etc/redhat-release ]; then redhat_release=$(cat /etc/redhat-release); fi

# Check if OES is installed
if [ -f /etc/novell-release ]; then novell_release=$(cat /etc/novell-release); fi

# Check if eDir is installed and running, if so set variables
if [ -d /etc/opt/novell/eDirectory/conf/.edir ]; then # &&  test `pidof ndsd`; then
    #if [ `pidof ndsd|awk -F " " '{ print $1 }'` -gt "0" ]; then
    #DS_VERSION=$(/etc/init.d/ndsd status |awk /'Product/ {print $6,$7,$8}')
    DS_VERSION=$(/opt/novell/eDirectory/bin/ndsstat |awk /'Product/ {print $3,$5,$6,$7,$8}')
    DS_BINARY=$(/opt/novell/eDirectory/bin/ndsstat |awk /'Binary/ {print $3}')
    #DS_BINARY=$(/etc/init.d/ndsd status |awk /'Binary/ {print $3}')
    #DS_SERVER=$(/etc/init.d/ndsd status |awk /'Server/ {print $3}')
    DS_SERVER=$(/opt/novell/eDirectory/bin/ndsstat|awk /'Server/ {print $3}')
    CONF_DIR=$(grep -m1 ^n4u.server.configdir /etc/opt/novell/eDirectory/conf/nds.conf | awk -F"configdir=" '{print $2}'|grep -v ^$)
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        CONF_DIR=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.configdir | awk -F"configdir=" '{print $2}'|grep -v ^$);
        fi
    fi
    VAR_DIR=$(grep -m1 ^n4u.server.vardir /etc/opt/novell/eDirectory/conf/nds.conf | awk -F"vardir=" '{print $2}'|grep -v ^$)
    if [ $? -eq "1" ];then
        if test `pidof ndsd`; then
        VAR_DIR=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.vardir | awk -F"vardir=" '{print $2}'|grep -v ^$);
        fi
    fi
    LOG_DIR=$(grep -m1 ^n4u.server.log-file /etc/opt/novell/eDirectory/conf/nds.conf | awk -F"log-file=" '{print $2}' | awk -F"log" '{print $1}'|grep -v ^$)\log
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        LOG_DIR=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.log-file | awk -F"log-file=" '{print $2}' | awk -F"log" '{print $1}'|grep -v ^$)\log;
        fi
    fi
    LOG_FILE=$(grep -m1 ^n4u.server.log-file /etc/opt/novell/eDirectory/conf/nds.conf | awk -F"log" '{print $1}'|grep -v ^$)\log;
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        LOG_FILE=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.log-file | awk -F"log" '{print $1}'|grep -v ^$)\log
        fi
    fi
    DIB_DIR=$(grep -m1 ^n4u.nds.dibdir /etc/opt/novell/eDirectory/conf/nds.conf | awk -F"dibdir=" '{print $2}'|grep -v ^$);
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        DIB_DIR=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.nds.dibdir  | awk -F"dibdir=" '{print $2}'|grep -v ^$)
        fi
    fi
    NCP_INTERFACE=$(grep -m1 ^n4u.server.interfaces /etc/opt/novell/eDirectory/conf/nds.conf |awk -F"interfaces=" '{print $2}' |cut -f 1 -d @ |grep -v ^$);
    if [ $? -eq "1" ]; then
        if test `pidof ndsd`; then
        NCP_INTERFACE=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.interfaces |awk -F"interfaces=" '{print $2}' |cut -f 1 -d @ |grep -v ^$) 
        fi
    fi
fi # END Check if eDir is installed, if so set variables

# Check if eDir is running
  if [[ $1 = -l ]] || [[ $1 = --logs ]] || [[ $1 = -h ]] ||[[ $1 = --help ]] || [[ $1 = -r ]]; then
      echo > /dev/null
  elif test `pidof ndsd`; then
      echo > /dev/null
  else
      TIMELIMIT=20
     #read -t $TIMELIMIT REPLY # set timelimit on REPLY
      echo "eDirectory (ndsd) is not running"
      echo -ne "Do you want continue? (y/n): "
      read -t $TIMELIMIT REPLY # set timelimit on REPLY
      if [ -z "$REPLY" ]; then
          rcndsd restart
      else
          if [[ ! $REPLY =~ ^[Yy]$ ]]; then
              exit 1;
          else
              echo -ne "Do you want restart eDirectory? (Y/n): "
              read REPLY
              if [[ $REPLY =~ ^[Yy]$ ]]; then
                  rcndsd restart
                  echo
                  sleep 2
              fi
          fi
      fi
  fi

# END Check if eDir is running

# Check if xad is installed, export paths for secure binds
if [ -f /etc/init.d/xadsd ]; then
export _LIB=`/opt/novell/xad/share/dcinit/printConfigKey.pl "_Lib"`
export SASL_PATH=/opt/novell/xad/$_LIB/sasl2
export LDAPCONF=/etc/opt/novell/xad/openldap/ldap.conf
fi

# Update script
UPDATE_FILE="ndsd_healthchk-update.sh"
UPDATE_URL="http://dsfwdude.com/downloads/${UPDATE_FILE}"
BACKUP_FILE=$0.`date -I`.version-${SCRIPT_VERSION}.bk
THIS_FILE=$0
ARG=$1

#######################################################################################
#                                FUNCTIONS 
#######################################################################################
# e-Mail address setting displayed
emailSetting(){
    echo -e ""
    echo -e "To see script options run ${BOLD}${THIS_FILE} -h${NC}"
    echo -e "To change configuration options run${BOLD} ${THIS_FILE} -l${NC}\n"
}

# Send e-Mail function
sendEmail(){
    echo -e "Healtcheck script "$(basename $0)"\n\n""Completed healthcheck on server "$SERVER_NAME".\n $(cat $LOG)"| mutt -s "$EMAIL_SUB" "$EMAIL_TO" -a $LOG
 }  
# END-of-function send_email


# log location
setLogsToGather(){
    LOG=${LOG_DIR}/ndsd_healthchk.log
    DSREPAIR_LOG=${LOG_DIR}/ndsrepair.log
    MESSAGES_LOG=/var/log/messages
    NDSD_LOG=${LOG_DIR}/ndsd.log
    #NDSD_LOG=$(/opt/novell/eDirectory/bin/ndsconfig get n4u.server.log-file |grep -v ^$)
    LOGGER="/bin/logger -t ndsd_health_check"
}

# Logging to screen and logfile function
log(){
    setLogsToGather
    echo -e "$@"
    echo -e "$@"|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" >> $LOG
}

# ndsrepair -N Repair Network Addresses
reparinetworkaddress() {
/opt/novell/eDirectory/bin/ndsrepair -N <<ENDR
1
1
ENDR
}

# ndsrepair -P Display Partitions - if more than 5 partitions put ENTER before the q.  If more than 10 and a second ENTER.
displaypartitions() {
/opt/novell/eDirectory/bin/ndsrepair -P <<ENDR
ENDR
}

# Get IP Address
getip(){
    ifconfig | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'|head -1
}

getAdminUser(){
       # get credentials from CASA novell-lum keys
        > /var/lib/novell-lum/user.txt
        > /var/lib/novell-lum/pass.txt
        /usr/bin/lum_retrieve_proxy_cred username /var/lib/novell-lum/user.txt
        /usr/bin/lum_retrieve_proxy_cred password /var/lib/novell-lum/pass.txt
        ADMUSER=`cat /var/lib/novell-lum/user.txt`
        ADMPASSWD=`cat /var/lib/novell-lum/pass.txt`
#        /opt/novell/proxymgmt/bin/oes-enc-dec 
        rm /var/lib/novell-lum/user.txt
        rm /var/lib/novell-lum/pass.txt
}

# Credentials for admin user in LDAP syntax 
dscredentials(){
    getAdminUser
    if [[ -z $ADMUSER ]]; then
        LUM_PROXY_USERF=`grep CONFIG_LUM_PROXY_USER /etc/sysconfig/novell/lum* |cut -d '"' -f2`;
        if [[ -z $LUM_PROXY_USERF ]]; then
            if [[ -f /usr/sbin/rcmicasad ]]; then
                /usr/sbin/rcmicasad status 1>&2 > /dev/null
                if [ $? = "0" ]; then
                    CASA_RUNNING="true"
                else
                    CASA_RUNNING="false"
                fi
            fi
            if [ $CASA_RUNNING = "false" ];then
                /usr/sbin/rcmicasad start
            fi
            echo -ne "Enter user (Example cn=admin,o=novell): "
            read ADMUSER
            echo
            KEYVALUE=${ADMUSER} CASAcli -s -n novell-lum -k CN
        else
            # If CASA key is not used then prompt for user
            echo -ne "Enter user (Example cn=admin,o=novell): "
            read ADMUSER
            echo
        fi
    fi
    if [[ -z $ADMPASSWD ]]; then
        LUM_PROXY_USERF=`grep CONFIG_LUM_PROXY_USER /etc/sysconfig/novell/lum* |cut -d '"' -f2`;
        if [[ -z $LUM_PROXY_USERF ]]; then
            if [[ -f /usr/sbin/rcmicasad ]]; then
                /usr/sbin/rcmicasad status 1>&2 > /dev/null
                if [ $? = "0" ]; then
                     CASA_RUNNING="true"
                else
                     CASA_RUNNING="false"
                fi
            fi
            if [ $CASA_RUNNING = "false" ]; then
                /usr/sbin/rcmicasad start
            fi
            echo 
            echo -e The user is $ADMUSER
            echo -ne "Enter user's password: "
            read -s ADMPASSWD
            echo
            KEYVALUE=${ADMPASSWD} CASAcli -s -n novell-lum -k Password
        else
            # If CASA key is not used then prompt for user's password
            echo -e The user is $ADMUSER
            echo -ne "Enter user's password: "
            read -s ADMPASSWD
            echo
        fi
    fi

#    clear
#    echo -ne "Enter admin user  (cn=admin,o=novell): "
#    read ADMUSER
#    clear
#    echo -e The user is ${ADMUSER}
#    echo -ne "Enter user's password: "
#    read -s ADMPASSWD
#    echo
#    sleep 1
}

# add to crontab
addToCron(){
    TMP_FILE=`mktemp`
    trap 'rm $TMP_FILE; ' EXIT
    RES=0
    /usr/bin/crontab -l >> ${TMP_FILE}
    grep -s "$(basename $0) ndsd" ${TMP_FILE} >> /dev/null
    JOB_NOT_EXIST=$?
    if test ${JOB_NOT_EXIST} == 1; then
        echo "$ADD_JOB" >> ${TMP_FILE}
        /usr/bin/crontab ${TMP_FILE} >> /dev/null
        RES=$?
        echo 
        echo "${ADD_JOB} added crontab"
        echo "Run crontab -l to view"
        echo "Run crontab -e to edit"
    else
        echo "$(basename $0) is already present in crontab"
        echo "Run crontab -l to view"
        echo "Run crontab -e to edit"
        RES=$?
    fi
#    rm $TMP_FILE
    exit $RES
}

# Check diskspace warn if less than 5G
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

# add backup to crontab
addToCronBk(){
    TMP_FILE=`mktemp`
    trap 'rm $TMP_FILE; ' EXIT
    RES=0
    /usr/bin/crontab -l >> ${TMP_FILE}
    grep -s "$(basename $0) bk" $TMP_FILE >> /dev/null
    JOB_NOT_EXIST=$?
    if test $JOB_NOT_EXIST == 1; then
        echo "$ADD_BACKUP_JOB" >> $TMP_FILE
        /usr/bin/crontab $TMP_FILE >> /dev/null
        RES=$?
        echo 
        echo "$ADD_BACKUP_JOB added crontab"
        echo "Run crontab -l to view"
        echo "Run crontab -e to edit"
    else
        echo "$(basename $0) is already present in crontab"
        echo "Run crontab -l to view"
        echo "Run crontab -e to edit"
        RES=$?
    fi
    #rm $TMP_FILE
    exit $RES
}

# DIB BACKUP
dibBk(){
#   log "    ${RED}Shutting down eDirectory${NC}"
    if test `uname -p` == x86_64; then # Must be 64 bit
    ndstrace -u > /dev/null 2>&1
#   /etc/init.d/ndsd stop
    log "${yellow}eDirectory must be stopped to continue with the backup (rcndsd stop)${NC}\n"
    TIMELIMIT=180
    echo -e "You have 3 minutes to make a decision"  #yes not to continue
    echo -e "The default action is proceed with the backup\n"  #yes not to continue
    echo -ne "Do you want to stop ndsd and backup the dib? (Y/n): "  #yes not to continue
    read -t $TIMELIMIT REPLY  # set timelimit on REPLY
    echo
    if [ -z "$REPLY" ]; then   # if REPLY is null then
        log "    ${RED}Shutting down eDirectory${NC}"
        /etc/init.d/ndsd stop
    elif [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "The dib was ${RED}not${NC} backed up"
        log "To disable this option do: ${BOLD}$(basename $0) -d${NC}"
        exit 0;
    else
        log "    ${RED}Shutting down eDirectory${NC}"
        /etc/init.d/ndsd stop
    fi
    tar -czf `date -I`_dib.tgz -C /var/opt/novell/eDirectory/data dib  -C /var/opt/novell nici -C /etc/opt/novell/eDirectory/conf/ nds.conf -C /etc/opt/novell/ nici.cfg -C /etc/opt/novell/ nici64.cfg -C /etc/opt/novell/eDirectory/conf/ ndsimon.conf -C /etc/init.d/ ndsd -C /etc/opt/novell/eDirectory/conf/ ndsmodules.conf

    /etc/init.d/ndsd start
    # Make backup directory
        if [ -d $BACKUP_DIR_NDSD ]; then
            &> /dev/null
        else
            /bin/mkdir -p $BACKUP_DIR_NDSD
        fi
    # Move dib tarball to backup
    mv `date -I`_dib.tgz $BACKUP_DIR_NDSD
    fi
    echo
    echo -e "The backup is located in $BACKUP_DIR_NDSD"
    echo -e "Backups are stored for $BACKUP_KEPT"
    echo -e "These parameters can be changed in the List Script Options Menu"
    echo -e "\t $(basename $0) -l"
    echo
    echo "Backups older than $BACKUP_KEPT days will be deleted"
    echo
    log "Checking for backups older than $BACKUP_KEPT days"
        # Remove old backups
        find $BACKUP_DIR_NDSD/*_dib.tgz -mtime +$BACKUP_KEPT >> /tmp/bkdib_del
        bklist=( `cat /tmp/bkdib_del` )
        for i in "${bklist[@]}"
            do
                log "    $i"
                # Clean up
                log "Deleting backups older than $BACKUP_KEPT days"
                rm ${i}
             done
        if [ ! -s /tmp/bkdib_del ]; then echo "No backups older than $BACKUP_KEPT days found"; fi
        rm /tmp/bkdib_del
}

# pause 'Press [Enter] key to continue ...'
pause(){
    read -r -p "$*"
}

# Top of script, display server info
serverInfo(){
#    clear
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
	log "eDir Server: $DS_SERVER"
	log "eDir Version: $DS_VERSION"
	log "eDir Binary: $DS_BINARY"; fi
	log "${RED}===========================================================================${NC}"
    [ $EMAIL_SETTING -eq 1 ] && emailSetting;
    echo
}

restoredsbk(){
((C++))

#bklist=(`ls -a`)
#len=${#bklist[*]}

#i=0
#while [ $i -lt $len ]; do
#echo "$i: ${array[$i]}"
#let i++
#done

#for i in $( ls -a $BACKUP_DIR_NDSD/*_dsbk.bak ); do
#echo "$i"
#done
echo
log "Restore eDirectory backup, ie: ${BOLD}dsbk restore -f $BACKUP_DIR_NDSD/`date -I`_dsbk.bak -l $BACKUP_DIR_NDSD/`date -I`_dsbk-restore.log -e $NICIPASSWD -t -w${NC}\n"
        RES=0
#        ls -a $BACKUP_DIR_NDSD/*_dsbk.bak


    bkarray=(`ls -r $BACKUP_DIR_NDSD/*_dsbk.bak`); 
    len=${#bkarray[*]}
    b=1
    for i in ${bkarray[@]}; do
        echo -e " $b) $i" 
        ((b++))
#        echo -e " $len) $i "
#        len=$(expr $len - 1)
    done
        RES=$?
    echo #$RES
    if test $RES = 0; then
        t=0
        DSBK_RESTORE_FILE=""
        REPLY=""
        REGEX="^[0-9]{1,2}"
        #while [ -z $DSBK_RESTORE_FILE ] && [ $t -lt 3 ]; do
        while [ -z $REPLY ] && [ $t -lt 3 ]; do
            #read -ep "Please enter the dsbk restore file: " DSBK_RESTORE_FILE
            read -ep "Please select the dsbk restore file: " REPLY
            ((t++))
            if [  -z $REPLY ]; then
                echo No backup specified
                echo 
                REPLY=""
            elif [[ ! $REPLY =~ $REGEX ]];then
                echo Invalid selection
                echo A non numeric character was entered
                echo Must be a number from 1 to $len
                echo 
                REPLY=""
            elif [[ $REPLY > $len ]];then
                echo Invalid selection
                echo Must be a number from 1 to $len
                echo 
                REPLY=""
            else
                echo Selected $REPLY > /dev/null
            fi
        done
        if [  -z $REPLY ]; then
            echo Exiting, no backup specified
        else
            echo
            REPLY=$(expr $REPLY - 1) 
            DSBK_RESTORE_FILE=${bkarray[$REPLY]}
        fi
        echo -e "Selected $DSBK_RESTORE_FILE\n"
        else
            echo There are no dsbk backups in $BACKUP_DIR_NDSD
            exit $RES
        fi


    bkarray=(`ls -r $BACKUP_DIR_NDSD/*restore.log`);
    len=${#bkarray[*]}
    b=1
    RES=$?
    if test $RES = 0; then
        t=0
        DSBK_RESTORE_LOG=""
        while [ -z $DSBK_RESTORE_LOG ] && [ $t -lt 3 ]; do
       #read -ep "Please enter the dsbk restore file: " DSBK_RESTORE_LOG
       #read -ep "Please enter the dsbk restore file: " REPLY
       #REPLY=$(expr $REPLY - 1)
            if [[ `echo ${bkarray[$REPLY]}| awk -F/ '{print $NF}'| cut -d "_" -f1` == `echo $DSBK_RESTORE_FILE | awk -F/ '{print $NF}'| cut -d "_" -f1` ]]; then 
           DSBK_RESTORE_LOG=${bkarray[$REPLY]}
           ((t++))
        else
            for i in ${bkarray[@]}; do
                echo -e " $b) $i"
                ((b++))
            done
            echo
            REPLY=""
            while [ -z $REPLY ] && [ $t -lt 3 ]; do
                read -ep "Please enter the dsbk restore log: " REPLY
                ((t++))
            if [[ -z $REPLY ]]; then
                echo No backup log specified
                echo 
                REPLY=""
            elif [[ ! $REPLY =~ $REGEX ]];then
                echo Invalid selection
                echo A non numeric character was entered
                echo Must be a number from 1 to $len
                echo 
                REPLY=""
            elif [[ $REPLY > $len ]]; then
                echo Invalid selection
                echo Must be a number from 1 to $len
                echo 
                REPLY=""
            else
                echo Selected $REPLY > /dev/null
            fi
            done
            if [ -z $REPLY ];then
                echo Exiting, no backup log specified
                echo 
                exit
            else
                echo
                REPLY=$(expr $REPLY - 1)
                DSBK_RESTORE_LOG=${bkarray[$REPLY]}
                ((t++))
            fi
        fi
        done
                echo -e "Selected $DSBK_RESTORE_LOG\n"

                dsbk restore -f $DSBK_RESTORE_FILE -l $DSBK_RESTORE_LOG -e $NICIPASSWD -r -a -o -n -v -k
                sleep 10
                echo 
                echo -e "Viewing end of ndsd.log\n"
                tail $NDSD_LOG
                exit $RES
        else
                echo There are no dsbk backups in $BACKUP_DIR_NDSD
                exit $RES
        fi
}

# Set BACKUP_KEPT setting, days to keep backups
backupKept(){
    BACKUP_KEPT=""
    BACKUP_REGEX="^[0-9]{1,3}"
    while [[ ! $BACKUP_KEPT =~ $BACKUP_REGEX ]]; do
    echo -n "Enter days to keep backups (example 40): "
    read BACKUP_KEPT
    if [[ ! $BACKUP_KEPT =~ $BACKUP_REGEX ]];then
        echo 'Invalid input'
        echo 'Please enter a number'
    fi
    done
    echo " Keeping backups for ${BACKUP_KEPT} days"
    sleep .2
    sed -i "s/^BACKUP_KEPT=.*/BACKUP_KEPT=\"${BACKUP_KEPT}\"/g" ${THIS_FILE}
}

# Set EMail Recipient
changeEmailTo(){
    EMAIL_TO=""
    EMAIL_REGEX="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
    while [[ ( ! $EMAIL_TO =~ $EMAIL_REGEX ) ]]; do
    echo -n "Enter an e-mail account: "
    read EMAIL_TO
    if [[ ( ! $EMAIL_TO =~ $EMAIL_REGEX ) ]];then
        echo 'Invalid input'
        echo 'Please use e-mail format: your@mail.com'
    fi
    done
    echo " The e-mail recipient is ${EMAIL_TO}"
    sleep .2
    sed -i "s/^EMAIL_TO=.*/EMAIL_TO=\"${EMAIL_TO}\"/g" ${THIS_FILE}
}

# Set sync time in seconds, how long to run trace
changeSyncTime(){
    SYNC_TIME=""
    SYNC_REGEX="^[0-9]{1,3}"
    while [[ ! $SYNC_TIME =~ $SYNC_REGEX ]]; do
    echo -n "Enter for schema sync to run in seconds: "
    read SYNC_TIME
    if [[ ! $SYNC_TIME =~ $SYNC_REGEX ]];then
        echo 'Invalid input'
        echo 'Please enter a number'
    fi
    done
    echo " The schema sync time is ${SYNC_TIME} seconds"
    sleep .2
    sed -i "s/^SYNC_TIME=.*/SYNC_TIME="${SYNC_TIME}"/g" ${THIS_FILE}
}

# Set search base
changeBaseSearch(){
    echo -n "Enter container to start the search (Example ou=prc,o=novell): "
    read BASE
    echo " The search will start at ${BASE}"
    sleep .2
    sed -i "s/^BASE=.*/BASE=\"${BASE}\"/g" ${THIS_FILE}
}

# Set ndsbackup user
changeNdsbackupUser(){
    echo -n "Enter ndsbackup user (example admin.novell): "
    read ADMNUSER
    echo " The ndsbackup user ${ADMNUSER}"
    sleep .2
    sed -i "s/^ADMNUSER=.*/ADMNUSER=\"${ADMNUSER}\"/g" ${THIS_FILE}
}

# Change BACKUP_DIR_NDSD setting
backupDirNdsd(){
    echo -n "Enter backup directory (example /var/opt/novell/eDirectory/backup): "
    read BACKUP_DIR_NDSD
    echo " The backup directory ${BACKUP_DIR_NDSD}"
    sleep .2
    sed -i "s:^BACKUP_DIR_NDSD=.*:BACKUP_DIR_NDSD=\"${BACKUP_DIR_NDSD}\":g" ${THIS_FILE}
}

# Change cron job for ADD_BACKUP_JOB setting
addNdsdBackupJob(){
    CRON_REGEX="^[0-9*]{1,2}\ [0-9*]{1,2}\ [0-9*]{1,2}\ [0-9*]{1,2}"
    echo -e "Enter eDirectory cronjob setting"
    echo -e 'You must have $0 and an option for the script to run properly'
    echo -e "Options are bk_dib, bk_nds, bk_dsbk, or bk_all"
    echo -n 'Example 0 03 * * 0 $0 bk_dsbk: '
    read ADD_BACKUP_JOB
    echo " The cronjob setting ${ADD_BACKUP_JOB}"
    if [[ -z "${ADD_BACKUP_JOB}" ]]; then
        echo applying default setting
        ADD_BACKUP_JOB="0 03 * * 0 \$0 bk_dsbk"
    elif [[ ! $ADD_BACKUP_JOB =~ $CRON_REGEX ]]; then 
        addNdsdBackupJob
        echo invalid input
        echo 'input must conatin $0 and one of the bk options'
    fi
#    if [[ ${ADD_BACKUP_JOB} != .*'bk_dsbk' ]] || [[ ${ADD_BACKUP_JOB} != .*'bk_nds' ]] || [[ ${ADD_BACKUP_JOB} != .*'bk_nds' ]] || [[ ${ADD_BACKUP_JOB} != .*'bk_dsbk' ]] || [[ ${ADD_BACKUP_JOB} != .*'bk_all' ]]; then
#        addNdsdBackupJob
#        echo invalid input
#        echo 'input must conatin $0 and one of the bk options'
#    fi
    sleep .2
    sed -i "s:^ADD_BACKUP_JOB=.*:ADD_BACKUP_JOB=\"${ADD_BACKUP_JOB}\":g" ${THIS_FILE}
}

# Change cron job for ADD_JOB setting
addBackupJob(){
    CRON_REGEX="^[0-9*]{1,2}\ [0-9*]{1,2}\ [0-9*]{1,2}\ [0-9*]{1,2}"
    echo -e "Enter cronjob setting to run this script"
    echo -e 'You must have $0 for the script to run properly'
    echo -n 'Example 0 05 * * * $0 : '
    read ADD_JOB
    echo " The cronjob setting ${ADD_JOB}"
    if [[ -z "${ADD_JOB}" ]]; then
        echo applying default setting
        ADD_JOB="0 05 * * * \$0"
    elif [[ ! $ADD_JOB =~ $CRON_REGEX ]]; then
        echo 'invalid input: must conatin $0'
        addBackupJob
#    if ! echo "${ADD_JOB}" | grep -m1 ^ -q [0-9*]{1,2}\ [0-9*]{1,2}\ [0-9*]{1,2}\ [0-9*]{1,2}\ [0-9*]{1,2}\ ;
#    if [[ ! ${ADD_JOB} =~ $CRON_REG ]]; then
#        echo 'invalid input: must conatin cron syntax'
#        addBackupJob
    fi
    sleep .2
    sed -i "s:^ADD_JOB=.*:ADD_JOB=\"${ADD_JOB}\":g" ${THIS_FILE}
} 

# Set EMail Recipient
changeNiciPasswd(){
    echo -n "Enter container to start the search (Example novell): "
    read NICIPASSWD
    echo " The search will start at ${NICIPASSWD}"
    sleep .2
    sed -i "s/^NICIPASSWD=.*/NICIPASSWD=\"${NICIPASSWD}\"/g" ${THIS_FILE}
}

# Toggle from 1 to 0 or 0 to1
toggle(){
   if [ "${VAR1}" == "0" ]; then
        sed -i "s/^$VAR2=.*/$VAR2=1/g" ${THIS_FILE}
        ${VAR2}=1 > /dev/null 2>&1
    else
        sed -i "s/^$VAR2=.*/$VAR2=0/g" ${THIS_FILE}
        ${VAR2}=0 > /dev/null 2>&1
    fi 
}

# Status enabled is bold, else red
statusColorBoldRed(){
    if [ ${STATUS} = Enabled ]; then SCOLOR=${BOLD}; else SCOLOR=${RED}; fi
}

# Status enabled is green, else red
statusColorGreenRed(){
    if [ ${STATUS} = Enabled ]; then SCOLOR=${GREEN}; else SCOLOR=${RED}; fi
}

# listOption Menu - Configuration options
listOptions(){
    echo 
    echo -e "List Script Options"
    echo -e "Press the corresponding number to enable or disable\n"

    echo -e "Logging and e-mail options"
    if [[ ${LOGTOSYSLOG} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}1)${NC}\tLog To /var/log/messages${NC}\t${SCOLOR}${STATUS}      ${NC}\t"

    if [[ ${RESET_LOG} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}2)${NC}\tReset Health Check Log${NC}\t\t${SCOLOR}${STATUS}${NC}";

    if [[ ${EMAIL_SETTING} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}3)${NC}\te-Mail Always${NC}\t\t\t${SCOLOR}${STATUS}${NC}"
		
    if [[ ${EMAIL_ON_ERROR} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}4)${NC}\te-Mail on Error${NC}\t\t\t${SCOLOR}${STATUS} ${NC}"
		
    echo -e "   ${BOLD}5)${NC}\tSend e-Mail To${NC}\t\t\t${BOLD}${EMAIL_TO} ${NC}\n"

    echo -e "Checks and Repairs to perform"
    if [[ ${OBIT_CHECK} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}6)${NC}\tCheck for Obituaries${NC}\t\t${SCOLOR}${STATUS} ${NC}"

    if [[ ${EXREF_CHECK} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}7)${NC}\tCheck External References${NC}\t${SCOLOR}${STATUS} ${NC}"

    if [[ ${HOST_FILE_CHECK} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}8)${NC}\tCheck /etc/hosts file${NC}\t\t${SCOLOR}${STATUS} ${NC}"

    if [[ ${REPLICA_SYNC} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}9)${NC}\tCheck Replica Sync${NC}\t\t${SCOLOR}${STATUS} ${NC}"

    if [[ ${NTP_CHECK} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}10)${NC}\tCheck NTP${NC}\t\t\t${SCOLOR}${STATUS}${NC}"

    if [[ ${TIME_SYNC} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}11)${NC}\tCheck Time Synchronization${NC}\t${SCOLOR}${STATUS} ${NC}"

    if [[ ${REPAIR_NETWORK_ADDR} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}12)${NC}\tRepair Network Addresses${NC}\t${SCOLOR}${STATUS} ${NC}"

    if [ ${SCHEMA_SYNC} -eq 1 ]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}13)${NC}\tRun Schema Sync ${NC}\t\t${SCOLOR}${STATUS}${NC}"

    if [ ${REPLICA_SYNC} -eq 1 ] ||  [ ${SCHEMA_SYNC} -eq 1 ]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorBoldRed
    echo -e "   ${BOLD}14)${NC}\tLength of Time for Sync ${NC}\t  ${SCOLOR}${SYNC_TIME}${NC}"			
		
    if [ ${REPAIR_LOCAL_DB} -eq 1 ]; then STATUS=Enabled; else STATUS=Disabled; fi
	statusColorGreenRed
    echo -e "   ${BOLD}15)${NC}\tRepair Local Database${NC}\t\t${SCOLOR}${STATUS}      ${NC}\t";		
	
    if [ ${DISPLAY_PARTITIONS} -eq 1 ]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}16)${NC}\tDisplay Partitions${NC}\t\t${SCOLOR}${STATUS}      ${NC}\t";
		
    if [[ ${DISPLAY_UNKNOWN_OBJECTS} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}17)${NC}\tDisplay Unknown Ojbects${NC}\t\t${SCOLOR}${STATUS} ${NC}\t";
				
    if [[ ${ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS} -eq 1 ]] && [[ ${DISPLAY_UNKNOWN_OBJECTS} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}18)${NC}\tAnonymouse bind ${NC}\t\t${SCOLOR}${STATUS} ${NC}\t";
	
    if [ ${DISPLAY_UNKNOWN_OBJECTS} -eq 1 ]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorBoldRed
    if [ -z ${BASE} ]; then STATUS=rootdse; else STATUS=${BASE}; fi
    echo -e "   ${BOLD}19)${NC}\tStart search at ${NC}\t\t${SCOLOR}${STATUS}      ${NC}\t\n"
    echo -e "Backup options"

    if [[ ${CHECK_NDS_DIB} -eq 1 ]]; then STATUS=Enabled; else STATUS=Disabled; fi
    statusColorGreenRed
    echo -e "   ${BOLD}20)${NC}\tCheck for dib backup${NC}\t\t${SCOLOR}${STATUS} ${NC}\t";
    echo -e "   \t(when script finishes)${NC}";

    STATUS=Enabled
    statusColorBoldRed
    echo -e "   ${BOLD}21)${NC}\tThe ndsbackup user${NC}\t\t${SCOLOR}${ADMNUSER}${NC}";

    echo -e "   ${BOLD}22)${NC}\tPassword to backup NICI (dsbk)${NC}\t${SCOLOR}${NICIPASSWD}${NC}";
		
    echo -e "   ${BOLD}23)${NC}\tLocation of backup tarballs${NC}\t${SCOLOR}${BACKUP_DIR_NDSD}${NC}"; 
		
    echo -e "   ${BOLD}24)${NC}\tDays to keep backups${NC}\t\t  ${SCOLOR}${BACKUP_KEPT}${NC}\n";

    echo -e "Cron Job Settings"
    echo -e "   ${BOLD}25)${NC}\tHealth check${NC}\t\t\t${SCOLOR}${ADD_JOB}${NC}";

    echo -e "   ${BOLD}26)${NC}\tndsd backup${NC}\t\t\t${SCOLOR}${ADD_BACKUP_JOB}${NC}";
    echo
    echo -e "   ${BOLD}r${NC} to run ${BOLD}$(basename $0)${NC}"
    echo -e "   ${BOLD}h${NC} to view options running ${BOLD}$(basename $0)${NC}"
    echo -e "   ${BOLD}q${NC} or Press ${BOLD}[Enter]${NC} to Exit\n"
    echo
    echo -n "Enter an option: "

    read IN

case $IN in

        1)
            VAR1=${LOGTOSYSLOG}
            VAR2=LOGTOSYSLOG
            toggle
            ${THIS_FILE} -l
            ;;

        2)
            VAR1=${RESET_LOG}
            VAR2=RESET_LOG
            toggle
            ${THIS_FILE} -l
            ;;

        3)
            VAR1=${EMAIL_SETTING}
            VAR2=EMAIL_SETTING
            toggle
            ${THIS_FILE} -l
            ;;

        4)
            VAR1=${EMAIL_ON_ERROR}
            VAR2=EMAIL_ON_ERROR
            toggle
            ${THIS_FILE} -l
            ;;

        5)
            changeEmailTo
            ${THIS_FILE} -l
            ;;

        6)
            VAR1=${OBIT_CHECK}
            VAR2=OBIT_CHECK
            toggle
            ${THIS_FILE} -l
            ;;

        7)
            VAR1=${EXREF_CHECK}
            VAR2=EXREF_CHECK
            toggle
            ${THIS_FILE} -l
            ;;

        8)
            VAR1=${HOST_FILE_CHECK}
            VAR2=HOST_FILE_CHECK
            toggle
            ${THIS_FILE} -l
            ;;

        9)
            VAR1=${REPLICA_SYNC}
            VAR2=REPLICA_SYNC
            toggle
            ${THIS_FILE} -l
            ;;

        10)
            VAR1=${NTP_CHECK}
            VAR2=NTP_CHECK
            toggle
            ${THIS_FILE} -l
            ;;

        11)
            VAR1=${TIME_SYNC}
            VAR2=TIME_SYNC
            toggle
            ${THIS_FILE} -l
            ;;

        12)
            VAR1=${REPAIR_NETWORK_ADDR}
            VAR2=REPAIR_NETWORK_ADDR
            toggle
            ${THIS_FILE} -l
            ;;

        13)
            VAR1=${SCHEMA_SYNC}
            VAR2=SCHEMA_SYNC
            toggle
            ${THIS_FILE} -l
            ;;

        14)
            changeSyncTime
            ${THIS_FILE} -l
            ;;

        15)
            VAR1=${REPAIR_LOCAL_DB}
            VAR2=REPAIR_LOCAL_DB
            toggle
            ${THIS_FILE} -l
            ;;

        16)
            VAR1=${DISPLAY_PARTITIONS}
            VAR2=DISPLAY_PARTITIONS
            toggle
            ${THIS_FILE} -l
            ;;

        17)
            VAR1=${DISPLAY_UNKNOWN_OBJECTS}
            VAR2=DISPLAY_UNKNOWN_OBJECTS
            toggle
            ${THIS_FILE} -l
            ;;

        18)
            VAR1=${ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS}
            VAR2=ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS
            toggle
            ${THIS_FILE} -l
            ;;

        19)
            changeBaseSearch
            ${THIS_FILE} -l
            ;;

        20)
            VAR1=${CHECK_NDS_DIB}
            VAR2=CHECK_NDS_DIB
            toggle
            ${THIS_FILE} -l
            ;;


        21)
            changeNdsbackupUser
            ${THIS_FILE} -l
            ;;

        22)
            changeNiciPasswd
            ${THIS_FILE} -l
            ;;

        23)
            backupDirNdsd
            ${THIS_FILE} -l
            ;;

        24)
            backupKept
            ${THIS_FILE} -l
            ;;

        25)
            addBackupJob
            ${THIS_FILE} -l
            ;;

        26)
            addNdsdBackupJob
            ${THIS_FILE} -l
            ;;

        r|R|run|RUN)
            ${THIS_FILE}
            ;;
        h|H|--help)
            ${THIS_FILE} -h
            ;;
        *)
            exit;;
esac
}
# END listOptions

# Backup the script - part of script backup
backupScript(){
    echo "Backing up $(basename $0) to ${BACKUP_FILE}"
    cp ${THIS_FILE} ${BACKUP_FILE}
}

# get updated healtch check file - part of script backkup
getUpdate() {
 # Make backup directory
    if [ -d /tmp/download ]; then
        &> /dev/null
    else
        /bin/mkdir -p /tmp/download
    fi
 
    [ "${ARGUMENT}" = "up" ] && echo "checking for update"
    if [ ! -e $UPDATE_FILE ]; then
      [ "${ARGUMENT}" = "up" ] && echo "attempting to download update"
      wget -q $UPDATE_URL
    fi
    [ "${ARGUMENT}" = "up" ] && echo "checking again (in case download failed)"
    if [ ! -e $UPDATE_FILE ]; then
      wget $UPDATE_URL
      echo "update not found"
      cat $THIS_FILE > $UPDATE_FILE
    fi
}

# Execute updated file - part of script backup
executeUpdate() {
#  echo "executing updated file"
    chmod +x $UPDATE_FILE
    ./$UPDATE_FILE run # must invoke with --run
}

# Copy settings to updated file - part of script backup
copySettings(){
CPAUTO_UPDATE=`grep -m1 ^\AUTO_UPDATE= $THIS_FILE`
CPCRON_SETTING=`grep -m1 ^\CRON_SETTING= $THIS_FILE`
CPADD_JOB=`grep -m1 ^\ADD_JOB= $THIS_FILE`
CPADD_BACKUPJOB=`grep -m1 ^\ADD_BACKUP_JOB= $THIS_FILE`
CPBACKUP_NDSD=`grep -m1 ^\BACKUP_NDSD= $THIS_FILE`
CPADMNUSER=`grep -m1 ^\ADMNUSER= $THIS_FILE`
CPBACKUP_DIR_NDSD=`grep -m1 ^\BACKUP_DIR_NDSD= $THIS_FILE`
CPBACKUP_NDS_DIB=`grep -m1 ^\BACKUP_NDS_DIB= $THIS_FILE`
CPCHECK_NDS_DIB=`grep -m1 ^\CHECK_NDS_DIB= $THIS_FILE`
CPBACKUP_NDS_DSBK=`grep -m1 ^\BACKUP_NDS_DSBK= $THIS_FILE`
CPBACKUP_KEPT=`grep -m1 ^\BACKUP_KEPT= $THIS_FILE`
CPNICIPASSWD=`grep -m1 ^\NICIPASSWD= $THIS_FILE`
CPBACKUP_NDS_NDSBACKUP=`grep -m1 ^\BACKUP_NDS_NDSBACKUP= $THIS_FILE`
CPEMAIL_SETTING=`grep -m1 ^\EMAIL_SETTING= $THIS_FILE`
CPEMAIL_ON_ERROR=`grep -m1 ^\EMAIL_ON_ERROR= $THIS_FILE`
CPCHECK_DISK_SPACE=`grep -m1 ^\CHECK_DISK_SPACE= $THIS_FILE`
CPOBIT_CHECK=`grep -m1 ^\OBIT_CHECK= $THIS_FILE`
CPREPAIR_NETWORK_ADDR=`grep -m1 ^\REPAIR_NETWORK_ADDR= $THIS_FILE`
CPSYNC_TIME=`grep -m1 ^\SYNC_TIME= $THIS_FILE`
CPREPLICA_SYNC=`grep -m1 ^\REPLICA_SYNC= $THIS_FILE`
CPSCHEMA_SYNC=`grep -m1 ^\SCHEMA_SYNC= $THIS_FILE`
CPDISPLAY_FSMO=`grep -m1 ^\DISPLAY_FSMO= $THIS_FILE`
CPDUP_UIDNUMBER=`grep -m1 ^\DUP_UIDNUMBER= $THIS_FILE`
CPREPAIR_LOCAL_DB=`grep -m1 ^\REPAIR_LOCAL_DB= $THIS_FILE`
CPDISPLAY_PARTITIONS=`grep -m1 ^\DISPLAY_PARTITIONS= $THIS_FILE`
CPDISPLAY_UNKNOWN_OBJECTS=`grep -m1 ^\DISPLAY_UNKNOWN_OBJECTS= $THIS_FILE`
CPANONYMOUS_DISPLAY_UNKNOWN_OBJECTS=`grep -m1 ^\ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS= $THIS_FILE`
CPBASE=`grep -m1 ^\BASE= $THIS_FILE`
CPEMAIL_TO=`grep -m1 ^\EMAIL_TO= $THIS_FILE`
CPRESET_LOG=`grep -m1 ^\RESET_LOG= $THIS_FILE`
CPLOGTOSYSLOG=`grep -m1 ^\LOGTOSYSLOG= $THIS_FILE`
test $CPAUTO_UPDATE; if [[ $? == 0 ]]; then sed -i "s/^AUTO_UPDATE=./$CPAUTO_UPDATE/g" $UPDATE_FILE; fi
test $CPCRON_SETTING; if [[ $? == 0 ]]; then sed -i "s/^CRON_SETTING=./$CPCRON_SETTING/g" $UPDATE_FILE; fi
test $CPADD_JOB; if [[ $? == 0 ]]; then sed -i "s/^ADD_JOB=.*/$CPADD_JOB/g" $UPDATE_FILE; fi
test $CPADD_BACKUPJOB; if [[ $? == 0 ]]; then sed -i "s/^ADD_BACKUPJOB=.*/$CPADD_BACKUPJOB/g" $UPDATE_FILE; fi
test $CPBACKUP_NDSD; if [[ $? == 0 ]]; then sed -i "s/^BACKUP_NDSD=.*/$CPBACKUP_NDSD/g" $UPDATE_FILE; fi
test $CPADMNUSER; if [[ $? == 0 ]]; then sed -i "s/^ADMNUSER=.*/$CPADMNUSER/g" $UPDATE_FILE; fi
test $CPBACKUP_DIR_NDSD; if [[ $? == 0 ]]; then sed -i s:^$BACKUP_DIR_NDSD=.*:$CPBACKUP_DIR_NDSD:g $UPDATE_FILE; fi
test $CPBACKUP_NDS_DIB; if [[ $? == 0 ]]; then sed -i "s/^BACKUP_NDS_DIB=.*/$CPBACKUP_NDS_DIB/g" $UPDATE_FILE; fi
test $CPCHECK_NDS_DIB; if [[ $? == 0 ]]; then sed -i "s/^CHECK_NDS_DIB=.*/$CPCHECK_NDS_DIB/g" $UPDATE_FILE; fi
test $CPBACKUP_NDS_DSBK; if [[ $? == 0 ]]; then sed -i "s/^BACKUP_NDS_DSBK=.*/$CPBACKUP_NDS_DSBK/g" $UPDATE_FILE; fi
test $CPBACKUP_KEPT; if [[ $? == 0 ]]; then sed -i "s/^BACKUP_KEPT=.*/$CPBACKUP_KEPT/g" $UPDATE_FILE; fi
test $CPNICIPASSWD; if [[ $? == 0 ]]; then sed -i "s/^NICIPASSWD=.*/$CPNICIPASSWD/g" $UPDATE_FILE; fi
test $CPBACKUP_NDS_NDSBACKUP; if [[ $? == 0 ]]; then sed -i "s/^BACKUP_NDS_NDSBACKUP=.*/$CPBACKUP_NDS_NDSBACKUP/g" $UPDATE_FILE; fi
test $CPEMAIL_SETTING; if [[ $? == 0 ]]; then sed -i "s/^EMAIL_SETTING=./$CPEMAIL_SETTING/g" $UPDATE_FILE; fi
test $CPEMAIL_ON_ERROR; if [[ $? == 0 ]]; then sed -i "s/^EMAIL_ON_ERROR=./$CPEMAIL_ON_ERROR/g" $UPDATE_FILE; fi
test $CPCHECK_DISK_SPACE; if [[ $? == 0 ]]; then sed -i "s/^CHECK_DISK_SPACE=./$CPCHECK_DISK_SPACE/g" $UPDATE_FILE; fi
test $CPOBIT_CHECK; if [[ $? == 0 ]]; then sed -i "s/^OBIT_CHECK=.*/$CPOBIT_CHECK/g" $UPDATE_FILE; fi
test $CPREPAIR_NETWORK_ADDR; if [[ $? == 0 ]]; then sed -i "s/^REPAIR_NETWORK_ADDR=./$CPREPAIR_NETWORK_ADDR/g" $UPDATE_FILE; fi
test $CPSYNC_TIME; if [[ $? == 0 ]]; then sed -i "s/^SYNC_TIME=.*/$CPSYNC_TIME/g" $UPDATE_FILE; fi
test $CPREPLICA_SYNC; if [[ $? == 0 ]]; then sed -i "s/^REPLICA_SYNC=./$CPREPLICA_SYNC/g" $UPDATE_FILE; fi
test $CPSCHEMA_SYNC; if [[ $? == 0 ]]; then sed -i "s/^SCHEMA_SYNC=./$CPSCHEMA_SYNC/g" $UPDATE_FILE; fi
test $CPDISPLAY_FSMO; if [[ $? == 0 ]]; then sed -i "s/^DISPLAY_FSMO=./$CPDISPLAY_FSMO/g" $UPDATE_FILE; fi
test $CPDUP_UIDNUMBER; if [[  $? == 0 ]]; then sed -i "s/^DUP_UIDNUMBER=./$CPDUP_UIDNUMBER/g" $UPDATE_FILE; fi
test $CPREPAIR_LOCAL_DB; if [[ $? == 0 ]]; then sed -i "s/^REPAIR_LOCAL_DB=./$CPREPAIR_LOCAL_DB/g" $UPDATE_FILE; fi
test $CPDISPLAY_PARTITIONS; if [[ $? == 0 ]]; then sed -i "s/^DISPLAY_PARTITIONS=./$CPDISPLAY_PARTITIONS/g" $UPDATE_FILE; fi
test $CPDISPLAY_UNKNOWN_OBJECTS; if [[ $? == 0 ]]; then sed -i "s/^DISPLAY_UNKNOWN_OBJECTS=./$CPDISPLAY_UNKNOWN_OBJECTS/g" $UPDATE_FILE; fi
test $CPANONYMOUS_DISPLAY_UNKNOWN_OBJECTS; if [[ $? == 0 ]]; then sed -i "s/^ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS=./$CPANONYMOUS_DISPLAY_UNKNOWN_OBJECTS/g" $UPDATE_FILE; fi
test $CPBASE; if [[ $? == 0 ]]; then sed -i "s/^BASE=.*/$CPBASE/g" $UPDATE_FILE; fi
test $CPEMAIL_TO; if [[ $? == 0 ]]; then sed -i "s/^EMAIL_TO=.*/$CPEMAIL_TO/g" $UPDATE_FILE; fi
test $CPRESET_LOG; if [[ $? == 0 ]]; then sed -i "s/^RESET_LOG=./$CPRESET_LOG/g" $UPDATE_FILE; fi
test $CPLOGTOSYSLOG; if [[ $? == 0 ]]; then sed -i "s/^LOGTOSYSLOG=./$CPLOGTOSYSLOG/g" $UPDATE_FILE; fi
unset CPCRON_SETTING
unset CPADD_JOB
unset CPADD_BACKUPJOB
unset CPBACKUP_NDSD
unset CPADMNUSER
unset CPBACKUP_DIR_NDSD
unset CPBACKUP_NDS_DIB
unset CPCHECK_NDS_DIB
unset CPBACKUP_NDS_DSBK
unset CPBACKUP_KEPT
unset CPNICIPASSWD
unset CPBACKUP_NDS_NDSBACKUP
unset CPEMAIL_SETTING
unset CPEMAIL_ON_ERROR
unset CPEMAIL_ON_ERROR
unset CPCHECK_DISK_SPACE
unset CPOBIT_CHECK
unset CPREPAIR_NETWORK_ADDR
unset CPSYNC_TIME
unset CPREPLICA_SYNC
unset CPSCHEMA_SYNC
unset CPDISPLAY_FSMO
unset CPDUP_UIDNUMBER
unset CPREPAIR_LOCAL_DB
unset CPDISPLAY_PARTITIONS
unset CPDISPLAY_UNKNOWN_OBJECTS
unset CPANONYMOUS_DISPLAY_UNKNOWN_OBJECTS
unset CPBASE
unset CPEMAIL_TO
unset CPRESET_LOG
unset CPLOGTOSYSLOG
}

# Replace the original file with updated file - part of script backkup
replaceCurrentFileWithUpdate() {
  [ "${ARGUMENT}" = "up" ] && echo "overwriting current file with update file"
  chmod +x $UPDATE_FILE
  if [ "$UPDATE_FILE" != ./"$THIS_FILE" ]; then mv -f $UPDATE_FILE $THIS_FILE; fi
  echo Be sure to update the "User Configuration Section" 
  echo Run $(basename $0) -l to modify the "User Configuration Section" 
}

# Run all updates if no options - part of script backup
update() {
    # if the currently running script is not invoked with --run,
	# then it is not the updated one
    if [ -z "${ARGUMENT}" ]; then
        backupScript
        getUpdate
        copySettings
        executeUpdate
        replaceCurrentFileWithUpdate
        RES=$?
        exit $RES # must exit, or script will recursively call itself for all eternity
    fi
}

#Auto update function
autoUpdate() {
    # Check FTP connectivity
    if [ $(checkDSfWDude) -eq 0 ];then
        # Fetch and store to memory, check version
        UPDATE_VERSION=`curl -s http://dsfwdude.com/downloads/autoupdate-ndsd_healthchk.sh | grep -m1 ^SCRIPT_BINARY_VERSION= |cut -f2 -d=`
        # Compare version, download if newer version is available
        if [[ "$SCRIPT_BINARY_VERSION" -lt "$UPDATE_VERSION" ]];then
            echo -e "\nChecking for newer version ..."
            sleep 1
            echo -e "Current binary version $SCRIPT_BINARY_VERSION"
            echo -e "Updating to binary version $UPDATE_VERSION"
            backupScript
            getUpdate
            copySettings
            replaceCurrentFileWithUpdate
        fi
    fi
}

checkDSfWDude() {
    # Echo back 0 or 1 into if statement
    # To call/use: if [ $(checkDSfWDude) -eq 0 ];then
    netcat -z -w 1 dsfwdude.com 80;
    if [ $? -eq 0 ]; then
         UPDATE=YES
         echo "0"
    else #echo "Can not contact DSfWDude.com ....  update"
         UPDATE=NO
         echo "1"
    fi
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

# Check disk space
log "$C)  Checking Disk Space is greater than ${BOLD}"$CHECK_DISK_SPACE"G${NC}"
chkDiskSpace

# check that eDirectory is configured
((C++))
log "$C)  Checking for eDirectory database file and if ndsd is running-${BOLD}"`echo $DIB_DIR`/nds.db"${NC}"
    if [ -f "`echo $DIB_DIR`/nds.db" ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: ndsd is not running and/or eDirectory database is not found!!! ${NC}\n"
        RES=$?
        exit $RES 
    fi

# Check ndsd is running
((C++))
log "$C)  Checking that eDirectory (ndsd) is running - ${BOLD}rcndsd status${NC}"
    if [ `pidof ndsd|awk -F " " '{ print $1 }'` > 0 ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "eDirectory (ndsd) is not running"
        echo -ne "Do you want continue? (y/n): "
        read REPLY
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1;                       
        else
            echo -ne "Do you want restart eDirectory? (y/n): "
            read REPLY
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rcndsd restart
                echo
            fi	
        fi
    fi
# END Check ndsd is running

if [ $BACKUP_NDSD -eq 0 ]; then # if BACKUP_NDSD is 1 (enabled) then skip and just backup
 if [ $NTP_CHECK -eq 1 ]; then 
# Check ntp is running for next command
((C++))
log "$C)  Checking that ntpd is running - ${BOLD}rcntp status${NC}"
    if [ `pidof ntpd|awk -F " " '{ print $1 }'` >0 ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        echo -e "    ntpd is not running, restarting ntpd\n"
        NUMBER_WARNINGS=`expr $NUMBER_WARNINGS + 1`
        rcntpd restart >/dev/null
    fi

# Check ntp is running for next command
((C++))
log "$C)  Report ntpd peers - ${BOLD}ntpq -p${NC}"
    ntpq -p 
    ntpq -p >> $LOG
    log ""

# Check system time and hardware clock
((C++))
log "$C)  Report system clock and hardware clock are in sync ${BOLD}date = hwclock${NC}"
    if test `grep ^HWCLOCK /etc/sysconfig/clock` = 'HWCLOCK="--localtime"'; then
        if test `hwclock | awk '{print $5}' |awk -F ":" '{print $1 ":" $2}'` = `date +%H:%M`; then
            log "    ${GREEN}GOOD${NC}\n"
        elif test `hwclock | awk '{print $5}' |awk -F ":" '{print $1 ":" $2}'` = `date +%I:%M`; then
            log "    ${GREEN}GOOD${NC}\n"
        elif test `hwclock | awk '{print $4}' |awk -F ":" '{print $1 ":" $2}'` = `date +%H:%M`; then
            log "    ${GREEN}GOOD${NC}\n"
        elif test `hwclock | awk '{print $4}' |awk -F ":" '{print $1 ":" $2}'` = `date +%I:%M`; then
            log "    ${GREEN}GOOD${NC}\n"
        else
            log "    The system time is `date`"
            log "    The hwclock is `hwclock`"
            log "    Run hwclock -w to sync the hardware clock to the system time\n"

        fi
    else
        log "    The system time is `date`"
        log "    The hwclock is `hwclock`"
        log "    Run hwclock -w to sync the hardware clock to the system time\n"
    fi
 # End time section
 fi # End NTP section

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
    # Create trace file
    TMP_FILE_TRACE=`mktemp`
    trap 'rm $TMP_FILE_TRACE; ' EXIT
    ndstrace -u > /dev/null 2>&1
    ndstrace -l > $TMP_FILE_TRACE & #> /dev/null 2>&1 &
    sleep .2
    ndstrace -c "set ndstrace=nodebug;ndstrace on;ndstrace fmax=500000000" > /dev/null 2>&1 &
    sleep .2
    ndstrace -c "set ndstrace=*u;set ndstrace=*h" >/dev/null 2>&1
    sleep $SYNC_TIME
    edirreportsync=$(/opt/novell/eDirectory/bin/ndsrepair -E | grep -s "Total errors: 0")
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
    rm $TMP_FILE_TRACE
fi # END replica sync section

if [ $OBIT_CHECK -eq 1 ]; then
# check eDirectory obituaries
((C++))
log "$C)  Checking for eDirectory Obituaries using command ${BOLD}ndsrepair -C -Ad -a${NC}"
    edircheckobits=$(/opt/novell/eDirectory/bin/ndsrepair -C -Ad -a | grep -s "Found: 0 total obituaries in this DIB")
    if [ "$edircheckobits" == "Found: 0 total obituaries in this DIB, " ]; then
        log "    ${GREEN}GOOD${NC}\n"
    else
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        log "    ${RED}ERROR: Unprocessed Obits exist${NC}"
        log "    See TID 7011536 Obituary Troubleshooting"
        log "    See TID 7002659 How to progress stuck obituaries"
        log "    $(tail -n4 /var/opt/novell/eDirectory/log/ndsrepair.log)${NC}\n"
    fi
fi # END obit check

if [ $EXREF_CHECK -eq 1 ]; then
# check external references
((C++))
log "$C)  Checking for eDirectory External References using command ${BOLD}ndsrepair -C${NC}"
    sleep .5
    edircheckexref=$(/opt/novell/eDirectory/bin/ndsrepair -C | grep -s "Total errors: 0")
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

if [ $REPAIR_NETWORK_ADDR -eq 1 ]; then    # REPAIR_NETWORK_ADDR must be enabled to run this section
# check that the servers ip address is listed in the /etc/hosts.conf
((C++))
log "$C) Checking Network Addresses using command ${BOLD}ndsrepair -N${NC}"
    TMP_FILE_NETWORK=`mktemp`
    trap 'rm $TMP_FILE_NETWORK; ' EXIT
    sleep .5
    reparinetworkaddress > $TMP_FILE_NETWORK
    edirchecknaddress=$(grep -i "Total errors: 0" $TMP_FILE_NETWORK)
    if [ "$edirchecknaddress" == "" ]; then
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: Checking Network Addresses${NC}"
        log "    Check the ndsrepair -N for errors"
        log "    Look up the error(s) reported in the ndsrepair.log at http://novell.com/support"
        log "    Last Error in ndsrepair.log"
        log "    $(cat /var/opt/novell/eDirectory/log/ndsrepair.log |grep ERROR: | tail -n1)${NC}\n"
    else
        log "    ${GREEN}GOOD${NC}\n"
    fi
    rm $TMP_FILE_NETWORK
fi # END REPAIR_NETWORK_ADDR check

if [ $SCHEMA_SYNC -eq 1 ]; then  # SCHEMA_SYNC option must be enabled (set to 1) to run this sectipn
# check eDirectory time is in sync
((C++))
log "$C) Checking eDirectory Schema Synchronization using command ${BOLD}set ndstrace=*ss${NC}"
    # Create trace file
    TMP_FILE_TRACE=`mktemp`
    trap 'rm $TMP_FILE_TRACE; ' EXIT
    ndstrace -u > /dev/null 2>&1
    ndstrace -l > $TMP_FILE_TRACE & #> /dev/null 2>&1 &
    sleep .2
    ndstrace -c "set ndstrace=nodebug;ndstrace on;ndstrace fmax=500000000" > /dev/null 2>&1 &
    sleep .2
    ndstrace -c "ndstrace tags time scma scmd svty;set ndstrace=*ssa;set ndstrace=*ssd;set ndstrace=*ss;set ndstrace=*u;s
et ndstrace=*h" >/dev/null 2>&1
    sleep $SYNC_TIME
    edirschsync=$( grep -i "All processed = YES" $TMP_FILE_TRACE)
    if [ "$edirschsync" == "" ]; then
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: Schema Not in Sync ${NC}"
        log "    Run the command in a terminal"
        log "    load ndstrace, enable scma and scmd"
        log "    set ndstrace=*scma and *scmd"
        log "    Look for All processed = YES or NO"
        log "    Increase the SYNC_TIME setting in the configuration section of this script"
        log "    Check the ndstrace.log for errors\n"
        log "  *** ndstrace schema synchronization ***"
        log "$(tail -n15 $TMP_FILE_TRACE)\n"                
    else
        log "    ${GREEN}GOOD${NC}\n"
    fi
    rm $TMP_FILE_TRACE
fi
# END SCHEMA_SYNC check

# Repair local database 
if [ $REPAIR_LOCAL_DB -eq 1 ]; then
# Run Local repair
((C++))
log "$C) Run Local Database Repair using command ${BOLD}ndsrepair -R${NC}"
    localrepair=$(ndsrepair -R | grep -i "Total errors: 0")
    if [ "$localrepair" == "" ]; then
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: Local Repair errors${NC}"
        log "    Last Error in ndsrepair.log"
        log "   $(cat /var/opt/novell/eDirectory/log/ndsrepair.log |grep ERROR: | tail -n1)${NC}"
        log "    Run ndsrepair -R again"
        log "    Look up the error(s) reported in the ndsrepair.log at http://novell.com/support\n"
    else
        log "    ${GREEN}GOOD${NC}\n"
    fi
	# END Run Local repair
    sleep 1
fi 
# END Repair local database 

if [ $DISPLAY_PARTITIONS -eq 1 ]; then
# check that the servers ip address is listed in the /etc/hosts.conf
((C++))
log "$C) Reporting Partitions using command ${BOLD}ndsrepair -P${NC}"
    TMP_FILE_PART=`mktemp`
    trap 'rm $TMP_FILE_PART; ' EXIT
    displaypartitions > $TMP_FILE_PART
    sed -i '/Press ENTER/d' $TMP_FILE_PART
    sed -i '/^Enter/d' $TMP_FILE_PART
    partitionreport=$(grep -i "Total errors: 0" $TMP_FILE_PART)
    if [ "$partitionreport" == "" ]; then
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: checking partitions${NC}"
        log "    $(cat /var/opt/novell/eDirectory/log/ndsrepair.log |grep Total errors: | tail -n1)${NC}"
        log "    Check the ndsrepair -P for errors"
        log "    Look up the error(s) reported in the ndsrepair.log at http://novell.com/support\n"
    else
        log "    ${GREEN}GOOD${NC}\n"
    fi
        grep -A100 "^Total number of replicas*" $TMP_FILE_PART
        # Clean up
        rm $TMP_FILE_PART
        log
    # END Display Partitions
fi 

[[ $DISPLAY_UNKNOWN_OBJECTS -eq 1 ]] && [[ $ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS -eq 1 ]]
if [[ $DISPLAY_UNKNOWN_OBJECTS -eq 1 ]]; then
# check that the servers ip address is listed in the /etc/hosts.conf
((C++))
log "$C) Root DSE Search for ${BOLD}unknown objects${NC}"
    TMP_FILE_UNKNOWN=`mktemp`
    trap 'rm $TMP_FILE_UNKNOWN; ' EXIT
    if [ $XADINST -eq 1 ]; then
        /usr/bin/ldapsearch -Y EXTERNAL -LLL -Q -b "$DEFAULTNAMINGCONTEXT" -s sub "(&(objectclass=unknown))" dn |grep -v '^#' |sed -e :a -e '$!N;s/\n //;ta' -e 'P;D' |grep -v '^$'> $TMP_FILE_UNKNOWN 
    elif [[ $ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS -eq 1 ]] && [ $XADINST -eq 0 ]; then
        /usr/bin/ldapsearch -x -LLL -H ldaps://`getip` -b "$BASE" -s sub '(&(objectclass=unknown))' dn |sed -e :a -e '$!N;s/\n //;ta' -e 'P;D' > $TMP_FILE_UNKNOWN
    else
        #dscredentials
        #getAdminUser
        /usr/bin/ldapsearch -x -LLL -H ldaps://`getip` -D $ADMUSER -w $ADMPASSWD -b "$BASE" -s sub '(&(objectclass=unknown))' dn |sed -e :a -e '$!N;s/\n //;ta' -e 'P;D' > $TMP_FILE_UNKNOWN
    fi
    if [  -s $TMP_FILE_UNKNOWN ]; then
        NUMBER_ERRORS=`expr $NUMBER_ERRORS + 1`
        ERROR_NUMBER=("${ERROR_NUMBER[@]}" "$C")
        NDS_ERRORS=`expr $NDS_ERRORS + 1`
        log "    ${RED}ERROR: Unknown objects reported${NC}"
        log "    List of Unknown Objects${NC}"
        log "    $(cat $TMP_FILE_UNKNOWN)"
    else
        log "    ${GREEN}GOOD${NC}\n"
    fi
    # Clean up
    #rm $TMP_FILE_UNKNOWN
    log
fi # END check that the servers ip address is listed in the /etc/hosts.conf
fi # END $BACKUP_NDSD -eq 0 

# BACKUP SECTION
 if [ $BACKUP_NDSD -eq 1 ] && [ $BACKUP_NDS_NDSBACKUP -eq 1 ]; then
# Backup eDirectory ndsbackup
((C++))
log "$C)  Begin to backup eDirectory using ${BOLD}ndsbackup cvf /var/opt/novell/eDirectory/backup/`date -I`_ndsbackup.bak${NC}"
# Make backup directory
    if [ -d $BACKUP_DIR_NDSD ]; then
        &> /dev/null
    else
        /bin/mkdir -p $BACKUP_DIR_NDSD
    fi
# Run ndsbackup - first check that a passstore file has been created
    ndstrace -u > /dev/null 2>&1
    if [ -a /var/opt/novell/nici/0/edirsec.cfg ]; then
        /opt/novell/eDirectory/bin/ndsbackup cvf /var/opt/novell/eDirectory/backup/`date -I`_ndsbackup.bak -a $ADMNUSER -p passstore
    log ""
    log "To see objects in the backup do: ${BOLD}ndsbackup tf /var/opt/novell/eDirectory/backup/`date -I`_ndsbackup.bak -a $ADMNUSER -p passstore${NC}"
    log "To restore on object (cn=user1.o=novell) do: ${BOLD}ndsbackup xvf /var/opt/novell/eDirectory/backup/`date -I`_ndsbackup.bak -a $ADMNUSER -p passstore cn=user1.o=novell${NC}"
    log "To restore on a container and all object do: ${BOLD}ndsbackup xvf /var/opt/novell/eDirectory/backup/`date -I`_ndsbackup.bak -a $ADMNUSER -p passstore ou=prv.o=novell${NC}"
    log "${YELLOW}Warning:${NC} If restoring a ndsbackup and no object is specified all objects will be restored"
    log ""
        # Remove old backups
        log "Deleteting backups older than $BACKUP_KEPT days"
        find $BACKUP_DIR_NDSD/*ndsbackup.bak -mtime +$BACKUP_KEPT >> /tmp/ndsback_del
        trap 'rm /tmp/ndsback_del; ' EXIT
        bklist=( `cat /tmp/ndsback_del` )
        for i in "${bklist[@]}"
            do
                log "    $i"
                # Clean up
                rm ${i}
             done
        rm /tmp/ndsback_del
    else
        log ""
        log "The admin user's password has not been stored in ndspassstore"
        log "This is need for ndsbackup"
        log "Once the password is stored in ndspassstore this will not run again unless the users password is changed"
        log "The password will be encrypted in ndspassstore instead of stored in this script"
        log "Please enter admin user (full context) and the password at the prompt"
        log "Example admin.novell"
        log ""
        /opt/novell/eDirectory/bin/ndspassstore
        log "The password is now set in ndspassstore"
        log ""
        log "Now set the admin user in the script.  Example admin.novell" 
        log "This will allow the $(basename $0) script to run ndsbackup"
        log ""
        changeNdsbackupUser
        log "Run${BOLD} $(basename $0) bk_nds${NC} again to perform the backup"
        RES=$?
        exit $RES 
    fi
    echo
 fi
# END Backup eDirectory ndsbackup

 if [ $BACKUP_NDSD -eq 1 ] && [ $BACKUP_NDS_DSBK -eq 1 ]; then
# Backup eDirectory dsbk
# DSBK_LOG must have "date -I" and "_" because the date is used in the restore and the "_" is used as the delimiter for the restore 
DSBK_LOG=$BACKUP_DIR_NDSD/`date -I`_dsbk-restore.log
((C++))
log "$C)  Begin full backup of eDirectory using ${BOLD}dsbk backup -b -f $BACKUP_DIR_NDSD/`date -I`_dsbk.bak -l $DSBK_LOG -e $NICIPASSWD -t -w${NC}"
log "     This will do a full backup with rfl off\n"
# Make backup directory
    if [ -d $BACKUP_DIR_NDSD ]; then
        &> /dev/null
    else
        /bin/mkdir -p $BACKUP_DIR_NDSD
    fi

# Make dsbk.conf file if does not exist
    if [ -e /etc/dsbk.conf ]; then
        echo "dsbk.conf is located in /etc... "
    else
        echo "Creating dsbk.conf file..."
        touch /tmp/dsbk.tmp
        trap 'rm /tmp/dsbk.tmp; ' EXIT
        echo "/tmp/dsbk.tmp" > /etc/dsbk.conf
        # Clean up
        rm /tmp/dsbk.tmp
        /opt/novell/eDirectory/bin/dsbk setconfig -L -T #>1 /dev/null
    fi
    /opt/novell/eDirectory/bin/dsbk getconfig #>1 /dev/null
    sleep 1

    # run dsbk
    DSBK_LOG=$BACKUP_DIR_NDSD/`date -I`_dsbk-restore.log
        /opt/novell/eDirectory/bin/dsbk backup -b -f $BACKUP_DIR_NDSD/`date -I`_dsbk.bak -l $DSBK_LOG -e novell -t -w 
        sleep 3
        echo "Viewing end of ndsd.log"
        echo 
        tail 22 $NDSD_LOG
        echo

        # Remove old backups
        log "Deleting backups older than $BACKUP_KEPT days"
        find $BACKUP_DIR_NDSD/*dsbk* -mtime +$BACKUP_KEPT >> /tmp/dsbk_del
        trap 'rm /tmp/dsbk_del; ' EXIT
        bklist=( `cat /tmp/dsbk_del` )
        for i in "${bklist[@]}"
            do
                log "    $i"
                # Clean up
                rm ${i}
            done
 
     fi # END Backup eDirectory dsbk

 if [ $BACKUP_NDSD -eq 1 ] && [ $BACKUP_NDS_DIB -eq 1 ]; then
# Backup eDirectory copying dib
((C++))
log "$C)  Begin to backup eDirectory by ${BOLD}copying dib${NC}"
#   log "    ${RED}Shutting down eDirectory${NC}"
    if test `uname -p` == x86_64 && test -a /var/opt/novell/eDirectory/data/dib; then # Must be 64 bit
        ndstrace -u > /dev/null 2>&1
#       /etc/init.d/ndsd stop
        log "eDirectory must be stopped to continue (rcndsd stop)"
        TIMELIMIT=20
        echo -ne "Do you want to stop ndsd? (y/n): " #yes not to continue
        read -t $TIMELIMIT REPLY # set timelimit on REPLY
        echo
        if [ -z "$REPLY" ]; then   # if REPLY is null then
            log "    ${RED}Shutting down eDirectory${NC}"
            /etc/init.d/ndsd stop
        elif [[ ! $REPLY =~ ^[Yy]$ ]]; then
            RES=$?
            log " The dib was not backed up"
            exit $RES 
        else
            /etc/init.d/ndsd stop
        fi
        tar -czf `date -I`_dib.tgz -C /var/opt/novell/eDirectory/data dib  -C /var/opt/novell nici -C /etc/opt/novell/eDirectory/conf/ nds.conf -C /etc/opt/novell/ nici.cfg -C /etc/opt/novell/ nici64.cfg -C /etc/opt/novell/eDirectory/conf/ ndsimon.conf -C /etc/init.d/ ndsd -C /etc/opt/novell/eDirectory/conf/ ndsmodules.conf

        /etc/init.d/ndsd start
      # Make backup directory
        if [ -d $BACKUP_DIR_NDSD ]; then
            &> /dev/null
        else
            /bin/mkdir -p $BACKUP_DIR_NDSD
        fi
      # Move dib tarball to backup
        mv `date -I`_dib.tgz $BACKUP_DIR_NDSD
    else
        log
        log "${YELLOW}Did not backup dib${NC}  Must be 64 bit version of eDirectory with default dib location"
    fi
        echo
        # Remove old backups
        log "Deleting backups older than $BACKUP_KEPT days"
        find $BACKUP_DIR_NDSD/*_dib.tgz -mtime +$BACKUP_KEPT >> /tmp/bkdib_del
        trap 'rm /tmp/bkdib_del; ' EXIT
        bklist=( `cat /tmp/bkdib_del` )
        for i in "${bklist[@]}"
            do
                log "    $i"
                # Clean up
                rm ${i}
             done
        rm /tmp/bkdib_del

     fi
	 # END Backup eDirectory copying dib
if test $BACKUP_NDSD -eq 0; then ndstrace -u > /dev/null 2>&1; fi
#rm $TMP_FILE_TRACE

if test $BACKUP_NDSD -eq 0; then ndstrace -u > /dev/null 2>&1; fi
if test "${#ERROR_NUMBER[@]}" == "0"; then log "Total number of errors: ${BOLD}${#ERROR_NUMBER[@]}${NC}"; fi
if test "${#WARNING_NUMBER[@]}" != "0"; then log "Total number of warnings: ${yellow}${#WARNING_NUMBER[@]}${NC}"; fi
if test "${#WARNING_NUMBER[@]}" -gt "1"; then TASKS=tasks; else TASKS=task; fi
if test "${#WARNING_NUMBER[@]}" != "0"; then log "Warnings reported on $TASKS: ${yellow}${WARNING_NUMBER[@]}${NC}"; fi
if test "${#ERROR_NUMBER[@]}" != "0"; then log "Total number of errors: ${RED}${#ERROR_NUMBER[@]}${NC}"; fi
if test "${#ERROR_NUMBER[@]}" -gt "1"; then TASKS=tasks; else TASKS=task; fi
if test "${#ERROR_NUMBER[@]}" != "0"; then log "Errors reported on $TASKS: ${RED}${ERROR_NUMBER[@]}${NC}"; fi
if test "${#FIXED_NUMBER[@]}" != "0"; then log "Total number of errors fixed: ${GREEN}${#FIXED_NUMBER[@]}${NC}"; fi
if test "${#FIXED_NUMBER[@]}" -gt "1"; then TASKS=tasks; else TASKS=task; fi
if test "${#FIXED_NUMBER[@]}" != "0"; then log "Fixes reported on $TASKS: ${GREEN}${FIXED_NUMBER[@]}${NC}"; fi

echo Log file is: $LOG
log "End of script: $(basename $0)"
log "---------------------------------------------------------------------------"
}

# Main - The main section of the script, this is what the script will do
main(){
    if [ ${AUTO_UPDATE} -eq 1 ]; then
        autoUpdate
    fi
    setLogsToGather	
    [ $EMAIL_ON_ERROR -eq 1 ] && RESET_LOG=1
    [ $RESET_LOG -eq 1 ] && echo > $LOG
    [ $DISPLAY_UNKNOWN_OBJECTS -eq 1 ] && [ $ANONYMOUS_DISPLAY_UNKNOWN_OBJECTS -eq 0 ] #&& dscredentials
    serverInfo
    healthCheck
    #send messamge to syslog that health check completed if set to 1
#    if [ ! -a /bin/logger] 
#    fi
    [ $LOGTOSYSLOG -eq 1  ] && $LOGGER "ndsd dsfw health check complete $(basename $0)"
    #send email if set to 1
    [ $EMAIL_SETTING -eq 1 ] && sendEmail
    #send email if ERROR: is found in log and emilaonerror set to 1
    if [ -n "$(grep "ERROR: " $LOG)" ] && [ $EMAIL_SETTING -eq 0 ]; then [ $EMAIL_ON_ERROR -eq 1 ] && sendEmail; fi
    # check for dib backup
    if [ $CHECK_NDS_DIB = 1 ]; then
        find $BACKUP_DIR_NDSD/*_dib.tgz -mtime -$BACKUP_KEPT > /tmp/bkdib_list 2>/dev/null
        if [ ! -s "/tmp/bkdib_list" ]; then
            log "${yellow}WARNING NO BACKUP OF DIB FILES LOCATED"
            log "${RED}It is important to have eDirectory backups"
            log "It appears there are no backups of the dib${NC}"
            if [ $XADINST -eq 1 ]; then
                log "\n${yellow}WARNING THIS IS A DSfW SERVER"
                log "${RED}If eDirectory is removed or corrupted on a DSfW server"
                log "DSfW will have to be re-installed"
                log "If this is the only DSfW server then the domain will be lost"
                log "All workstations will have to be rejoined to the domain"
                log "All Users SIDs will be modified and passwords will have to be reset"
                log "It is EXTREMELY IMPORTANT to have DIB backups on a DSfW server${NC}"
            fi
            log "---------------------------------------------------------------------------"
            dibBk
        fi
        rm /tmp/bkdib_list
    fi

    rm 0
}

#######################################################################################
# Script Options
#while getopts "add:c:ndsd:addr:scma:repair:all:-h:h:help:--help" optname; do

    case "$1" in
        -ac|add|--add)
        addToCron
        ;;
        -ab|add_bk|--add_bk)
        addToCronBk
        ;;
        -a|-A|a|A|--all|all)
        OBIT_CHECK=1
        EXREF_CHECK=1
        HOST_FILE_CHECK=1
        REPLICA_SYNC=1
        NTP_CHECK=1
        TIME_SYNC=1
        REPAIR_NETWORK_ADDR=1
        SCHEMA_SYNC=1
        REPAIR_LOCAL_DB=1
        DISPLAY_PARTITIONS=1
        DISPLAY_UNKNOWN_OBJECTS=1
        ;;
        -na|na|cron)
        CRON_SETTING=1
        ;;
        na_all|--na_all)
        CRON_SETTING=1
        REPAIR_NETWORK_ADDR=1
        SCHEMA_SYNC=1
        DISPLAY_FSMO=1
        REPAIR_LOCAL_DB=1
        DISPLAY_PARTITIONS=1
        DISPLAY_UNKNOWN_OBJECTS=1
        ;;
        addr|--addr)
        REPAIR_NETWORK_ADDR=1
        ;;
        scma|--scma)
        SCHEMA_SYNC=1
        ;;
        repair|--repair)
        REPAIR_LOCAL_DB=1
        ;;
        -b|-B|b|B)
        backupScript
        RES=$?
        exit $RES 
        ;;
        -d|-D)
        sed -i "s/^CHECK_NDS_DIB=1/CHECK_NDS_DIB=0/g" ${THIS_FILE}
        echo -e "\nCheck for DIB backup ${RED}disabled${NC}\n"
        exit
        ;;
        -e|-E)
        sed -i "s/^CHECK_NDS_DIB=0/CHECK_NDS_DIB=1/g" ${THIS_FILE}
        echo -e "\nCheck for DIB backup ${GREEN}enabled${NC}\n"
        exit
        ;;
        -bk|bk_dib|--bk_dib)
        BACKUP_NDSD=1
        BACKUP_NDS_DIB=1
        BACKUP_NDS_DSBK=0
        BACKUP_NDS_NDSBACKUP=0
        ;;
        -bd|bk_dsbk|--bk_dsbk)
        BACKUP_NDSD=1
        BACKUP_NDS_DIB=0
        BACKUP_NDS_DSBK=1
        BACKUP_NDS_NDSBACKUP=0
        ;;
        -bn|bk_nds|--bk_nds)
        BACKUP_NDSD=1
        BACKUP_NDS_DIB=0
        BACKUP_NDS_DSBK=0
        BACKUP_NDS_NDSBACKUP=1
        ;;
        -ba|bk_all|--bk_all)
        BACKUP_NDSD=1
        BACKUP_NDS_DIB=1
        BACKUP_NDS_DSBK=1
        BACKUP_NDS_NDSBACKUP=1
        ;;
        -up|up|--update)
        backupScript
        getUpdate
        copySettings
        #executeUpdate
        replaceCurrentFileWithUpdate
        RES=$?
        exit $RES
        ;;
        -l|-L|l|L|list|--list)
        listOptions
        RES=$?
        exit $RES
        ;;
        -h|-H|h|H|--help|help)
        echo
        echo -e "Usage: $(basename $0) {list|all|add|add_bk|bk_all|bk_dib|bk_dsbk|bk_nds|up} "
        echo
        echo -e "    Healtcheck Options"
        echo -e "       -a|all    runs all options expect backup options"
        echo -e "      -l|list    list configuration options"
        echo
        echo -e "    Backup Options"
        echo -e "       bk_all    backup using all backup options"
        echo -e "       bk_dib    backup eDirectory files"
        echo -e "       bk_nds    backup eDirectory using ndsbackup"
        echo -e "      bk_dsbk    backup eDirectory using dsbk"
        echo -e "                 note: rollforward logs are disabled"
        echo
        echo -e "    Restore Options"
        echo -e "           -r    restore eDirectory using dsbk"
        echo -e "                 note: rollforward logs are disabled"
        echo
        echo -e "    Cron Job Options"
        echo -e "          add    adds ${ADD_JOB} to crontab "
        echo -e "       add_bk    adds ${ADD_BACKUP_JOB} to crontab "
        echo
        echo -e "    Update Script"
        echo -e "           up    update to the latest health check script"
        echo
        RES=$?
        exit $RES
        ;;
        -n|-N|n|N)
	addBackupJob
        listOptions
        RES=$?
        exit $RES;;
        -r|-R|r|R|restore|--restore)
        restoredsbk
        ;;
        *)
        ;;
    esac

#done
#######################################################################################
#                                MAIN 
#######################################################################################
# Main - run the main function
main
