#!/bin/bash
# Post Installation Settings for the RCMP

# NSS Settings for Mail
echo "Turning off access time and salvage on the MAIL volume."

echo -e "/noatime=mail" > /dev/nsscmd
echo -e "/nosalvage=mail" > /dev/nsscmd

echo "These settings are permanent accross reboots of the server."
sleep 2

# Configure SSH to DSB specs
echo "Changing SSH configuration"
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "Port 3479" >> /etc/ssh/sshd_config
# restart ssh daemon for change to take effect
rcsshd restart
echo "SSH is now running on port 3479, and root does not have access."
sleep 2

# LUM Configuration
# Admin should add the IP Address of the local server to this command
namconfig set preferred-server=192.168.2.102
# Admin should add the IP Addresses of two or more server near this server
# the IP Addresses should be comma separated without spaces.
namconfig set alternative-ldap-server-list=192.168.2.101
namconfig set persistent-search=no

rcnamcd restart
sleep 1

namconfig -k
echo "LUM configuration is complete."
sleep 2

# NCP Configuration
ncpcon set CROSS_PROTOCOL_LOCKS=1
ncpcon set FIRST_WATCHDOG_PACKET=5
ncpcon set MAXIMUM_CACHED_FILES_PER_SUBDIRECTORY=10000
ncpcon set MAXIMUM_CACHED_FILES_PER_VOLUME=80000
ncpcon set MAXIMUM_CACHED_SUBDIRECTORIES_PER_VOLUME=200000

/etc/init.d/ncp2nss restart
rcndsd restart
echo "NCP configuration is complete."
sleep 2

# NDS Configuration
ndsconfig set n4u.nds.advertise-life-time=600

rcndsd restart
echo "NDS configuration is complete."
sleep 1

# Finish Message
echo ""
echo "All post installation changes have been made to this server."
echo "To ensure all changes take effect please reboot the server"
echo "at your earliest convenience."
echo "RCMP ECS Team"

exit
