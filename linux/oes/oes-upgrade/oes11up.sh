#!/bin/bash
REL=0.1.1

# Script to upgrade an OES11 SP1 server to OES11 SP2

TS=$(date +'%b %d %T')
HOST=$(hostname)
USER=$(whoami)
LOG=/var/log/upgrade.log
EMAIL=root
ZBIN=/usr/bin/

function initlog() { 
  if [ -e /var/log/upgrade.log ]; then
    echo "Log file exists." > /dev/null
  else
    touch /var/log/upgrade.log
    echo "Logging started at ${TS}" > ${LOG}
    echo "All actions are being performed by the user: ${USER}" >> ${LOG}
    echo " " >> ${LOG}
  fi
}

function logit() { 
  echo -e $TS $HOST: $* >> ${LOG}
}

initlog

# ID Check - you must be root to run an upgrade
function idme() { 
  if [ $USER != "root" ]; then
    echo "You must be root to upgrade this server."
    echo "The script will exit now. Please become"
    echo "root user and try again."
    sleep 2
    exit 1
  fi
}

idme

function mod_php53() { 
  echo "Please follow the on screen prompts to install apache2-mod_php53"
  sleep 2
  $ZBIN/zypper in apache2-mod_php53
  echo "apache2-mod_php53 successfully installed."
}

function diskspace() { 
 #get code from new dynmotd script!!! 
}

function zypper_ca() { 
  echo "Please verify that the correct SLES11 SP2, SLE11 SDK SP2, and OES11 SP1 repositories are present."
  sleep 2
  $ZBIN/zypper ca
  echo "Add any missing or needed repositories using the zypper ar command."
}

function zypper_pa() { 
  echo "The server should be fully patched prior to upgrading, going to do this now!"
  echo "Please follow any on screen prompts to install new patches."
  sleep 2
  $ZBIN/zypper update -t patch
  echo "If there were any patches applied please check if any services need to be"
  echo "restarted by using the zypper ps command, or reboot the server if this is."
  echo "indicated."
}

function zypper_pd() { 
  echo "Check the following output to ensure the migration scripts for SLES, SLE SDK,"
  echo "and OES are present but not yet installed."
  sleep 2
  $ZBIN/zypper pd
  echo "You should see the migration scripts for SLES11 SP3, and OES11 SP2. If the"
  echo "Software Development Kit is installed you will also see a migration script"
  echo "for SLE11-SDK-SP3."
}

function zypper_in() { 
  echo "Please confirm if the SLE11-SDK-SP2 is installed on this server."
  read -p "SLE11-SDK-SP2 is present: " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      $ZBIN/zypper in -t product Open_Enterprise_Server-SP2-migration SUSE_SLES-SP3-migration sle-sdk-SP3-migration
    else
      $ZBIN/zypper in -t product Open_Enterprise_Server-SP2-migration SUSE_SLES-SP3-migration
  fi
}

function zypper_ar() { 
  read "Do you have access to a proper SMT server or nu.novell.com? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      suse_register
      echo "The necessary repositories have been added to the server."
    else
      echo "Add the repositories for SLES11-SP3, SLE-SDK-SP3, and OES11-SP2."
      sleep 2
      $ZBIN/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/OES11-SP2-Pool/sle-11-x86_64 CAS-DEV-OES11-SP2-Pool
      $ZBIN/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/OES11-SP2-Updates/sle-11-x86_64 CAS-DEV-OES11-SP2-Updates
      $ZBIN/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLES11-SP3-Pool/sle-11-x86_64 CAS-DEV-SLES11-SP#-Pool
      $ZBIN/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLES11-SP3-Updates/sle-11-x86_64 CAS-DEV-SLES11-SP3-Updates
      $ZBIN/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLE11-SDK-SP3-Pool/sle-11-x86_64 CAS-DEV-SLE11-SDK-SP3-Pool
      $ZBIN/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLE11-SDK-SP3-Updates/sle-11-x86_64 CAS-DEV-SLE11-SDK-SP3-Updates
 fi
}

function zypper_ref() { 
  echo "New repositories added, let's refresh the service."
  sleep 2
  $ZBIN/zypper ref -s 
  echo "The repo metadata and cache have been refreshed for all configured repositories."
}

function zypper_dup() {
  read "Going to begin the upgrade process. Are you sure you want to continue? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      read "Is the SDK going to be upgraded as well? " -n 1 -r
      if [[ $REPLY =~ ^[Yy]$ ]]
        then
          $ZBIN/zypper dup --from SLES11-SP3-Pool --from SLES11-SP3-Updates --from OES11-SP2-Pool --from OES11-SP2-Updates --from SLE11-SDK-SP3-Pool --from SLE11-SDK-SP3-Updates
        else
          $ZBIN/zypper dup --from SLES11-SP3-Pool --from SLES11-SP3-Updates --from OES11-SP2-Pool --from OES11-SP2-Updates
      fi
    else
      echo "Rerun the script when you are ready."
      exit 1
  fi
}

function reboot_now() { 
  echo "The server has just been upgrade, it needs an immediate reboot."
  /sbin/shutdown -r now
}

function admacct() { 
  echo "This is the configured admin account for OES configuration."
  cat /etc/sysconfig/novell/oes/ldap | grep CONFIG_LDAP_ADMIN_CONTEXT | cut -f2- -d"="
  read "Do you know the password for this account? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      
    else
      echo "Please modify the file /etc/sysconfig/novell/oes-ldap, and replace the"
      echo "value for CONFIG_LDAP_ADMIN_CONTEXT with your admin account, and try again."
      exit 1
   fi  
}

function channel-oes() {

}

function xml_file() { 

}

function final_check() { 

}


