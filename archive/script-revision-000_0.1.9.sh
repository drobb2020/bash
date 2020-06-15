#!/bin/bash - 
#===============================================================================
#
#          FILE: script-revision.sh
# 
#         USAGE: ./script-revision.sh /path/to/scriptname.sh
# 
#   DESCRIPTION: 
#
#                Copyright (C) 2016  David Robb
#
#        GPL v3: This program is free software: you can redistribute it and/or 
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation, either version 3 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program.  If not,
#                see <http://www.gnu.org/licenses/>. 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Mon Jul 13 2015 11:50
#  LAST UPDATED: Tue Jun 14 2016 07:37
#      REVISION: 9
#     SCRIPT ID: 000
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.9                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/script-revision.log'              # logging (if required)
scripts='/run/media/david/scripts'              # path to script repository

function helpme() { 
  echo WARNING
	echo "--------------------------------------------------------------------------"
  echo "The correct command line syntax is:"
  echo "./script-revision.sh /path/to/scriptname.sh"
  echo "for example ./script-revision.sh /run/media/david/scripts/training/test.sh"
  echo "=========================================================================="
  exit 1
}

# separate the path from the script name
echo $1 > /tmp/pf.$$.tmp
echo "The path and script name entered is: $1"
cat /tmp/pf.$$.tmp | awk -F '/[^/]*$' '{print $1}' > /tmp/path.$$.tmp
cat /tmp/pf.$$.tmp | awk -F/ '{print $NF}' > /tmp/fn.$$.tmp
path=$(cat /tmp/path.$$.tmp)
fn=$(cat /tmp/fn.$$.tmp)
echo "The path to the script is: $path"
echo "The script name is: $fn"

# Get the version, sid and last updated timestamp from the script
cat $1 | grep version | awk 'END{print}' | cut -f 1 -d " " | cut -f 2 -d "=" > /tmp/org-ver.$$.tmp
cat $1 | grep sid | awk -F = '{print $2}' | cut -f 1 -d " " > /tmp/sid.$$.tmp
# if [ -n $(echo $1 | grep uid) ]; then
#  cat $1 | grep uid | awk -F = '{print $2}' | cut -f 1 -d " " > /tmp/uid.$$.tmp
# fi
cat $1 | grep "LAST UPDATED" | awk '{print $4, $5, $6, $7, $8}' > /tmp/lu.$$.tmp
echo $fn | cut -f 1 -d "." > /tmp/sn.$$.tmp
version=$(cat /tmp/org-ver.$$.tmp)
sid=$(cat /tmp/sid.$$.tmp)
echo "The current script version is: $version"
echo "The script ID is: $sid"

# Get Purpose and Author from script
cat $1 | grep DESCRIPTION | cut -f 2- -d ":" > /tmp/desc.$$.tmp
cat $1 | grep AUTHOR | awk '{print $3, $4}' > /tmp/author.$$.tmp
echo "Script Description is: $(cat /tmp/desc.$$.tmp)"
echo "The Author of this script is: $(cat /tmp/author.$$.tmp)"

# Function to increment the version number
increment_version ()
{
  declare -a part=( ${1//\./ } )
  declare    new
  declare -i carry=1

  for (( CNTR=${#part[@]}-1; CNTR>=0; CNTR-=1 )); do
    len=${#part[CNTR]}
    new=$((part[CNTR]+carry))
    [ ${#new} -gt $len ] && carry=1 || carry=0
    [ $CNTR -gt 0 ] && part[CNTR]=${new: -len} || part[CNTR]=${new}
  done
  new="${part[*]}"
  echo -e "${new// /.}"
} 

# Check to make sure a script has been specified on the command line
# Else increment the version, update the last updated timestamp, and 
# make a backup copy of the script
if [ $# -lt 1 ]; then
  clear
  echo "====================================================================="
  echo -e "\033[1;31mERROR\033[0m"
  echo "---------------------------------------------------------------------"
  echo "You are missing the name of the script on the command line, try again"
  echo "====================================================================="
  helpme
else
  increment_version $version > /tmp/new-ver.$$.tmp

  cat /tmp/new-ver.$$.tmp

  sed -i "s|version=.*|version=$(cat /tmp/new-ver.$$.tmp)|" $path/$fn
  sed -i "s|LAST UPDATED:.*|LAST UPDATED: $(date +"%a %b %d %Y %R")|" $path/$fn

  cp $path/$fn $path/$(cat /tmp/sn.$$.tmp)-$(cat /tmp/sid.$$.tmp)_$(cat /tmp/new-ver.$$.tmp).sh

	# Backup the script catalog to archives so you can work on it.
	/bin/cp $scripts/script_catalog.xml $scripts/archives/script_catalog_$(date +'%Y%m%d_%H%M').xml
  # Update the script catalog with new information
	if [ -f /tmp/uid.$$.tmp ]; then
	/usr/bin/xml ed -L -u "/catalog/scripts/script/sid[@id=$(cat /tmp/sid.$$.tmp)]/uid" -v $(cat /tmp/uid.$$.tmp) /home/david/bin/script_catalog.xml
  fi
  /usr/bin/xml ed -L -u "/catalog/scripts/script/sid[@id=$(cat /tmp/sid.$$.tmp)]/name" -v $(cat /tmp/fn.$$.tmp) /home/david/bin/script_catalog.xml

  /usr/bin/xml ed -L -u "/catalog/scripts/script/sid[@id=$(cat /tmp/sid.$$.tmp)]/purpose" -v "$(cat /tmp/desc.$$.tmp)" /home/david/bin/script_catalog.xml

  /usr/bin/xml ed -L -u "/catalog/scripts/script/sid[@id=$(cat /tmp/sid.$$.tmp)]/version" -v $(cat /tmp/new-ver.$$.tmp) /home/david/bin/script_catalog.xml

  /usr/bin/xml ed -L -u "/catalog/scripts/script/sid[@id=$(cat /tmp/sid.$$.tmp)]/author" -v "$(cat /tmp/author.$$.tmp)" /home/david/bin/script_catalog.xml

  /usr/bin/xml ed -L -u "/catalog/scripts/script/sid[@id=$(cat /tmp/sid.$$.tmp)]/location" -v $(cat /tmp/path.$$.tmp) /home/david/bin/script_catalog.xml

  # Delete all the temp files used during the execution of this script
  rm -f /tmp/*.$$.tmp
fi

exit 1
