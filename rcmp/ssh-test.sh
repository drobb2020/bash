#!/bin/bash
PRL0=/tmp/prl0.tmp.$$
P0=/tmp/p0.tmp.$$

# Configure SSH to DSB specs
echo "Changing SSH configuration"

PRL0=$(cat /etc/ssh/sshd_config | grep -w PermitRootLogin | grep -v "#")
echo -e "$PRL0" >> /tmp/prl0.tmp$$

if [ -z /tmp/prl0.tmp.$$ ]
    then
	echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    else
	echo "The setting PermitRootLogin has already been set to no, configuration not modified ..."
fi
P0=$(cat /etc/ssh/sshd_config | grep -w Port | grep -v "#")
echo -e "$P0" >> /tmp/p0.tmp.$$

if [ -z /tmp/p0.tmp.$$ ]
    then
	echo "Port 3479" >> /etc/ssh/sshd_config
    else
	echo "The setting Port has already been set to 3479, configuration not modified ..."
fi

# restart ssh daemon for change to take effect
rcsshd restart
echo "SSH is now running on port 3479, and the root account no longer has SSH access."

exit
