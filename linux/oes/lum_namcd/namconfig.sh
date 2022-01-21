#==============================================================================
# File: namconfig.sh
#
# Description: Configure LDAP Servers for NAM
#
# Usage: ./namconfig.sh
#==============================================================================

#==============================================================================
# History
#
# Version       Programmer              Date (YYYY-MM-DD)       Comments
# -----------------------------------------------------------------------------
# 1.0       Eric Ladouceur      2017-04-24      -Initial build
# 1.1		Eric Ladouceur		2017-05-02		-Add full path for nds command
# 1.2 		Eric Ladouceur		2017-05-05		-Fix conditions when server
#                                                holds more than 1 replica
# 1.3		Eric Ladouceur		2017-07-11		-Fix conditions for server
#                                                holding a replica
# 1.4		Eric Ladouceur		2017-07-19		-Add persistent search setting
#                                                check
# 1.5		Eric Ladouceur		2017-08-16		-Add cache-only setting check
#								-Add log location / level check
# 1.6		Joel Breton		2017-09-29		-using hostname -i to find primary IP
# 1.7		Eric Ladouceur		2017-11-21		-Change refresh flag to all
# 1.8		Joel Breton		2018-10-01		-Prompt for replica server if not found
#==============================================================================

/bin/bash /opt/scripts/os/postinstall/versioncheck.sh
RESULT=$?

if [ $RESULT -eq 1 ]; then
	echo ""
	echo "Please run /opt/scripts/os/postinstall/updatescripts.sh to update local scripts with server versions."
	echo "Once local scripts are updated, re-run $0"
	exit 0
elif [ $RESULT -eq 0 ]; then
        # If versioncheck.sh finished with code 0 (scripts are up to date, nothing updated),
        # continue with this script

	# Server Information

	#ACTIVE_INTERFACE=`/sbin/ifconfig | grep eth | awk '{print $1}'`
	#IP_ADDRESS=`/sbin/ifconfig $ACTIVE_INTERFACE | grep 'inet addr' | awk '{print $2}' | sed 's/addr://'`
	IP_ADDRESS=`hostname -i`
	SERVERDNSNAME=$(/usr/bin/nslookup $IP_ADDRESS | sed -n '4p' | cut -d\= -f 2 | cut -c 2-  | rev | cut -c 2- | rev)
	SERVERDNSDOMAIN=$(echo $SERVERDNSNAME | cut -d\. -f 2- )
	OESVERSION=$(cat /etc/novell-release | grep VERSION | cut -d\= -f2 | xargs)

	echo
	echo "***********************************************************************************"
	echo "Server IP: ${IP_ADDRESS}"
	echo "Server DNS Name: ${SERVERDNSNAME}"
	echo "Server DNS Domain: ${SERVERDNSDOMAIN}"
	echo "Server OES Version: ${OESVERSION}"
	
	# eDirectory information
	
	TREENAME=$(/opt/novell/eDirectory/bin/ndsstat | grep 'Tree Name' | awk '{print $3}')
	
	REPLICA=0
	NDSREPAIR=$(/opt/novell/eDirectory/bin/ndsrepair -E | grep Partition | wc -l)

	if [ $NDSREPAIR -ge 1 ];
	then
		REPLICA=1
		echo
		echo "Server holds a replica"
	else
	
		echo
		echo "Server doesn't have any replicas"
	fi

	# Current LDAP Server configuration

	CURRENT_PREFERRED_LDAPSERVER=$(namconfig get | grep -i ^preferred-server |  cut -d\= -f2)
	CURRENT_ALTERNATIVE_LDAPSERVER=$(namconfig get | grep -i ^alternative-ldap-server-list | cut -d\= -f2)
	CURRENT_PERSISTENT_SEARCH=$(namconfig get | grep -i ^persistent-search | cut -d\= -f2)
	CURRENT_PERSISTENT_CACHE_REFRESH_PERIOD=$(namconfig get | grep -i ^persistent-cache-refresh-period | cut -d\= -f2 | cut -d\[ -f1)
	CURRENT_PERSISTENT_CACHE_REFRESH_FLAG=$(namconfig get | grep -i ^persistent-cache-refresh-flag | cut -d\= -f2)
	CURRENT_CACHE_ONLY_FLAG=$(namconfig get | grep -i ^cache-only | cut -d\= -f2)

	if [ -z $(namconfig get | grep -i ^log-file-location | cut -d\= -f2) ]
	then
		CURRENT_LOG_FILE_LOCATION="None"

	else
		CURRENT_LOG_FILE_LOCATION=$(namconfig get | grep -i ^log-file-location | cut -d\= -f2)
	fi

	CURRENT_LOG_LEVEL=$(namconfig get | grep -i ^log-Level | cut -d\= -f2 | cut -d\[ -f1 | xargs)

	echo 
	echo "Current setting"
	echo
	echo "Preferred LDAP Server: $CURRENT_PREFERRED_LDAPSERVER"
	echo "Altnernative LDAP Servers: $CURRENT_ALTERNATIVE_LDAPSERVER"
	echo "Persistent-search: $CURRENT_PERSISTENT_SEARCH"
	echo "Persistent-cache-refresh-period: $CURRENT_PERSISTENT_CACHE_REFRESH_PERIOD"
	echo "Persistent-cache-refresh-flag: $CURRENT_PERSISTENT_CACHE_REFRESH_FLAG"
	echo "Cache-only: $CURRENT_CACHE_ONLY_FLAG"

	if [[ $OESVERSION =~ ^2015 ]];
        then
		echo "Log-file-location: $CURRENT_LOG_FILE_LOCATION"
		echo "Log-level: $CURRENT_LOG_LEVEL"
        fi
	echo "***********************************************************************************"


	if [ $SERVERDNSDOMAIN = "rcmp-grc.gc.ca" ];
	then
		EDIRREP2_DNSNAME=$(/usr/bin/nslookup root-$TREENAME-2.rcmp-grc.gc.ca | sed -n '4p' | cut -d\= -f 2 | cut -c 2-  | rev | cut -c 2- | rev)
		if [ $REPLICA -eq 1 ];
			then
			NEWPREFERREDLDAPSERVER=$SERVERDNSNAME
		else
			echo "Unable to detect a local replica."
			echo
			read -p "  Do you want to specify a replica server ? (y|n) " REPLY
			echo
			if [[ $REPLY =~ ^[Yy]$ ]]
			then
				read -p "Enter the name of the preferred replica server: " NEWPREFERREDLDAPSERVER
			else
				NEWPREFERREDLDAPSERVER="root-$TREENAME-1.rcmp-grc.gc.ca"
			fi
		fi

		if [ $EDIRREP2_DNSNAME != $SERVERDNSNAME ];
		then
			NEWALTERNATIVELDAPSERVER="root-$TREENAME-2.rcmp-grc.gc.ca,idm-$TREENAME.rcmp-grc.gc.ca"
		else
			NEWALTERNATIVELDAPSERVER="root-$TREENAME-1.rcmp-grc.gc.ca,idm-$TREENAME.rcmp-grc.gc.ca"
		fi
	else
		EDIRREP2_DNSNAME=$(/usr/bin/nslookup eDirReplica-2.$SERVERDNSDOMAIN | sed -n '4p' | cut -d\= -f 2 | cut -c 2-  | rev | cut -c 2- | rev)
		if [ $REPLICA -eq 1 ];
        	then
                	NEWPREFERREDLDAPSERVER=$SERVERDNSNAME
	        else
			echo "Unable to detect a local replica."
			echo
			read -p "  Do you want to specify a replica server ? (y|n) " REPLY
			echo
			if [[ $REPLY =~ ^[Yy]$ ]]
			then
				read -p "Enter the name of the preferred replica server: " NEWPREFERREDLDAPSERVER
			else
        	        	NEWPREFERREDLDAPSERVER="eDirReplica-1.$SERVERDNSDOMAIN"
			fi
	        fi

		if [ $EDIRREP2_DNSNAME != $SERVERDNSNAME ];
		then
			NEWALTERNATIVELDAPSERVER="eDirReplica-2.$SERVERDNSDOMAIN,idm-$TREENAME.rcmp-grc.gc.ca"
		else
			NEWALTERNATIVELDAPSERVER="eDirReplica-1.$SERVERDNSDOMAIN,idm-$TREENAME.rcmp-grc.gc.ca"
		fi
	fi

	# Configure NAM
	NAMCONFIGRESTART=0

	if [ $CURRENT_PREFERRED_LDAPSERVER == $NEWPREFERREDLDAPSERVER ];
	then
		echo
		echo "  Current Preferred LDAP Server is setup correctly" 
	else
		echo "Current Preferred LDAP Server: ${CURRENT_PREFERRED_LDAPSERVER}"
		echo "New Preferred LDAP Server: ${NEWPREFERREDLDAPSERVER}"
		echo
		read -p "  Change Preferred Server ? (y/n)" REPLY
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			namconfig set preferred-server=${NEWPREFERREDLDAPSERVER}
			echo "Preferred LDAP server changed"
			NAMCONFIGRESTART=1
		fi
	fi

	if [ $CURRENT_ALTERNATIVE_LDAPSERVER == $NEWALTERNATIVELDAPSERVER ];
	then
		echo
		echo "  Current Alternative LDAP Servers are setup correctly" 
	else
		echo "Current Alternative LDAP Servers: ${CURRENT_ALTERNATIVE_LDAPSERVER}"
		echo "New Alternative LDAP Servers: ${NEWALTERNATIVELDAPSERVER}"
		echo
		read -p "  Change Alternative LDAP Servers ? (y/n)" REPLY
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			namconfig set alternative-ldap-server-list=${NEWALTERNATIVELDAPSERVER}
			echo "Alternative LDAP Server changed"
			NAMCONFIGRESTART=1
		fi
	fi

	if [ $CURRENT_PERSISTENT_SEARCH == "no" ];
	then
		echo
		echo "  Current persistent search setting is OK" 
	else
		echo
		echo "New persistent search setting: no"
		namconfig set persistent-search=no
		NAMCONFIGRESTART=1
	fi

	if [ $CURRENT_PERSISTENT_CACHE_REFRESH_PERIOD == "3600" ];
	then
		echo
		echo "  Current persistent search cache refresh period setting is OK" 
	else
		echo
		echo "New persistent search cache refresh period setting: 3600"
		namconfig set persistent-cache-refresh-period=3600
		NAMCONFIGRESTART=1
	fi


	if [ $CURRENT_PERSISTENT_CACHE_REFRESH_FLAG == "all" ];
	then
		echo
		echo "  Current persistent search cache refresh flag setting is OK" 
	else
		echo
		echo "New persistent search cache refresh flag setting: All"
		namconfig set persistent-cache-refresh-flag=all
		NAMCONFIGRESTART=1
	fi


	if [ $CURRENT_CACHE_ONLY_FLAG == "no" ];
	then
		echo
		echo "  Current cache flag setting is OK" 
	else
		echo
		echo "New cache only flag setting: no"
		namconfig set cache-only=no
		NAMCONFIGRESTART=1
	fi


	if [[ $OESVERSION =~ ^2015 ]];
	then
		if [ $CURRENT_LOG_FILE_LOCATION == "/var/log/novell-lum" ] ;
		then
			echo
			echo "  Current log file location is OK" 
		else
			echo
			echo "New log file location is /var/log/novell-lum"
			if [ ! -d /var/log/novell-lum ];
			then
				mkdir /var/log/novell-lum;
			fi
			namconfig set log-file-location=/var/log/novell-lum
			NAMCONFIGRESTART=1
		fi

		if [ $CURRENT_LOG_LEVEL == "0" ];
		then
			echo
			echo "  Current log level is OK" 
		else
			echo
			echo "New log level is 0"
			namconfig set log-level=0
			NAMCONFIGRESTART=1
		fi

        else
                echo
                echo "  Log level / location not supported on OES 2"
        fi


	if [ $NAMCONFIGRESTART = 1 ];
        then
                if [[ $(rpm -qa | grep expect) ]]
                then
                        expect -c "
                                spawn namconfig -k
                                expect {
                                        "*admin*" {send "\\r"}; exp_continue}
                        "
                        echo ""

                        namconfig cache_refresh
                else
                        echo "Password not required - Press Enter to continue"
                        namconfig -k
                        namconfig cache_refresh
                fi
        fi
fi

echo
echo "Script completed successfully"
