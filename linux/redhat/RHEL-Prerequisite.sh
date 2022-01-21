#!/bin/bash
##################################################################################
#
# Copyright © 2017 NetIQ Corporation, a Micro Focus company. All Rights Reserved.
#
##################################################################################

uname -a | grep -i linux &> /dev/null
if [ "$(echo "$?")" == 0 ] && [ -f /etc/redhat-release ]
then
	echo nothing > /dev/null
else
	echo ""
	echo -e "\tThis script can be run only on redhat linux machine"
	echo ""
	exit
fi
hostname | grep -q ^localhost\.
localfqdn=$?
hostname | grep -q ^localhost$
localonly=$?
if [ $localfqdn -eq 0 ] || [ $localonly -eq 0 ]
then
	echo ""
	echo -e "\tHostname configured wrongly with localhost"
	echo ""
	exit 1
fi
echo ""
datenow=`date +%Y%m%d%H%M`
#A - required rpm name for both 32 and 64 bit machine
#B - Required rpm name for 64 bit machine outputs corresponding -32bit rpms if any
#C - Required file name for 64 bit machine outputs corresponding -32bit rpms if any
#D - Required file name for both 32 and 64 bit machine
#E - Required file name for 32 bit machine
pre-requisite()
{
echo "Running Pre-requisite for $package" 
echo ""
for a in `echo $A`
do
	echo $a | grep i686 > /dev/null
	if [ `echo $?` == 0 ]
	then
		a=`echo $a | cut -d"." -f1`
		rpm -qa | grep ^$a- | grep -E "i386|i586|i686" > /dev/null
		if [ `echo $?` != 0 ]
		then
			echo -e "\t$a i686 ( 32 bit ) rpm required but not found" >> /tmp/$datenow.log
			continue
		fi
	fi
	echo $a | grep x86_64 > /dev/null
	if [ `echo $?` == 0 ]
	then
		a=`echo $a | cut -d"." -f1`
		rpm -qa | grep ^$a- | grep x86_64 > /dev/null
		if [ `echo $?` != 0 ]
		then
			echo -e "\t$a x86_64 rpm required but not found" >> /tmp/$datenow.log
			continue
		fi
	fi
	rpm -qa | grep ^$a- > /dev/null
	if [ `echo $?` != 0 ]
	then
		echo -e "\t$a rpm required but not found" >> /tmp/$datenow.log
	fi
done
machinelongbit=`getconf LONG_BIT`
if [ $machinelongbit == 64 ]
then
	if [ ! -z "$B" ]
	then
		for a in `echo $B`
		do
			rpm -qa | grep ^$a- > /dev/null
			if [ `echo $?` != 0 ]
		        then
                		echo -e "\t$a rpm required but not found" >> /tmp/$datenow.log
		        fi
		done
	fi
	if [ ! -z "$C" ]
	then
		for a in `echo $C`
		do
			ls $a* &> /dev/null
			if [ `echo $?` != 0 ]
                        then
				echo $a | grep libccs2 &> /dev/null
				if [ `echo $?` == 0 ]
				then
                			echo -e "\tnici 32bit rpm required but not found" >> /tmp/$datenow.log
				else
					echo -e "\t$a file / symlink required but not found" >> /tmp/$datenow.log
				fi
			fi
		done
	fi
else
	if [ ! -z "$E" ]
	then
		for a in `echo $E`
                do
                        ls $a &> /dev/null
                        if [ `echo $?` != 0 ]
                        then
                        	echo -e "\t$a file / symlink required but not found" >> /tmp/$datenow.log
                        fi
                done
	fi
fi
if [ ! -z "$D" ]
then
	for a in `echo $D`
	do
		ls $a* &> /dev/null
		if [ `echo $?` != 0 ]
		then
			echo $a | grep libccs2 &> /dev/null
			if [ `echo $?` == 0 ]
			then
				echo -e "\tnici rpm required but not found" >> /tmp/$datenow.log
			fi
			grep libpng12 $a &> /dev/null
			if [ `echo $?` == 0 ]
			then
				echo -e "\t/usr/lib/libpng12.so.0 library required but not found" >> /tmp/$datenow.log
			fi
		fi
	done
fi
if [ -f "/tmp/$datenow.log" ]
then
	cat /tmp/$datenow.log
	echo -e "\tPlease refer the documentation on what the exact revision of rpms listed above is needed"
	echo ""
	rm /tmp/$datenow.log
else
	echo -e "\tAll the pre-requisites for $package have been met"
	echo ""
fi
}
#unset A B C D E
#package=`echo GUI Identity Manager`
#A=`echo libXrender.i686 libXau.i686 libxcb.i686 libX11.i686 libXext.i686 libXi.i686 libXtst.i686 glibc.x86_64 libstdc++.i686 libstdc++.x86_64 libgcc.x86_64 unzip gettext ksh`
#export A package > /dev/null
#pre-requisite
unset A B C D E
package=`echo Identity Manager`
A=`echo glibc.x86_64 libstdc++.x86_64 libgcc.x86_64 net-tools.x86_64 zip unzip gettext ksh bc lsof`
export A package > /dev/null
pre-requisite
unset A B C D E
echo "Running Pre-requisite for Java Remote Loader"
echo ""
if type -p java > /dev/null
then
	echo -e "\tFound java executable in PATH" > /dev/null
	_java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]
then
	echo -e "\tFound java executable in JAVA_HOME" > /dev/null
	_java="$JAVA_HOME/bin/java"
else
	echo -e "\tNo java hence Java Remote Loader can't run"
	echo ""
fi

if [[ "$_java" ]]
then
	version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
	echo -e "\tVersion of java is $version" 
	version2=`echo $version | cut -c'1,2,3'`
	echo | awk -v n1=$version2 -v n2=1.8  '{if (n1<n2) printf ("%s < %s\n", n1, n2); else printf ("%s >= %s\n", n1, n2);}'  | grep '>' &> /dev/null
	if [ `echo $?` == 0 ]
	then
        	echo -e "\tAll the pre-requisites for Java Remote Loader have been met"
		echo ""
	else         
        	echo -e "\tVersion of java is less than 1.8 hence Java Remote Loader can't be run"
		echo ""
	fi
fi
unset A B C D E
package=`echo Identity Vault`
if [ -f /etc/redhat-release ] ; then
	reqd_glibc_version=2.4
	if [ "$reqd_glibc_version" != "" ]
        then
                installed_glibc_version=`rpm -qi glibc | grep "Version" | awk '{print $3}'`
                xcomponents=`echo $reqd_glibc_version | tr "." " " | tr "-" " "`
                ycomponents=`echo $installed_glibc_version | tr "." " " | tr "-" " "`
                firstxcomponents=`echo $xcomponents | cut -d" " -f1`
                firstycomponents=`echo $ycomponents | cut -d" " -f1`
                secondxcomponents=`echo $xcomponents | cut -d" " -f2`
                secondycomponents=`echo $ycomponents | cut -d" " -f2`
                if [ "$firstxcomponents" != "$firstycomponents" ]
                then
                        echo -e "\t$a base version should match $reqd_glibc_version" >> /tmp/$datenow.log
                        continue
                else
                        if [ "${secondxcomponents}" -gt "${secondycomponents}" ]
                        then
                                echo -e "\t$a version should be greater than or equal to $reqd_glibc_version" >> /tmp/$datenow.log
                                continue
                        fi
                fi
        fi
	source /etc/os-release
	if (( $(awk 'BEGIN {print ("'$VERSION_ID'" >= "'8'")}') ))
	then
	  A=$(echo gettext.x86_64 libstdc++.x86_64 yum-utils createrepo_c yum)
	else
	  A=$(echo gettext.x86_64 libstdc++.x86_64 yum-utils createrepo yum)
	fi
	export A B package > /dev/null
fi
pre-requisite
unset A B C D E
package=$(echo iManager Web Administration)
A=$(echo glibc.i686 libXau.i686 libxcb.i686 libX11.i686 libXext.i686 libXi.i686 libXtst.i686 libgcc.i686 libXrender.i686 libstdc++.x86_64 lsof)
export A package > /dev/null
pre-requisite
if [ ! -f /etc/redhat-release ] ; then
	unset A B C D E
	package=`echo Designer`
	A=`echo gettext.x86_64`
	C=`echo /opt/novell/lib64/libccs2`
	export A C package > /dev/null
	pre-requisite
	unset A B C D E
	package=`echo Analyzer`
	A=`echo gettext`
	C=`echo /opt/novell/lib/libccs2`
	D=`echo /usr/lib/libpng12.so.0`
	export A C D package > /dev/null
	pre-requisite
fi
