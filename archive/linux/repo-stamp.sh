#!/bin/bash

# Mirror all repositories and timestamps the new updates

# Mirror all new patches down to the configured repositories
/usr/sbin/smt-mirror

# Get the Repository ID for all configured repositories
r=$(/usr/sbin/smt-repos -o -v | grep "Repository ID" | cut -f 2 -d ":" | sed -e 's/^[ \t]*//')

# now timestamp all patches so they can be installed
for i in $r
  do
    /usr/sbin/smt-staging createrepo $i -t
    /usr/sbin/smt-staging createrepo $i -p
  done

# Completion message
echo ""
echo "--------------------------------------------------------------------"
echo "SMT Updated and ready for patching"
echo "--------------------------------------------------------------------"
echo "All configured repositories have been mirrored down from SCC, and"
echo "timestamped. Servers can now be patched to the latest releases."
echo "--------------------------------------------------------------------"

exit 1

