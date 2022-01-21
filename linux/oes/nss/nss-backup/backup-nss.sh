#!/bin/bash

# backup-nss.sh
# a rsync script to backup NSS volumes to a common location

#variables
mf=rsync-backup                    # mail sender
email=root                         # mail recipient
date=$(date +"%A, %B %d - %T")     # date
src=excs-s8202.excession.org       # servername
srctech=/media/nss/TECH            # source volume 1 name
srchome=/media/nss/HOME            # source volume 2 name
# host=$(hostname)
successtechlog=/home/rsync/backup/logs/success-TECH-"$src".log
successhomelog=/home/rsync/backup/logs/success-HOME-"$src".log
errortechlog=/home/rsync/backup/logs/error-TECH-"$src".log
errorhomelog=/home/rsync/backup/logs/error-HOME-"$src".log
desttech=/media/nss/DATA/tech/
desthome=/media/nss/DATA/home/
speed=5000

# Functions
function mail_body1() { 

  echo -e "Rsync is already running, please refer to the attached running file for further information."
}

function mail_body2() {
  echo -e "Rsync backups have completed. Attached are the success and error logs for the last backup session. Please review."
}

function logheader() {
  echo "--------------------------------------------------------------------------------" >> "$1"
  echo "---------------------------------[ rsync Log ]----------------------------------" >> "$1"
  echo "$date" >> "$1"
  echo "Source Server: $src" >> "$1"
  echo "--------------------------------------------------------------------------------" >> "$1"
}

function logfooter() { 
  echo "--------------------------------------------------------------------------------" >> "$1"
  echo "----------------------------------[ rsync Log ]---------------------------------" >> "$1"
  echo "--------------------------------------------------------------------------------" >> "$1"
}

# Check to see if rsync is already running
if [ -e /home/rsync/backup/rsync.lck ]; then
  echo "Rsync job is already running....exiting"
  mail_body1 | mail -s "Rsync Logs" $mf $email -a /home/rsync/backup/logs/running.txt
  exit
fi
 
touch /home/rsync/backup/rsync.lck

# rsync --bwlimit=$speed -atvx --delete --ignore-errors --exclude-from=/root/bin/excludedFiles.txt --timeout=360 -e "sudo ssh -o StrictHostKeyChecking=no -i /home/rsync/.ssh/id_rsa" $user@$hostname:$src $dest >> $successLogs 2>> $errorLogs 

# Rsync main
logheader $successtechlog
logheader $errortechlog
/usr/bin/rsync -avzh --ignore-errors --bwlimit=$speed --del --progress --stats --exclude-from=/home/rsync/backup/excludedtechfiles.txt --timeout=360 -e "sudo /usr/bin/ssh -o StrictHostKeyChecking=no -i /home/rsync/.ssh/id_rsa" rsync@$src:$srctech $desttech >> $successtechlog 2>> $errortechlog
logfooter $successtechlog
logfooter $errortechlog

logheader $successhomelog
logheader $errorhomelog
/usr/bin/rsync -avzh --ignore-errors --bwlimit=$speed --del --progress --stats --exclude-from=/home/rsync/backup/excludedhomefiles.txt --timeout=360 -e "sudo /usr/bin/ssh -o StrictHostKeyChecking=no -i /home/rsync/.ssh/id_rsa" rsync@$src:$srchome $desthome >> $successhomelog 2>> $errorhomelog
logfooter $successhomelog
logfooter $errorhomelog

#email the logs
mail_body2 | mail -s "Rsync Logs" -a $successtechlog -a $successhomelog -a $errortechlog -a $errorhomelog $mf $email
 
#delete lock file at end of job
rm /home/rsync/backup/rsync.lck

#finished
exit 0
