#!/bin/bash - 
#===============================================================================
#
#          FILE: dsmc.sh
# 
#         USAGE: ./dsmc.sh 
# 
#   DESCRIPTION: SSC dsmcad start/stop process script
#
#                Copyright (C) 2014   Jacques Guillemette
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
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: /media/nss/<VolumeName>/tivoli/dsm.opt must exist
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: This script relies on two parameters the start or stop directive
#                in parm1($1) and the location of dsm.opt file in parm2 ($2).
#                The dsm.opt file must be stored within a tivoli folder at the root
#                of the volume of the resource to be backed up.
#        AUTHOR: Jacques Guillemette (jacques.guillemette@ssc-spc.gc.ca)
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: Tue May 20 2014 10:26
#  LAST UPDATED: Wed Jul 20 2016 09:53
#       VERSION: 0.1.3
#     SCRIPT ID: 000
# SSC UNIQUE ID: 37
#===============================================================================
set -o nounset                       # Treat unset variables as an error
version=0.1.3                        # Version level of script
ts=$(date +"%b %d %T")               # general date/time stamp
host=$(hostname)                     # host name of local server
user=$(whoami)                       # who is running the script
log='/var/log/tsm.log'               # logging (if required)
dsm=/usr/bin                         # path to dsmcad
tsmCmd=$1                            # first command line variable (start or stop)
volName=$2                           # second command line variable (name of TIV volume)
optFile="/media/nss/$2/tivoli-system/dsm.opt"   # absolute location of dsm.opt file

function initlog() {
  if [ -e ${log} ]; then
    echo "log file exists" > /dev/null
  else
    touch ${log}
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

function logit() {
  echo -e "$ts" "$host": "$@" >> ${log}
}

initlog

#Main

echo -e "" >> ${log}
logit "v$version SSC OES11 SP2 Tivoli NCS Script"
logit "=============================================="

case "${tsmCmd}" in
    start)
        logit "Initiating ${dsm}/dsmcad -optfile=${optFile}"
        ${dsm}/dsmcad -optfile="${optFile}"
        if [ $? -ne 0 ]; then
            logit "Initiating ${dsm}/dsmcad -optfile=${optFile} failed"
        else
            logit "Initiating dsmcad for ${2} was successful"
            pid=$(ps -ef | grep dsmcad | grep "${2}" | awk '{ print $2 }')
            logit "The pid of this process is: ${pid}"
            echo -e "$pid" > /var/run/dsmcad_"${2}".pid
        fi
    ;;
    stop)
        logit "Get Process ID for ${2}: $(cat /var/run/dsmcad_"${2}".pid)"
        pid=$(cat /var/run/dsmcad_"${2}".pid)
	logit "Initiating kill for the following process ${pid}"
        kill "${pid}"

        if [ $? -ne 0 ]; then
            logit "The kill process for dsmcad running for ${2} ($pid) failed"
        else
            logit "The kill process for dsmcad running for ${2} ($pid) was successful"
            rm -f /var/run/dsmcad_"${2}".pid
        fi
esac

exit 1

