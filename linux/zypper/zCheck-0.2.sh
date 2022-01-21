#!/bin/bash

# version 0.2

outfile=/tmp/zCheck.$(date +%Y%m%d%M).out

count=$(zypper -x -n lu|grep -c "update name")
echo "Number of patches found: $count"
if [ "$count" == 0 ]; then
   echo "No updates this time, exiting!"
   exit 0
fi

echo "Comparing existing packages and updates..." > "$outfile"
echo "Comparing existing packages and updates..."

for item in $(zypper -x -n lu|grep "update name")
do
   newitem=${item//\"/ }
   currentitem=$(echo "$newitem" |awk '{ print $1 }')
   if [ "$currentitem" = "name=" ]; then
      itemname=$(echo "$newitem" |awk '{ print $2 }')
   fi
   if [ "$currentitem" = "edition=" ]; then
      itemedition=$(echo "$newitem" |awk '{ print $2 }')

      # Now let's break down the results...
      fullname=$itemname-$itemedition
      oldname=$(rpm -q "$itemname")
      echo "" >> "$outfile"
      echo ""
      echo "Existing version: $oldname" >> "$outfile"
      echo "Existing version: $oldname"
      echo "Updating version: $fullname" >> "$outfile"
      echo "Updating version: $fullname"
   fi
done
echo ""
#echo "Now, let's actually update the system... "
echo ""
#/usr/bin/zypper up
#/usr/bin/zypper up -y --skip-interactive
#/usr/bin/zypper up -y --type patch --skip-interactive
echo "" >> "$outfile"
echo ""
echo "...Done!" >> "$outfile"
echo "...Done!"
echo "See $outfile for results."

exit 0
