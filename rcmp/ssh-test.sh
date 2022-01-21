#!/bin/bash
PRL0=/tmp/prl0.tmp.$$
P0=/tmp/p0.tmp.$$

# Configure SSH to DSB specs
echo "Changing SSH configuration"

PRL0=$(grep -w PermitRootLogin /etc/ssh/sshd_config | grep -v "#")
echo -e "$PRL0" >> /tmp/prl0.tmp$$

if [ -n "/tmp/prl0.tmp.$$" ]
    then
    echo "The setting PermitRootLogin has already been set to no, configuration not modified..."
    else
	echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi
P0=$(grep -w Port /etc/ssh/sshd_config | grep -v "#")
echo -e "$P0" >> /tmp/p0.tmp.$$

if [ -n "/tmp/p0.tmp.$$" ]
    then
    echo "The setting Port has already been set to 3479, configuration not modified..."
    else
    echo "Port 3479" >> /etc/ssh/sshd_config
fi

# restart ssh daemon for change to take effect
rcsshd restart

echo "SSH is now running on port 3479, and the root account no longer has SSH access."

exit 0
