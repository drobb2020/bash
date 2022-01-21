#!/bin/bash
####################################################################
# SUMA Archive Channel Creation Script - Called from Cron          #
#                                                                  #
# This script creates quarterly archives of SUSE Manager           #
# channels from SUSE Updates channels. It takes a list             #
# of source channels from the archive-sources.lst file             #
# that should be located in the same directory as this             #
# script. Each entry in that file will be used as a                #
# source channel to create an archive for patches/updates          #
# in the appropriate archive channel.                              #
#                                                                  #
# REQUIRES:                                                        #
# 1. cron entries for each quarter :                               #
# eg. 30th of months June and Sept. and 31st of months March       #
# and December:                                                    #
# 0 0 30 6,9 * /path/to/this/script                                #
# 0 0 31 3,12 * /path/to/this/script                               #
#                                                                  #
# 2. archive-sources.lst :                                         #
# A list of the architecture, the source updates channel           #
# for each distro and the suffix of the target channel             #
# version and architecture (1 per line - no line-feed at EOF)      #
# Example:                                                         #
# S390x,sles11-sp3-updates-s390x,SLES11-SP3-Updates for s390x      #
# ppc64,sles11-sp4-updates-ppc64,SLES11-SP4-Updates for PPC        #
# x86_64,sles11-sp3-updates-x86_64,SLES11-SP3-Updates for x86_64   #
# etc.                                                             #
#                                                                  #
####################################################################
#                                                                  #
# Created by - Jeff Price, SUSE Consulting - 2015                  #
#                                                                  #
####################################################################
## date strings
month=$(date +%m)
year=$(date +%Y)
fdate=$(date +%m-%d-%Y)

## set quarter
if [ "$month" -le 3 ]; then
  quar=1
elif [ "$month" -gt 3 ] && [ "$month" -lt 7 ]; then
  quar=2
elif [ "$month" -gt 6 ] && [ "$month" -lt 10 ]; then
  quar=3
elif [ "$month" -gt 9 ]; then
  quar=4
fi

## Create archives using source list
while read -r line
do
  arch=$(echo "$line" | awk -F, '{print $1}')
  src_ch=$(echo "$line" | awk -F, '{print $2}')
  trg_ch=$(echo "$line" | awk -F, '{print $3}')

## set archive channel
target_parent=$arch"-patch-archives-channel"
source_channel=$src_ch
target_channel_name="Q$quar $year - $fdate - Archive of $trg_ch"
target_summary="Q$quar-$year Archive Set $trg_ch"
target_channel_label="q$quar-$year-archive-$src_ch"

## Debug Output
echo "Architecture: " "$arch"
echo "Source Channel: " "$src_ch"
echo "Target Channel Archive Suffix: " "$trg_ch"
echo "Target Archive Parent Channel: " "$target_parent"
echo "Source Channel (again): " "$source_channel"
echo "Target Channel Name: " "$target_channel_name"
lctn=$(echo "$target_channel_name"|tr '[:upper:]' '[:lower:]')
echo "lowercase target name: " "$lctn"
echo "Target Channel Label: " "$target_channel_label"
echo "Target Channel Summary and Description: " "$target_summary"
/usr/bin/spacecmd -d -- softwarechannel_clone -s ��"$src_ch"�� -n
��"$target_channel_name"�� -l ��"$target_channel_label"�� -p ��"$target_parent"�� - g
/usr/bin/spacecmd -d -- softwarechannel_setorgaccess
��"$target_channel_label"�� -e
done < ./archive-sources.lst
