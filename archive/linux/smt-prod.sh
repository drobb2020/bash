#!/bin/bash
# Script to mirror and timestamp production repositories

# Get the repository ID's for all configured repositories
r=$(/usr/sbin/smt-repos -o -v | grep "Repository ID" | cut -f 2 -d ":" | sed -e 's/^[ \t]*//')

# Now timestamp all patches so they can be installed
for i in $r
  do 
    /usr/sbin/smt-staging createrepo $i -p
  done

# Completion message
echo ""
echo "---------------------------------------------------------------------"
echo "SMT Updated - Servers ready for patching"
echo "---------------------------------------------------------------------"
echo "All configured repositories have been mirrored down from NCC/SCC, and"
echo "timestamped. Servers can now be patched to the latest releases."
echo "---------------------------------------------------------------------"
echo "Have fun patching ..."
echo ""

exit 1

