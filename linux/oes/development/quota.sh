#!/bin/bash
VOL=PRIVOL
OUTFILE="/tmp/quota-summary-$VOL.txt"

#create 3 files with information
cat /_admin/Manage_NSS/Volume/$VOL/UserInfo.xml | grep "spaceUsed>" | cut -f5 -d'>' | sed 's/<\/spaceUsed//' > /tmp/Userinfo.xml-UsedSpace.txt 
cat /_admin/Manage_NSS/Volume/$VOL/UserInfo.xml | grep "quotaAmount>" | cut -f7 -d'>' | sed 's/<\/quotaAmount//' > /tmp/Userinfo.xml-quotaAmount.txt
cat /_admin/Manage_NSS/Volume/$VOL/UserInfo.xml | grep "name>" |  cut -f2 -d'>' |sed 's/<\/name//' > /tmp/UserInfo.xml-name.txt

#Create and array of UsedSpace
u=0
while read -r line ; do
        USEDSPACE[$u]="$line"
        u=$(($u+1))
done < /tmp/Userinfo.xml-UsedSpace.txt

#Create an array of the QuotaAmount
q=0
while read -r line ; do
        QUOTAAMOUNT[$q]="$line"
        q=$(($q+1))
done < /tmp/Userinfo.xml-quotaAmount.txt

#Create an array of the Names
n=0
while read -r line ; do
        NAME[$n]="$line"
        n=$(($n+1))
done < /tmp/UserInfo.xml-name.txt

echo ""
echo "Make sure counts are the same"
echo "used u is $u"
echo "quota q is $q"
echo "name n is $n"
echo ""

#print quota info to a file
COUNT=0
echo "NAME USEDSPACE QUOTAAMOUNT" >> $OUTFILE
  while [ $COUNT -lt $u ] ; do
    echo ${NAME[${COUNT}]} ${USEDSPACE[${COUNT}]}  ${QUOTAAMOUNT[${COUNT}]} >> $OUTFILE
    (( COUNT=COUNT+1 ))
  done

echo "Quota summary has been sent to $OUTFILE"
echo ""
exit 0

