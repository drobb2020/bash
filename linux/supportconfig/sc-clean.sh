#!/bin/bash - 
#===============================================================================
#
#          FILE: sc-clean.sh
# 
#         USAGE: ./sc-clean.sh 
# 
#   DESCRIPTION: Remove hostname and IP Address information from 
#                a supportconfig collection
#
#                Copyright (c) 2018, David Robb
#
#        GPL v2: This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License
#                as published by the Free Software Foundation; either version 2
#                of the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public License
#                along with this program; if not, write to the Free Software
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Fri Jul 11 2014 13:40
#  LAST UPDATED: Sun Mar 18 2018 11:47
#       VERSION: 0.3.4
#     SCRIPT ID: 053
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server

user=$(whoami)                                   # who is running the script
log='/var/log/sc-clean.log'                      # log name and location (if required)
DIALOG=${DIALOG=dialog}                          # to run in an xwindows (such as xming) change dialog to xdialog
base=${HOME}/shared/supportconfigs               # base location of files
[ -d "${base}" ] || mkdir -p "${base}"               # make the base if it does not exist
log=${base}/sc-cleaning.log                      # logging actions
location=$(mktemp --suffix=_location)            # temp file for location of extracted supportconfig
server=$(mktemp --suffix=_server)                # temp file for name of server
dns=$(mktemp --suffix=_dns)                      # temp file for dns suffix
ip=$(mktemp --suffix=_ip)                        # temp file for first IP octet
#===============================================================================

# Remove temporary files if the script is aborted
trap 'rm -f $location' 0 SIGHUP SIGINT SIGTRAP SIGTERM
trap 'rm -f $server' 0 SIGHUP SIGINT SIGTRAP SIGTERM
trap 'rm -f $dns' 0 SIGHUP SIGINT SIGTRAP SIGTERM
trap 'rm -f $ip' 0 SIGHUP SIGINT SIGTRAP SIGTERM

# Initialize logging
function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists" > /dev/null
  else
    touch $.log
    echo "Logging started at ${ts}" > "${log}"
    echo "All actions are being performed by the user: ${user}" >> "${log}"
    echo " " >> "${log}"
  fi
}

function logit() { 
  echo -e "$ts" "$host": "$@" >> "${log}"
}

initlog

# Opening note about the script
$DIALOG --colors --title "\Zb\Z0How to exit the script" --clear \
        --backtitle "Supportconfig cleaner - removes hostname and IP Addresses" \
        --msgbox "Please make sure all files are unpacked before proceeding.\nDuring the question phase you can use:\nctrl+c,\nESC,\nor the cancel button to exit this script.\nOnce the questions have been answered the script will perform the necessary operations on the files in the specified directory.\n-----------------------------------------------------------------\nsc-clean.sh  Copyright (C) 2014  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it\nunder certain conditions." 0 0

# Get the location of the unpacked supportconfig
$DIALOG --colors --title "\Zb\Z0Supportconfig Files location" --clear \
        --backtitle "Supportconfig cleaner - removes hostnames and IP Addresses" \
        --inputbox "Please enter the path to the unpacked supportconfig location. The base path is /home/david/sc.\nPlease fill in the remaining path\neg: cas-sac/nts_acpic-s0000_140808_1000:" 0 0 2> "$location"

retval1=$?

case $retval1 in
  1)
    echo "Good bye."; exit;;
  255)
    if test -s "$location" ; then
      cat "$location"
    else
      echo "Good bye."; exit
    fi
    ;;
esac

# Get the domain name for the server
$DIALOG --colors --title "\Zb\Z0DNS Domain Name" --clear \
        --backtitle "Supportconfig cleaner - removes hostnames and IP Addresses" \
        --inputbox "Please enter the domain name of this server. Include all portions of the DNS name\n(eg, ross.rcmp-grc.gc.ca):" 0 0 2> "$dns"

retval2=$?

case $retval2 in
  1)
    echo "Cancel pressed, goodbye."; exit;;
  255)
    if test -s "$dns" ; then
      cat "$dns"
    else
      echo "ESC pressed, goodbye."; exit
    fi
    ;;
esac

# grep the server name from the directory name
srv=$(cat "$location" | cut -f 2 -d "/" | cut -f 2 -d "_")
echo -e "$srv" > "$server"

#Get the first octet of the IP Address
$DIALOG --colors --title "\Zb\Z0First Octet of IP Address" --clear \
	      --backtitle "Supportconfig Cleaner - removes hostnames and IP Addresses" \
				--inputbox "Please enter the first octet of the IP Address.\n (eg, 10, or 192):" 0 0 2> "$ip"

retval3=$?

case $retval3 in
  1)
	  echo "Cancel pressed, goodbye."; exit;;
  255)
	  if test -s "$ip" ; then
		  cat "$ip"
	  else
		  echo "ESC pressed, goodbye."; exit
	  fi
	  ;;
esac


files=$(cat "$location")
host=$(cat "$server")
dn=$(cat "$dns")
dn1=$(cat "$dns" | cut -f 1 -d '.' )
dn2=$(cat "$dns" | cut -f 2- -d '.' )
ip1=$(cat "$ip")
clear

echo " " | tee -a "$log"
echo "-----------------------------------------------------------" | tee -a "$log"
logit "New supportconfig cleaning started at: $ts"
echo "==[ Supportconfig Cleaner ]================================" | tee -a "$log"
echo "You set the file location as: " "$base"/"$files" | tee -a "$log"
echo "The server name is: " "$host" | tee -a"$log"
echo "The domain name is: " "$dn" | tee -a "$log"
echo "-----------------------------------------------------------" | tee -a "$log"
echo ""
echo ""
sleep 1

if [ -d "$base"/"$files" ]; then
  for f in "$base"/"$files"/*.txt	
  do
    echo "Removing Hostname and IP Address information from $f ..." | tee -a "$log"
    sed -i 's/'"$host"'/host_primary/g' "$f" | tee -a "$log"
    sed -i 's/[a-z]\{1,5\}-s[0-9]\{1,4\}/host_secondary/g' "$f" | tee -a "$log"
    sed -i 's/[a-z]\{1,5\}-r[0-9]\{1,2\}-r[0-9]\{1,2\}-v[0-9]\{1,3\}/host_router/g' "$f" | tee -a "$log"
    sed -i 's/[a-z]\{1,5\}-r[0-9]\{1,2\}-adr-r/host_router/g' "$f" | tee -a "$log"
    sed -i 's/'"$dn"'/domain_primary.com/g' "$f" | tee -a "$log"
    #sed -i 's/'$dn1'/domain.com/g' $f | tee -a $log
    sed -i 's/'"$dn2"'/domain_secondary.com/g' "$f" | tee -a "$log"
    sed -i 's/specnatrp/snmptrap/g' "$f" | tee -a "$log"
    sed -i 's/specnatft/snmptrap/g' "$f" | tee -a "$log"
    sed -i 's/ehealthp1/snmptrap/g' "$f" | tee -a "$log"
    sed -i 's/ehealthp2/snmptrap/g' "$f" | tee -a "$log"
    sed -i 's/'"$ip1"'\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/xxx.xxx.xxx.xxx/g' "$f" | tee -a "$log"
    sed -i 's/127\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/lo.lo.lo.lo/g' "$f" | tee -a "$log"
		sed -i 's/169\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/zzz.zzz.zzz.zzz/g' "$f" | tee -a "$log"
		sed -i 's/224\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/mca.mca.mca.mca/g' "$f" | tee -a "$log"
		sed -i 's/239\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/mcb.mcb.mcb.mcb/g' "$f" | tee -a "$log"
		sed -i 's/255\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/mmm.mmm.mmm.mmm/g' "$f" | tee -a "$log"
    sed -i 's/[a-f0-9]\{1,4\}::[0-9]\{1,3\}:[a-f0-9]\{1,4\}:[a-f0-9]\{1,4\}:[0-9]\{1,4\}/xxxx::xxx:xxxx:xxxx:xxxx/g' "$f" | tee -a "$log"
  done
	clear
else
  echo -e "The supportconfig was not found at the location specified, please try again." | tee -a "$log"
  exit 1
fi

if [ -d "$base"/"$files"/sar ]; then
  for f1 in "$base"/"$files"/sar/*
  do
    echo "Removing Hostname information from ""$f1"" ..." | tee -a "$log"
    sed -i 's/'"$host"'/hostPrimary/g' "$f1"  | tee -a "$log"
  done
	clear
fi

if [ -d "$base"/"$files"/ldap-ncsvr-files ]; then
  for f2 in "$base"/"$files"/ldap-ncsvr-files/*
  do
    echo "Removing Hostname and IP Address information from $f2 ..." | tee -a "$log"
    sed -i 's/'"$host"'/hostPrimary/g' "$f2" | tee -a "$log"
    sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/xxx.xxx.xxx.xxx/g' "$f2" | tee -a "$log"
  done
fi
clear

if [ -d "$base"/"$files"/spacewalk-debug ]; then
  for f3 in "$base"/"$files"/spacewalk-debug/*
  do
    echo "Removing Hostname and IP address information from $f3 ..." | tee -a "$log"
    sed -i 's/'"$host"'/hostPrimary/g' "$f3" | tee -a "$log"
    sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/xxx.xxx.xxx.xxx/g' "$f2" | tee -a "$log"
  done
fi
clear
# Remove the existing spacewalk-debug.tar.bz2 file
if [ -e "$base"/"$files"s/spacewalk-debug.tar.bz2 ]; then
  rm -r "$base"/"$files"/spacewalk-debug.tar.bz2
fi

# Finished Cleaning files
echo "==[ Supportconfig Cleaner ]=====================================================" | tee -a "$log"
echo "All files in the collection have been cleaned of IP Address and hostname" | tee -a "$log"
echo "information" | tee -a "$log"
echo "Cleaning completed at: $ts" | tee -a "$log"
echo "--------------------------------------------------------------------------------" | tee -a "$log"
sleep 5
clear

# Tar up the spacewalk debug files
if [ -d "$base"/"$files"/spacewalk-debug ]; then
  echo "==[ Supportconfig Cleaner ]====================================================="
  echo "Going to tar up the modified spacewalk files for you now."
  echo "--------------------------------------------------------------------------------"
  pushd .
  cd "$base"/"$files"/spacewalk-debug || exit
  tar jcf spacewalk-debug-clean.tar.bz2 *
  mv *.bz2 ../
  rm -Rf "$base"/"$files"/spacewalk-debug
  popd || exit
fi
clear

# Tar up the modified files
echo "==[ Supportconfig Cleaner ]====================================================="
echo "Going to tar up the modified files for you now."
echo "--------------------------------------------------------------------------------"
pushd .
cd "$base"/"$files" || exit
tar jcf nts_"${host}"-clean_"$(date +'%y%m%d_%H%M')".tbz *
mv *.tbz ../
popd || exit
clear

# Clean up unneeded files
rm -f /tmp/tmp.*_location
rm -f /tmp/tmp.*_server
rm -f /tmp/tmp.*_dns
rm -f /tmp/tmp.*_ip
rm -f "$base"/"$files"/*.txt
rm -f "$base"/"$files"/*.xml
rm -f "$base"/"$files"/*.sh
rm -f "$base"/"$files"/*.out
rm -f "$base"/"$files"/*.html
rm -f "$base"/"$files"/*.SEMAPHORE
rm -f "$base"/"$files"/*.b64
rm -f "$base"/"$files"/*.bz2
rm -Rf "$base"/"$files"/sar
rm -Rf "$base"/"$files"/ldap-ncsvr-files
clear

# Exit message to local administrators
if [ "$user" != "david" ]; then
  echo "==[ Supportconfig Cleaner ]==================================================="
  echo "The files contained in the supportconfig for server $host"
  echo "have been cleaned of all hostname and IP Address information."
  echo "The files have been recompressed into a tarball." 
  echo "Please e-mail the cleaned tarball to your xSE."
  echo "------------------------------------------------------------------------------"
else
  echo "==[ Supportconfig Cleaner ]==================================================="
  echo "You know where to find the file..."
  echo "------------------------------------------------------------------------------"
fi

exit 1
