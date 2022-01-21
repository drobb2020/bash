#!/bin/sh

# Ipaddress change script - by Glen Davis - version 1.2
args=$@
oldip=$1
newip=$2
oldremoteip=$3
newremoteip=$4
total=`echo $args | awk 'END { print NF }'`
## check for root user
 if [ "`id -u`" -ne 0 ];  then 
 	echo "You must be root to run this script!"
	echo ""
	echo "Also,before running this script you should change your old ipaddress to your new ipaddress in yast2 network.  This script will then change the ipaddress for your other OES configuration files. "
	echo ""
 	exit 
  fi 

usage()
{
echo
echo "Usage ->  ./ipchange.sh oldip newip oldremoteip newremoteip"
echo 
echo "You must enter all four arguments.  oldip is your old ip address, new ip is your new ip address."
echo "The remoteip is the remote address you used when installing this server into the eDirectory tree. oldremoteip and newremoteip may be the same if the remoteip is not changing"
echo
exit 1
}
##############################################################################################
# There is still one entry at the bottom - cert file that we need to change with this script #
##############################################################################################

     if [ $total -lt 4 ];  then
        
	usage
     fi



echo ""

echo "First before running this script you should change your old ipaddress to your new ipaddress in yast2 network.  This script will then change the ipaddress for your other OES configuration files. "

echo "Your old ipaddress $oldip is being changed to your new ipaddress $newip"

if ! [ "$oldremoteip" = "$newremoteip" ]
then
echo "Your Remote edir/ldap IP is changing from $oldremoteip to $newremoteip"
fi


# use random numbers for backup
# $RANDOM returns a different random integer at each invocation.
# Nominal range: 0 - 32767 (signed 16-bit integer).

MAXCOUNT=1000
count=1

echo

while [ "$count" -le $MAXCOUNT ]      # Generate 10 ($MAXCOUNT) random integers.
do
  number=$RANDOM
 # echo $number
  let "count += 1"  # Increment count.
done



echo

while [ "$count" -le $MAXCOUNT ]      # Generate 10 ($MAXCOUNT) random integers.
do
  number2=$RANDOM
 # echo $number
  let "count += 1"  # Increment count.
done
echo "-----------------"





oes2() {

# change /etc/nam.conf
echo "Changing nam.conf file"
cp /etc/nam.conf /etc/nam.org
sed "s/$oldip/$newip/g" /etc/nam.conf > /tmp/nam.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/nam.$number > /tmp/nam.$number2
cp /tmp/nam.$number2 /etc/nam.conf
rm /tmp/nam.$number
rm /tmp/nam.$number2



# change /etc/opt/novell/eDirectory/conf/nds.conf
echo "Changing nds.conf file"
cp /etc/opt/novell/eDirectory/conf/nds.conf /etc/opt/novell/eDirectory/conf/nds.$number
sed "s/$oldip/$newip/g" /etc/opt/novell/eDirectory/conf/nds.conf > /tmp/nds.$number
cp /tmp/nds.$number /etc/opt/novell/eDirectory/conf/nds.conf
rm /tmp/nds.$number


# change /etc/sysconfig/novell/ldap_servers/$oldremoteip to $newremoteip

if [ -f /etc/sysconfig/novell/ldap_servers/$oldremoteip ] && ! [ "$oldremoteip" = "$newremoteip" ]
then

echo "Changing and renaming /etc/sysconfig/novell/ldap_servers/$oldremoteip" 
mv /etc/sysconfig/novell/ldap_servers/$oldremoteip /etc/sysconfig/novell/ldap_servers/$newremoteip
sed "s/$oldremoteip/$newremoteip/g" /etc/sysconfig/novell/ldap_servers/$newip > /tmp/$newremoteip
cp /tmp/$newremoteip /etc/sysconfig/novell/ldap_servers/$newremoteip
rm /tmp/$newremoteip
fi


if [ -f /etc/sysconfig/novell/ldap_servers/$oldip ]
then
echo "Changing and renaming /etc/sysconfig/novell/ldap_servers/$oldip"
# change /etc/sysconfig/novell/ldap_servers/$oldip to $newip
mv /etc/sysconfig/novell/ldap_servers/$oldip /etc/sysconfig/novell/ldap_servers/$newip
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/ldap_servers/$newip > /tmp/$newip
cp /tmp/$newip /etc/sysconfig/novell/ldap_servers/$newip
rm /tmp/$newip
fi




# change /etc/sysconfig/novell/NetStorage
if [ -f /etc/sysconfig/novell/NetStorage ]
then
echo "Changing /etc/sysconfig/novell/NetStorage file"

cp /etc/sysconfig/novell/NetStorage /etc/sysconfig/novell/NetStorage.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NetStorage > /tmp/NetStorage.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NetStorage.$number > /tmp/NetStorage.$number2
cp /tmp/NetStorage.$number2 /etc/sysconfig/novell/NetStorage
rm /tmp/NetStorage.$number
rm /tmp/NetStorage.$number2

fi

# change /etc/sysconfig/novell/NovellDhcp
if [ -f /etc/sysconfig/novell/NovellDhcp ]
then
echo "Changing /etc/sysconfig/novell/NovellDhcp file"

cp /etc/sysconfig/novell/NovellDhcp /etc/sysconfig/novell/NovellDhcp.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NovellDhcp > /tmp/NovellDhcp.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NovellDhcp.$number > /tmp/NovellDhcp.$number2
cp /tmp/NovellDhcp.$number2 /etc/sysconfig/novell/NovellDhcp
rm /tmp/NovellDhcp.$number
rm /tmp/NovellDhcp.$number2

fi


# change /etc/sysconfig/novell/NovellSamba
if [ -f /etc/sysconfig/novell/NovellSamba ]
then
echo "Changing /etc/sysconfig/novell/NovellSamba file"

cp /etc/sysconfig/novell/NovellSamba /etc/sysconfig/novell/NovellSamba.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NovellSamba > /tmp/NovellSamba.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NovellSamba.$number > /tmp/NovellSamba.$number2
cp /tmp/NovellSamba.$number2 /etc/sysconfig/novell/NovellSamba
rm /tmp/NovellSamba.$number
rm /tmp/NovellSamba.$number2

fi

# change /etc/sysconfig/novell/NovellDns
if [ -f /etc/sysconfig/novell/NovellDns ]
then
echo "Changing /etc/sysconfig/novell/NovellDns file"

cp /etc/sysconfig/novell/NovellDns /etc/sysconfig/novell/NovellDns.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NovellDns > /tmp/NovellDns.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NovellDns.$number > /tmp/NovellDns.$number2
cp /tmp/NovellDns.$number2 /etc/sysconfig/novell/NovellDns
rm /tmp/NovellDns.$number
rm /tmp/NovellDns.$number2

fi


# change /etc/sysconfig/novell/iprint and other iprint config files
if [ -f /etc/sysconfig/novell/iprint ]
then
echo "Changing /etc/sysconfig/novell/iprint file"

cp /etc/sysconfig/novell/iprint /etc/sysconfig/novell/iprint.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/iprint > /tmp/iprint.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/iprint.$number > /tmp/iprint.$number2
cp /tmp/iprint.$number2 /etc/sysconfig/novell/iprint
rm /tmp/iprint.$number
rm /tmp/iprint.$number2

fi

# change /etc/sysconfig/novell/imanager
if [ -f /etc/sysconfig/novell/imanager ]
then
echo "Changing /etc/sysconfig/novell/imanager file"

cp /etc/sysconfig/novell/imanager /etc/sysconfig/novell/imanager.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/imanager > /tmp/imanager.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/imanager.$number > /tmp/imanager.$number2
cp /tmp/imanager.$number2 /etc/sysconfig/novell/imanager
rm /tmp/imanager.$number
rm /tmp/imanager.$number2

fi



# change /etc/sysconfig/novell/lum
if [ -f /etc/sysconfig/novell/lum ]
then
echo "Changing /etc/sysconfig/novell/lum file"

cp /etc/sysconfig/novell/lum /etc/sysconfig/novell/lum.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/lum > /tmp/lum.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/lum.$number > /tmp/lum.$number2
cp /tmp/lum.$number2 /etc/sysconfig/novell/lum
rm /tmp/lum.$number
rm /tmp/lum.$number2

fi

# change /etc/sysconfig/novell/ncs
if [ -f /etc/sysconfig/novell/ncs ]
then
echo "Changing /etc/sysconfig/novell/ncs file"

cp /etc/sysconfig/novell/ncs /etc/sysconfig/novell/ncs.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/ncs > /tmp/ncs.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/ncs.$number > /tmp/ncs.$number2
cp /tmp/ncs.$number2 /etc/sysconfig/novell/ncs
rm /tmp/ncs.$number
rm /tmp/ncs.$number2

fi


# change /etc/sysconfig/novell/nss
if [ -f /etc/sysconfig/novell/nss ]
then
echo "Changing /etc/sysconfig/novell/nss file"

cp /etc/sysconfig/novell/nss /etc/sysconfig/novell/nss.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/nss > /tmp/nss.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/nss.$number > /tmp/nss.$number2
cp /tmp/nss.$number2 /etc/sysconfig/novell/nss
rm /tmp/nss.$number
rm /tmp/nss.$number2

fi



# change /etc/sysconfig/novell/sms
if [ -f /etc/sysconfig/novell/sms ]
then
echo "Changing /etc/sysconfig/novell/sms file"

cp /etc/sysconfig/novell/sms /etc/sysconfig/novell/sms.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/sms > /tmp/sms.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/sms.$number > /tmp/sms.$number2
cp /tmp/sms.$number2 /etc/sysconfig/novell/sms
rm /tmp/sms.$number
rm /tmp/sms.$number2

fi


# change /etc/sysconfig/novell/ifolder3
if [ -f /etc/sysconfig/novell/ifolder3 ]
then
echo "Changing /etc/sysconfig/novell/ifolder3 file"

cp /etc/sysconfig/novell/ifolder3 /etc/sysconfig/novell/ifolder3.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/ifolder3 > /tmp/ifolder3.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/ifolder3.$number > /tmp/ifolder3.$number2
cp /tmp/ifolder3.$number2 /etc/sysconfig/novell/ifolder3
rm /tmp/ifolder3.$number
rm /tmp/ifolder3.$number2
fi

if [ -f /opt/novell/ifolder3/lib/simias/admin/Web.config ]
then
cp /opt/novell/ifolder3/lib/simias/admin/Web.config /opt/novell/ifolder3/lib/simias/admin/Web.config.$number
sed "s/$oldip/$newip/g" /opt/novell/ifolder3/lib/simias/admin/Web.config > /tmp/ifWeb1.$number
cp /tmp/ifWeb1.$number /opt/novell/ifolder3/lib/simias/admin/Web.config

cp /opt/novell/ifolder3/lib/simias/webaccess/Web.config /opt/novell/ifolder3/lib/simias/webaccess/Web.config.$number
sed "s/$oldip/$newip/g" /opt/novell/ifolder3/lib/simias/webaccess/Web.config > /tmp/ifWeb2.$number
cp /tmp/ifWeb2.$number /opt/novell/ifolder3/lib/simias/webaccess/Web.config

cp /var/simias/data/simias/Simias.config /var/simias/data/simias/Simias.config.$number
sed "s/$oldip/$newip/g" /var/simias/data/simias/Simias.config > /tmp/simias.$number
cp /tmp/simias.$number /var/simias/data/simias/Simias.config

fi




echo "Changing dhcpd.conf file"
cp /etc/dhcpd.conf /etc/dhcpd.org
sed "s/$oldip/$newip/g" /etc/dhcpd.conf > /tmp/dhcpd.$number
cp /tmp/dhcpd.$number /etc/dhcpd.conf
rm /tmp/dhcpd.$number

# change /etc/samba/smb.conf
if [ -f /etc/samba/smb.conf ]
then
echo "Changing /etc/samba/smb.conf file"

cp /etc/samba/smb.conf /etc/samba/smb.conf.$number
sed "s/$oldip/$newip/g" /etc/samba/smb.conf > /tmp/smb.conf.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/smb.conf.$number > /tmp/smb.conf.$number2
cp /tmp/smb.conf.$number2 /etc/samba/smb.conf
rm /tmp/smb.conf.$number
rm /tmp/smb.conf.$number2

fi


# change /etc/opt/novell/httpd/conf.d/  files
if [ -f /etc/opt/novell/httpd/conf.d/iprint_g.conf ]
then
echo "Changing /etc/opt/novell/httpd/conf.d/iprint_g.conf file"

cp /etc/opt/novell/httpd/conf.d/iprint_g.conf /etc/opt/novell/httpd/conf.d/iprint_g.$number
sed "s/$oldip/$newip/g" /etc/opt/novell/httpd/conf.d/iprint_g.conf > /tmp/iprint_g.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/iprint_g.$number > /tmp/iprint_g.$number2
cp /tmp/iprint_g.$number2 /etc/opt/novell/httpd/conf.d/iprint_g.conf
rm /tmp/iprint_g.$number
rm /tmp/iprint_g.$number2

fi

if [ -f /etc/opt/novell/httpd/conf.d/iprint_ssl.conf ]
then
echo "Changing /etc/opt/novell/httpd/conf.d/iprint_ssl.conf file"

cp /etc/opt/novell/httpd/conf.d/iprint_ssl.conf /etc/opt/novell/httpd/conf.d/iprint_ssl.$number
sed "s/$oldip/$newip/g" /etc/opt/novell/httpd/conf.d/iprint_ssl.conf > /tmp/iprint_ssl.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/iprint_ssl.$number > /tmp/iprint_ssl.$number2
cp /tmp/iprint_ssl.$number2 /etc/opt/novell/httpd/conf.d/iprint_ssl.conf
rm /tmp/iprint_ssl.$number
rm /tmp/iprint_ssl.$number2

fi


}



oes2sp1_additions() {

#  This section checks for new files added in oes2sp1





# change /etc/sysconfig/novell/netstore
if [ -f /etc/sysconfig/novell/netstore ]
then
echo "Changing /etc/sysconfig/novell/netstore file"

cp /etc/sysconfig/novell/netstore /etc/sysconfig/novell/netstore.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/netstore > /tmp/netstore.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/netstore.$number > /tmp/netstore.$number2
cp /tmp/netstore.$number2 /etc/sysconfig/novell/netstore
rm /tmp/netstore.$number
rm /tmp/netstore.$number2

fi

# change /etc/sysconfig/novell/NvlDhcp
if [ -f /etc/sysconfig/novell/NvlDhcp ]
then
echo "Changing /etc/sysconfig/novell/NvlDhcp file"

cp /etc/sysconfig/novell/NvlDhcp /etc/sysconfig/novell/NvlDhcp.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NvlDhcp > /tmp/NvlDhcp.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NvlDhcp.$number > /tmp/NvlDhcp.$number2
cp /tmp/NvlDhcp.$number2 /etc/sysconfig/novell/NvlDhcp
rm /tmp/NvlDhcp.$number
rm /tmp/NvlDhcp.$number2

fi





# change /etc/sysconfig/novell/nvlsamba
if [ -f /etc/sysconfig/novell/nvlsamba ]
then
echo "Changing /etc/sysconfig/novell/nvlsamba file"

cp /etc/sysconfig/novell/nvlsamba /etc/sysconfig/novell/nvlsamba.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/nvlsamba > /tmp/nvlsamba.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/nvlsamba.$number > /tmp/nvlsamba.$number2
cp /tmp/nvlsamba.$number2 /etc/sysconfig/novell/nvlsamba
rm /tmp/nvlsamba.$number
rm /tmp/nvlsamba.$number2

fi


# change /etc/sysconfig/novell/NvlDns
if [ -f /etc/sysconfig/novell/NvlDns ]
then
echo "Changing /etc/sysconfig/novell/NvlDns file"

cp /etc/sysconfig/novell/NvlDns /etc/sysconfig/novell/NvlDns.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NvlDns > /tmp/NvlDns.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NvlDns.$number > /tmp/NvlDns.$number2
cp /tmp/NvlDns.$number2 /etc/sysconfig/novell/NvlDns
rm /tmp/NvlDns.$number
rm /tmp/NvlDns.$number2

fi


# change /etc/sysconfig/novell/iprnt and other iprint config files
if [ -f /etc/sysconfig/novell/iprnt ]
then
echo "Changing /etc/sysconfig/novell/iprnt file"

cp /etc/sysconfig/novell/iprnt /etc/sysconfig/novell/iprnt.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/iprnt > /tmp/iprnt.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/iprnt.$number > /tmp/iprnt.$number2
cp /tmp/iprnt.$number2 /etc/sysconfig/novell/iprnt
rm /tmp/iprnt.$number
rm /tmp/iprnt.$number2

fi

# change /etc/sysconfig/novell/iman
if [ -f /etc/sysconfig/novell/iman ]
then
echo "Changing /etc/sysconfig/novell/iman file"

cp /etc/sysconfig/novell/iman /etc/sysconfig/novell/iman.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/iman > /tmp/iman.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/iman.$number > /tmp/iman.$number2
cp /tmp/iman.$number2 /etc/sysconfig/novell/iman
rm /tmp/iman.$number
rm /tmp/iman.$number2

fi



# change /etc/sysconfig/novell/lum1
if [ -f /etc/sysconfig/novell/lum1 ]
then
echo "Changing /etc/sysconfig/novell/lum1 file"

cp /etc/sysconfig/novell/lum1 /etc/sysconfig/novell/lum1.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/lum1 > /tmp/lum1.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/lum1.$number > /tmp/lum1.$number2
cp /tmp/lum1.$number2 /etc/sysconfig/novell/lum1
rm /tmp/lum1.$number
rm /tmp/lum1.$number2
fi

# change /etc/sysconfig/novell/ncs1
if [ -f /etc/sysconfig/novell/ncs1 ]
then
echo "Changing /etc/sysconfig/novell/ncs1 file"

cp /etc/sysconfig/novell/ncs1 /etc/sysconfig/novell/ncs1.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/ncs1 > /tmp/ncs1.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/ncs1.$number > /tmp/ncs1.$number2
cp /tmp/ncs1.$number2 /etc/sysconfig/novell/ncs1
rm /tmp/ncs1.$number
rm /tmp/ncs1.$number2
fi


# change /etc/sysconfig/novell/nss1
if [ -f /etc/sysconfig/novell/nss1 ]
then
echo "Changing /etc/sysconfig/novell/nss1 file"

cp /etc/sysconfig/novell/nss1 /etc/sysconfig/novell/nss1.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/nss1 > /tmp/nss1.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/nss1.$number > /tmp/nss1.$number2
cp /tmp/nss1.$number2 /etc/sysconfig/novell/nss1
rm /tmp/nss1.$number
rm /tmp/nss1.$number2
fi



# change /etc/sysconfig/novell/sms1
if [ -f /etc/sysconfig/novell/sms1 ]
then
echo "Changing /etc/sysconfig/novell/sms1 file"

cp /etc/sysconfig/novell/sms1 /etc/sysconfig/novell/sms1.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/sms1 > /tmp/sms1.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/sms1.$number > /tmp/sms1.$number2
cp /tmp/sms1.$number2 /etc/sysconfig/novell/sms1
rm /tmp/sms1.$number
rm /tmp/sms1.$number2
fi


# change /etc/sysconfig/novell/ifldr3
if [ -f /etc/sysconfig/novell/ifldr3 ]
then
echo "Changing /etc/sysconfig/novell/ifldr3 file"

cp /etc/sysconfig/novell/ifldr3 /etc/sysconfig/novell/ifldr3.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/ifldr3 > /tmp/ifldr3.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/ifldr3.$number > /tmp/ifldr3.$number2
cp /tmp/ifldr3.$number2 /etc/sysconfig/novell/ifldr3
rm /tmp/ifldr3.$number
rm /tmp/ifldr3.$number2
fi

# change /etc/sysconfig/novell/afp
if [ -f /etc/sysconfig/novell/afp ]
then
echo "Changing /etc/sysconfig/novell/afp file"

cp /etc/sysconfig/novell/afp /etc/sysconfig/novell/afp.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/afp > /tmp/afp.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/afp.$number > /tmp/afp.$number2
cp /tmp/afp.$number2 /etc/sysconfig/novell/afp
rm /tmp/afp.$number
rm /tmp/afp.$number2
fi

# change /etc/sysconfig/novell/NvlCifs
if [ -f /etc/sysconfig/novell/NvlCifs ]
then
echo "Changing /etc/sysconfig/novell/NvlCifs file"

cp /etc/sysconfig/novell/NvlCifs /etc/sysconfig/novell/NvlCifs.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NvlCifs > /tmp/NvlCifs.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NvlCifs.$number > /tmp/NvlCifs.$number2
cp /tmp/NvlCifs.$number2 /etc/sysconfig/novell/NvlCifs
rm /tmp/NvlCifs.$number
rm /tmp/NvlCifs.$number2
fi

# this is for dsfw
if [ -f /etc/opt/novell/xad/xad.ini ]
then
echo "Changing /etc/opt/novell/xad/xad.ini"

cp /etc/opt/novell/xad/xad.ini /etc/opt/novell/xad/xad.ini.$number
sed "s/$oldip/$newip/g" /etc/opt/novell/xad/xad.ini > /tmp/xad.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/xad.$number > /tmp/xad.$number2
cp /tmp/xad.$number2 /etc/opt/novell/xad/xad.ini
rm /tmp/xad.$number
rm /tmp/xad.$number2
fi
# dsfw end


}



oes2sp2_additions () 
{

# change oes2sp2_additions

#This section checks for new files added in oes2sp2


# change /etc/sysconfig/novell/netstore2_sp2
if [ -f /etc/sysconfig/novell/netstore2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/netstore2_sp2 file"

cp /etc/sysconfig/novell/netstore2_sp2 /etc/sysconfig/novell/netstore2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/netstore2_sp2 > /tmp/netstore2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/netstore2_sp2.$number > /tmp/netstore2_sp2.$number2
cp /tmp/netstore2_sp2.$number2 /etc/sysconfig/novell/netstore2_sp2
rm /tmp/netstore2_sp2.$number
rm /tmp/netstore2_sp2.$number2

fi

# change /etc/sysconfig/novell/NvlDhcp2_sp2
if [ -f /etc/sysconfig/novell/NvlDhcp2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/NvlDhcp2_sp2 file"

cp /etc/sysconfig/novell/NvlDhcp2_sp2 /etc/sysconfig/novell/NvlDhcp2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NvlDhcp2_sp2 > /tmp/NvlDhcp2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NvlDhcp2_sp2.$number > /tmp/NvlDhcp2_sp2.$number2
cp /tmp/NvlDhcp2_sp2.$number2 /etc/sysconfig/novell/NvlDhcp2_sp2
rm /tmp/NvlDhcp2_sp2.$number
rm /tmp/NvlDhcp2_sp2.$number2

fi


# change /etc/sysconfig/novell/nvlsamba2_sp2
if [ -f /etc/sysconfig/novell/nvlsamba2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/nvlsamba2_sp2 file"

cp /etc/sysconfig/novell/nvlsamba2_sp2 /etc/sysconfig/novell/nvlsamba2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/nvlsamba2_sp2 > /tmp/nvlsamba2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/nvlsamba2_sp2.$number > /tmp/nvlsamba2_sp2.$number2
cp /tmp/nvlsamba2_sp2.$number2 /etc/sysconfig/novell/nvlsamba2_sp2
rm /tmp/nvlsamba2_sp2.$number
rm /tmp/nvlsamba2_sp2.$number2

fi


# change /etc/sysconfig/novell/NvlDns2_sp2
if [ -f /etc/sysconfig/novell/NvlDns2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/NvlDns2_sp2 file"

cp /etc/sysconfig/novell/NvlDns2_sp2 /etc/sysconfig/novell/NvlDns2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NvlDns2_sp2 > /tmp/NvlDns2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NvlDns2_sp2.$number > /tmp/NvlDns2_sp2.$number2
cp /tmp/NvlDns2_sp2.$number2 /etc/sysconfig/novell/NvlDns2_sp2
rm /tmp/NvlDns2_sp2.$number
rm /tmp/NvlDns2_sp2.$number2

fi


# change /etc/sysconfig/novell/iprnt2_sp2
if [ -f /etc/sysconfig/novell/iprnt2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/iprnt2_sp2 file"

cp /etc/sysconfig/novell/iprnt2_sp2 /etc/sysconfig/novell/iprnt2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/iprnt2_sp2 > /tmp/iprnt2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/iprnt2_sp2.$number > /tmp/iprnt2_sp2.$number2
cp /tmp/iprnt2_sp2.$number2 /etc/sysconfig/novell/iprnt2_sp2
rm /tmp/iprnt2_sp2.$number
rm /tmp/iprnt2_sp2.$number2

fi

# change /etc/sysconfig/novell/iman2_sp2
if [ -f /etc/sysconfig/novell/iman2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/iman2_sp2 file"

cp /etc/sysconfig/novell/iman2_sp2 /etc/sysconfig/novell/iman2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/iman2_sp2 > /tmp/iman2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/iman2_sp2.$number > /tmp/iman2_sp2.$number2
cp /tmp/iman2_sp2.$number2 /etc/sysconfig/novell/iman2_sp2
rm /tmp/iman2_sp2.$number
rm /tmp/iman2_sp2.$number2

fi


# change /etc/sysconfig/novell/lum2_sp2
if [ -f /etc/sysconfig/novell/lum2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/lum2_sp2 file"

cp /etc/sysconfig/novell/lum2_sp2 /etc/sysconfig/novell/lum2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/lum2_sp2 > /tmp/lum2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/lum2_sp2.$number > /tmp/lum2_sp2.$number2
cp /tmp/lum2_sp2.$number2 /etc/sysconfig/novell/lum2_sp2
rm /tmp/lum2_sp2.$number
rm /tmp/lum2_sp2.$number2
fi

# change /etc/sysconfig/novell/ncs2_sp2
if [ -f /etc/sysconfig/novell/ncs2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/ncs2_sp2 file"

cp /etc/sysconfig/novell/ncs2_sp2 /etc/sysconfig/novell/ncs2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/ncs2_sp2 > /tmp/ncs2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/ncs2_sp2.$number > /tmp/ncs2_sp2.$number2
cp /tmp/ncs2_sp2.$number2 /etc/sysconfig/novell/ncs2_sp2
rm /tmp/ncs2_sp2.$number
rm /tmp/ncs2_sp2.$number2
fi


# change /etc/sysconfig/novell/nss2_sp2
if [ -f /etc/sysconfig/novell/nss2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/nss2_sp2 file"

cp /etc/sysconfig/novell/nss2_sp2 /etc/sysconfig/novell/nss2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/nss2_sp2 > /tmp/nss2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/nss2_sp2.$number > /tmp/nss2_sp2.$number2
cp /tmp/nss2_sp2.$number2 /etc/sysconfig/novell/nss2_sp2
rm /tmp/nss2_sp2.$number
rm /tmp/nss2_sp2.$number2
fi



# change /etc/sysconfig/novell/sms2_sp2
if [ -f /etc/sysconfig/novell/sms2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/sms2_sp2 file"

cp /etc/sysconfig/novell/sms2_sp2 /etc/sysconfig/novell/sms2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/sms2_sp2 > /tmp/sms2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/sms2_sp2.$number > /tmp/sms2_sp2.$number2
cp /tmp/sms2_sp2.$number2 /etc/sysconfig/novell/sms2_sp2
rm /tmp/sms2_sp2.$number
rm /tmp/sms2_sp2.$number2
fi


# change /etc/sysconfig/novell/ifldr3_2_sp2
if [ -f /etc/sysconfig/novell/ifldr3_2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/ifldr3_2_sp2 file"

cp /etc/sysconfig/novell/ifldr3_2_sp2 /etc/sysconfig/novell/ifldr3_2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/ifldr3_2_sp2 > /tmp/ifldr3_2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/ifldr3_2_sp2.$number > /tmp/ifldr3_2_sp2.$number2
cp /tmp/ifldr3_2_sp2.$number2 /etc/sysconfig/novell/ifldr3_2_sp2
rm /tmp/ifldr3_2_sp2.$number
rm /tmp/ifldr3_2_sp2.$number2
fi

# change /etc/sysconfig/novell/afp2_sp2
if [ -f /etc/sysconfig/novell/afp2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/afp2_sp2 file"

cp /etc/sysconfig/novell/afp2_sp2 /etc/sysconfig/novell/afp2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/afp2_sp2 > /tmp/afp2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/afp2_sp2.$number > /tmp/afp2_sp2.$number2
cp /tmp/afp2_sp2.$number2 /etc/sysconfig/novell/afp2_sp2
rm /tmp/afp2_sp2.$number
rm /tmp/afp2_sp2.$number2
fi

# change /etc/sysconfig/novell/NvlCifs2_sp2
if [ -f /etc/sysconfig/novell/NvlCifs2_sp2 ]
then
echo "Changing /etc/sysconfig/novell/NvlCifs2_sp2 file"

cp /etc/sysconfig/novell/NvlCifs2_sp2 /etc/sysconfig/novell/NvlCifs2_sp2.$number
sed "s/$oldip/$newip/g" /etc/sysconfig/novell/NvlCifs2_sp2 > /tmp/NvlCifs2_sp2.$number
sed "s/$oldremoteip/$newremoteip/g" /tmp/NvlCifs2_sp2.$number > /tmp/NvlCifs2_sp2.$number2
cp /tmp/NvlCifs2_sp2.$number2 /etc/sysconfig/novell/NvlCifs2_sp2
rm /tmp/NvlCifs2_sp2.$number
rm /tmp/NvlCifs2_sp2.$number2
fi
}

nows_sbe ()
{

if [ -d /opt/simba ] # check for simba folder
then
echo "Changing NOWS components..."
sed -i "s/\\b$oldip\\b/$newip/g" $(grep -l $oldip /var/lib/simba/sbs/components/*/conf/*.xml) /var/lib/simba/sbs/conf/networking.xml /opt/gnome/share/gdm/themes/NOWSSBE/*.xml /etc/issue
fi

}




oes2
oes2sp1_additions
oes2sp2_additions
nows_sbe
echo ""
echo "Running namconfig -k to regenerate certificate"
namconfig -k


echo "Finished!  Please reboot your server to complete your address change."
echo ""

exit
