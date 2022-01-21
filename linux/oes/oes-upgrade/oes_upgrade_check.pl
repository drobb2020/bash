#!/usr/bin/perl 


################################################################################
# This script checks the configuration of all the services for any
# modification done manually besides installation. If modification
# detected in a service, it shows the list of attributes modified and
# requests user if he/she wants to keep/discard those modified attribute.
#
# Copyright (c) 2014
#       Novell, Inc.  All rights reserved.
################################################################################

use strict;
#use warnings;

my $VERSION_NUMBER="1.0.0";   #script version

my $CURRENT_DIR=`pwd`;
chomp $CURRENT_DIR;
my $NSS_ADMIN_INSTALL_BIN_PATH;

#Global variables
my $numArgs = $#ARGV + 1; #Holds the number of commandline arguments
my $oes_release_name; #get oes release name from the file novell-release ex: 11.1
my $release_name; #OES release name ex: oes11_sp1
my $scriptname; # name of the perl script
my @LIST_SYSCONFIG_FILES; # Holds the list of services in an array 
my @SERVICE_CONFIGURED_YES; # Holds the list of services configured in an array
my @SERVICE_CONFIGURED_NO;  # Holds the list of services not configured in an array
my %SYSCONFIG_MODIFIED_ATTR=(); #Stores the list of modified attributes in a hash (Verify)
my %SYSCONFIG_NO_CHANGE_ATTR=(); #Stores the list of unmodified attributes in a hash
my %SYSCONFIG_MODIFIED_ATTR_DISP=(); #Stores the list of modified attributes in a hash for a single service (Verify)
my $PATH_SYSCONFIG="/etc/sysconfig/novell"; #Path of the sysconfig files
my @LIST_SYSCONFIG_FILES_WRITE; #Stores the list of modified attributes in a hash for writing into a sysconfig files
my $oes_patch_number; # oes patch release number ex: 1
my $oes_release_number; # oes release number ex: 11
my $CURRENT_TIME=`date +%F_%T`;
chomp $CURRENT_TIME;
my $EDIR_SYSCONFIG_FILE_NAME;
my $EDIR_TREE_TYPE;
my $XAD_CONFIGURED;

my @LIST_SYSCONFIG_ATTR_AFP=('CONFIG_AFP_EDIR_CONTEXTS'); # An array to hold afp service attributes
my @LIST_SYSCONFIG_ATTR_LUM=('CONFIG_LUM_LDAP_SERVER','CONFIG_LUM_PARTITION_ROOT','CONFIG_LUM_WS_CONTEXT','CONFIG_LUM_PROXY_USER');
my @LIST_SYSCONFIG_ATTR_DSFW=('XAD_CONFIG_DNS');
my @LIST_SYSCONFIG_ATTR_EDIR=('CONFIG_EDIR_SERVER_CONTEXT','CONFIG_EDIR_HTTP_PORT','CONFIG_EDIR_HTTPS_PORT','CONFIG_EDIR_NTP_SERVERS','CONFIG_EDIR_SLP_MODE','CONFIG_EDIR_DASYNC','CONFIG_EDIR_SLP_BACKUP','CONFIG_EDIR_SLP_BACKUP_INTERVAL','CONFIG_EDIR_SLP_SCOPES','CONFIG_EDIR_SLP_DA');
my @LIST_SYSCONFIG_ATTR_LDAP=('CONFIG_LDAP_PROXY_CONTEXT','XAD_TREE_ADMIN_CONTEXT');
my @LIST_SYSCONFIG_ATTR_CIFS=('CONFIG_CIFS_PROXY_USER','CONFIG_CIFS_EDIR_CONTEXTS');
my @LIST_SYSCONFIG_ATTR_IPRINT=('CONFIG_IPRINT_TOP_CONTEXT','CONFIG_IPRINT_LDAP_SERVER');
my @LIST_SYSCONFIG_ATTR_DHCP=('CONFIG_DHCPSRV_LDAP_SERVER','CONFIG_DHCPSRV_SERVER_CONTEXT','CONFIG_DHCPSRV_SERVER_OBJECT_NAME','CONFIG_DHCPSRV_LDAP_USER_CONTEXT');
my @LIST_SYSCONFIG_ATTR_NSS=('CONFIG_NSS_NSSADMIN_DN');
my @LIST_SYSCONFIG_ATTR_IFOLDER=('CONFIG_IFOLDER_LDAP_SERVER','CONFIG_IFOLDER_SERVER_NAME','CONFIG_IFOLDER_PUBLIC_URL','CONFIG_IFOLDER_PRIVATE_URL','CONFIG_IFOLDER_SYSTEM_ADMIN_CONTEXT','CONFIG_IFOLDER_LDAP_PROXY_USER_CONTEXT','CONFIG_IFOLDER_LDAP_SEARCH_CONTEXTS','CONFIG_IFOLDER_NAMING_ATTRIBUTE');
my @LIST_SYSCONFIG_ATTR_NCS=('CONFIG_NCS_LDAP_SERVER','CONFIG_NCS_PROXY_USER');
my @LIST_SYSCONFIG_ATTR_NETSTORAGE=('CONFIG_XTIER_PROXY_CONTEXT');

my %LIST_SYSCONFIG_FILES_OES2SP3=('afp2_sp3' => \@LIST_SYSCONFIG_ATTR_AFP,'edir2_sp3' => \@LIST_SYSCONFIG_ATTR_EDIR,'iprnt2_sp3' => \@LIST_SYSCONFIG_ATTR_IPRINT,'lum2_sp3' => \@LIST_SYSCONFIG_ATTR_LUM,'NvlCifs2_sp3' => \@LIST_SYSCONFIG_ATTR_CIFS,'NvlDhcp2_sp3' => \@LIST_SYSCONFIG_ATTR_DHCP,'ifldr3_2_sp3' => \@LIST_SYSCONFIG_ATTR_IFOLDER,'ncs2_sp3' => \@LIST_SYSCONFIG_ATTR_NCS,'oes-ldap' => \@LIST_SYSCONFIG_ATTR_LDAP,'nss2_sp3' => \@LIST_SYSCONFIG_ATTR_NSS,'xad2_sp3' => \@LIST_SYSCONFIG_ATTR_DSFW); # A hash which holds the reference to array of service attributes

my %LIST_SYSCONFIG_FILES_OES11=('afp2_oes11' => \@LIST_SYSCONFIG_ATTR_AFP,'edir2_oes11' => \@LIST_SYSCONFIG_ATTR_EDIR,'lum2_oes11' => \@LIST_SYSCONFIG_ATTR_LUM,'NvlCifs2_oes11' => \@LIST_SYSCONFIG_ATTR_CIFS,'iprnt2_oes11' => \@LIST_SYSCONFIG_ATTR_IPRINT,'NvlDhcp2_oes11' => \@LIST_SYSCONFIG_ATTR_DHCP,'ifldr3_2_oes11' => \@LIST_SYSCONFIG_ATTR_IFOLDER,'ncs2_oes11' => \@LIST_SYSCONFIG_ATTR_NCS,'oes-ldap' => \@LIST_SYSCONFIG_ATTR_LDAP,'nss2_oes11' => \@LIST_SYSCONFIG_ATTR_NSS,,'xad2_oes11' => \@LIST_SYSCONFIG_ATTR_DSFW);

my %LIST_SYSCONFIG_FILES_OES11SP1=('afp_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_AFP,'edir_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_EDIR,'iprnt_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_IPRINT,'lum_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_LUM,'NvlCifs_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_CIFS,'NvlDhcp_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_DHCP,'ifldr3_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_IFOLDER,'ncs_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_NCS,'oes-ldap' => \@LIST_SYSCONFIG_ATTR_LDAP,'netstore_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_NETSTORAGE,'nss_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_NSS,'xad_oes11_sp1' => \@LIST_SYSCONFIG_ATTR_DSFW);

my %LIST_SYSCONFIG_FILES_OES11SP2=('afp_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_AFP,'edir_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_EDIR,'iprnt_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_IPRINT,'lum_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_LUM,'NvlCifs_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_CIFS,'NvlDhcp_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_DHCP,'ifldr3_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_IFOLDER,'ncs_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_NCS,'oes-ldap' => \@LIST_SYSCONFIG_ATTR_LDAP,'netstore_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_NETSTORAGE,'nss_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_NSS,'xad_oes11_sp2' => \@LIST_SYSCONFIG_ATTR_DSFW);

my %LIST_SYSCONFIG_FILES_OES2015=('afp_oes2015' => \@LIST_SYSCONFIG_ATTR_AFP,'edir_oes2015' => \@LIST_SYSCONFIG_ATTR_EDIR,'iprnt_oes2015' => \@LIST_SYSCONFIG_ATTR_IPRINT,'lum_oes2015' => \@LIST_SYSCONFIG_ATTR_LUM,'NvlCifs_oes2015' => \@LIST_SYSCONFIG_ATTR_CIFS,'NvlDhcp_oes2015' => \@LIST_SYSCONFIG_ATTR_DHCP,'ifldr3_oes2015' => \@LIST_SYSCONFIG_ATTR_IFOLDER,'ncs_oes2015' => \@LIST_SYSCONFIG_ATTR_NCS,'oes-ldap' => \@LIST_SYSCONFIG_ATTR_LDAP,'netstore_oes2015' => \@LIST_SYSCONFIG_ATTR_NETSTORAGE,'nss_oes2015' => \@LIST_SYSCONFIG_ATTR_NSS,'xad_oes2015' => \@LIST_SYSCONFIG_ATTR_DSFW);

my %SERVICES_WITH_OES_RELEASE=('2.0.3' => \%LIST_SYSCONFIG_FILES_OES2SP3, '11' => \%LIST_SYSCONFIG_FILES_OES11, '11.1' => \%LIST_SYSCONFIG_FILES_OES11SP1, "11.2" => \%LIST_SYSCONFIG_FILES_OES11SP2, "2015" => \%LIST_SYSCONFIG_FILES_OES2015);  

my %SYSCONF_FILE_NAMES=('afp'=>'afp','lum'=>'lum','edir'=>'edir','cifs'=>'NvlCifs','iprint'=>'iprnt','dhcp'=>'NvlDhcp','ifolder'=>'ifldr3','ncs' => 'ncs','netstorage'=>'netstore','nss' => 'nss','dsfw' => 'xad'); # command line input mapped to actual sysconfig files name


open (my $OUTPUT, '>', "/tmp/oes_upgrade_check-$CURRENT_TIME") || die "File could not open";



#Function to find out what version of OES installed in the system
sub OESReleaseName
{
   if (-e "/etc/novell-release") #if novell-release file exists 
   {
      my $oes_version_name=`grep  -r VERSION /etc/novell-release`; #grep for VERSION in the 'novell-release' file
      my @oes_version_number=split('=',$oes_version_name);
      $oes_release_name=pop @oes_version_number; #get the oes release name ex: 11.1
      chomp $oes_release_name;
      $oes_release_name =~ s/^\s+//; #remove leading spaces
      my @oes_release_number_and_patch=split('\.',$oes_release_name);
      $oes_release_number=shift @oes_release_number_and_patch; #get oes release number ex: 11
      if(@oes_release_number_and_patch)
      {
         $oes_patch_number=pop @oes_release_number_and_patch; #get oes release patch number ex: 1
         $release_name="oes$oes_release_number\_sp$oes_patch_number"; #detect oes release name ex: oes11_sp1
      }
      else
      {
         $release_name="oes$oes_release_number";
      }
      print $OUTPUT "\n \n\t\t ************************************************ \n";
      print $OUTPUT "\n  \t\t *\t OES server installed :  $release_name \t*  \n";
      print $OUTPUT "\n  \t\t *\t OES Upgrade Script Version :  $VERSION_NUMBER \t*  \n";
      print $OUTPUT "\n \t\t ************************************************ \n\n";
      print " \n\t\t ************************************************ \n";
      print "  \t\t *\t OES server installed :  $release_name \t*  \n";
      print "  \t\t *\t OES Upgrade Script Version :  $VERSION_NUMBER \t*  \n";
      print " \t\t ************************************************ \n\n"; 
   }
   else
   {
      print $OUTPUT "\n\n \t\t OES does not found on this server\n"; 
      print "\n \t\t OES does not found on this server\n"; #if novell-release file doesn't exists
      exit;
   }
}


# This function verifies and applies the modified attributes value 
sub Verify_and_Apply
{
  print $OUTPUT "\nList of sysconfig files are @LIST_SYSCONFIG_FILES \n";
  foreach (@LIST_SYSCONFIG_FILES) # list of sysconfig files based on command line input
  {
#    print $OUTPUT "\nCheck $_ is configured or not \n";
    if (-e "$PATH_SYSCONFIG/$_") #if sysconfig file exists
    {
       my $SERVICE_CONFIGURED=`grep -r SERVICE_CONFIGURED $PATH_SYSCONFIG/$_` ; #check whether service is configured or not
       my @SERVICE_CONFIGURED_VAR = split('=',$SERVICE_CONFIGURED);
       chomp(@SERVICE_CONFIGURED_VAR);
       my @SERVICE_CONFIGURED_VAL = split('"',$SERVICE_CONFIGURED_VAR[1]);
       chomp(@SERVICE_CONFIGURED_VAL);
       if ($SERVICE_CONFIGURED_VAL[1] eq 'yes' )
       {
          print $OUTPUT "\n$_ is configured\n\n";

=begin CONFIG_EDIR_REPLICA_SERVER needs to be handled specially
          if ( "$_" eq "$EDIR_SYSCONFIG_FILE_NAME" )
		  {
              my $CONFIG_EDIR_TREE_TYPE_VALUE = FindValueInSysconfigFile("CONFIG_EDIR_TREE_TYPE",$_); #Check value of CONFIG_EDIR_TREE_TYPE 
              chomp $CONFIG_EDIR_TREE_TYPE_VALUE;
              if ( "$CONFIG_EDIR_TREE_TYPE_VALUE" eq "existing" ) # CONFIG_EDIR_REPLICA_SERVER value Valid only when CONFIG_EDIR_TREE_TYPE="existing"
              {
		$EDIR_TREE_TYPE="existing";
                  push (@LIST_SYSCONFIG_ATTR_EDIR,'CONFIG_EDIR_REPLICA_SERVER');
              }
          }
=cut 
          read_sysconf_files($_); #if service is configured read the attribute value in the sysconfig files
       }
       else
       {
          print $OUTPUT "\n$_ is not configured \n";
          push (@SERVICE_CONFIGURED_NO, $_); #store the not configured files in an array
       }
    }
    else
    {
       print $OUTPUT "\n File not found : $PATH_SYSCONFIG/$_ \n";
       print " File not found : $PATH_SYSCONFIG/$_ \n";
    }
  }
}


# this function gets the value for slp attributes
sub SlpEdir
{
    my $CONF_ATTR=$_[0];
    my $CHANGE_VALUE_PATH_NAME=$_[1];
    my $SLP_CONF_ATTR = `grep -r ^$CONF_ATTR $CHANGE_VALUE_PATH_NAME`;
    my @SLP_CONF_ATTR_ARR = split('=',$SLP_CONF_ATTR);
    shift @SLP_CONF_ATTR_ARR;
    my $SLP_CONF_ATTR_VALUE_NEW = join("=",@SLP_CONF_ATTR_ARR);
    $SLP_CONF_ATTR_VALUE_NEW=~ s/^\s+//;;
    chomp $SLP_CONF_ATTR_VALUE_NEW;
    return $SLP_CONF_ATTR_VALUE_NEW;
}


sub GetNssAdminName
{
     my @NSS_ADMIN_NAME_FROM_DATA = split(' ',$_[0]);
     chomp @NSS_ADMIN_NAME_FROM_DATA;
     print $OUTPUT "\nNSS_ADMIN_NAME_FROM_DATA  @NSS_ADMIN_NAME_FROM_DATA \n";
     my $NSS_ADMIN_NAME_FROM_DATA_VALUE = pop @NSS_ADMIN_NAME_FROM_DATA;
     my @NSS_ADMIN_NAME_INI = split('\.',$NSS_ADMIN_NAME_FROM_DATA_VALUE);
     chomp @NSS_ADMIN_NAME_INI;
     pop @NSS_ADMIN_NAME_INI;
     shift @NSS_ADMIN_NAME_INI;
     my $CONFIG_NSS_ADMIN_NAME_NEW = join('.',@NSS_ADMIN_NAME_INI);
     chomp $CONFIG_NSS_ADMIN_NAME_NEW;
     return $CONFIG_NSS_ADMIN_NAME_NEW;
}


#This function will read the configuration stored outside the sysconfig file and returns the sysconfig attribute value
sub outside_configuration
{
    # Get the CONFIG_AFP_EDIR_CONTEXTS and CONFIG_CIFS_EDIR_CONTEXTS value from outside the sysconfig files
    if ($_ eq 'CONFIG_AFP_EDIR_CONTEXTS' || $_ eq 'CONFIG_CIFS_EDIR_CONTEXTS')
    {
        my @CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_ARR; # Hold the lines you want
        my $file;
        my $CHANGE_VALUE_PATH_NAME; # path where attributes value stored outside
        if ($_ eq 'CONFIG_AFP_EDIR_CONTEXTS')
        {
           $CHANGE_VALUE_PATH_NAME='/etc/opt/novell/afptcpd/afpdircxt.conf';
           open ($file, '<', $CHANGE_VALUE_PATH_NAME) || die "File not found"; # Open the file for reading
        }
        elsif ($_ eq 'CONFIG_CIFS_EDIR_CONTEXTS')
        {
           $CHANGE_VALUE_PATH_NAME='/etc/opt/novell/cifs/cifsctxs.conf';
           open ($file, '<', $CHANGE_VALUE_PATH_NAME) || die "File not found";
        }
        while (my $line = <$file>)
        {
           next if $line =~ m/^#/; # Look at each line and if isn't a comment
           push (@CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_ARR, $line);
        }
        close $file;
        chomp @CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_ARR;
        my $CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_NEW=join('#',@CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_ARR); # Join multiple values with the symbol '#'
        chomp $CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_NEW;
        my @CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_NEW_ARR=($CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_NEW,$CHANGE_VALUE_PATH_NAME);
        return @CONFIG_AFP_OR_CIFS_EDIR_CONTEXTS_NEW_ARR; # return the value and path
    }
    # Get the CONFIG_AFP_PROXY_USER and CONFIG_CIFS_PROXY_USER value from outside the sysconfig files
    elsif ($_ eq 'CONFIG_AFP_PROXY_USER' || $_ eq 'CONFIG_CIFS_PROXY_USER' || $_ eq 'CONFIG_LUM_PROXY_USER' || $_ eq 'CONFIG_DHCPSRV_LDAP_USER_CONTEXT' || $_ eq 'CONFIG_NCS_PROXY_USER' || $_ eq 'CONFIG_LDAP_PROXY_CONTEXT' || $_ eq 'CONFIG_XTIER_PROXY_CONTEXT')
    { 
       my %PROXY_USER_VALUE_FILE=('CONFIG_AFP_PROXY_USER' => '/opt/novell/afptcpd/bin/afp_retrieve_proxy_cred.sh', 'CONFIG_CIFS_PROXY_USER' => '/opt/novell/cifs/bin/cifs_retrieve_proxy_cred.sh', 'CONFIG_LUM_PROXY_USER' => '/usr/bin/lum_retrieve_proxy_cred', 'CONFIG_DHCPSRV_LDAP_USER_CONTEXT' => '/opt/novell/dhcp/bin/dhcp_retrieve_proxy_cred', 'CONFIG_NCS_PROXY_USER' => '/opt/novell/ncs/bin/ncs_retrieve_proxy_cred', 'CONFIG_LDAP_PROXY_CONTEXT' => '/opt/novell/proxymgmt/bin/cp_retrieve_proxy_cred', 'CONFIG_XTIER_PROXY_CONTEXT' => '/opt/novell/netstorage/bin/ns_retrieve_proxy_cred');
       my $CHANGE_VALUE_PATH_NAME=$PROXY_USER_VALUE_FILE{$_}; # path where attributes value stored outside

       my $TEMP_PATH="/tmp/username_temp";       
       if(-e $CHANGE_VALUE_PATH_NAME)
       {
          if($_ eq 'CONFIG_LDAP_PROXY_CONTEXT')
          {
             `$CHANGE_VALUE_PATH_NAME username > $TEMP_PATH`;
          }
          else
          { 
             `$CHANGE_VALUE_PATH_NAME username $TEMP_PATH`;
          }
          my $CONFIG_PROXY_USER_VALUE_NEW;
          if(-e $TEMP_PATH)
          { 
	     `perl -pi -e 's/\\./,/g' $TEMP_PATH`;
             $CONFIG_PROXY_USER_VALUE_NEW = `cat $TEMP_PATH` ;
             chomp $CONFIG_PROXY_USER_VALUE_NEW;
             `rm /tmp/username_temp`; #delete temp file
          }
          else
          {
            $CONFIG_PROXY_USER_VALUE_NEW="";
          }    
          my @CONFIG_PROXY_USER_VALUE_NEW_ARR=($CONFIG_PROXY_USER_VALUE_NEW,$CHANGE_VALUE_PATH_NAME);
          print $OUTPUT "New Value for $_ : $CHANGE_VALUE_PATH_NAME -> $CONFIG_PROXY_USER_VALUE_NEW \n";
          return @CONFIG_PROXY_USER_VALUE_NEW_ARR;
       }
       else
       {
          print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          return;
       }
    }
	elsif($_ eq 'CONFIG_AFP_SUBTREE_SEARCH' ) 
	{
		my $CHANGE_VALUE_PATH_NAME = "/etc/opt/novell/afptcpd/afptcpd.conf";
		if ( -e $CHANGE_VALUE_PATH_NAME)
		{
		my %AFP_CONF_ATTR=('SUBTREE_SEARCH' => 'CONFIG_AFP_SUBTREE_SEARCH');
		my $SUBTREE_SEARCH_ATTR=`grep -r SUBTREE_SEARCH $CHANGE_VALUE_PATH_NAME |grep -v ^#`;
		my @SUBTREE_SEARCH_ATTR_ARR= split(' ',$SUBTREE_SEARCH_ATTR);
		my $SUBTREE_SEARCH_ATTR_NEW = $SUBTREE_SEARCH_ATTR_ARR[1];
		chomp $SUBTREE_SEARCH_ATTR_NEW;
		my @SUBTREE_SEARCH_ATTR_NEW_ARR=($SUBTREE_SEARCH_ATTR_NEW,$CHANGE_VALUE_PATH_NAME);
		print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $SUBTREE_SEARCH_ATTR_NEW\n";
		return @SUBTREE_SEARCH_ATTR_NEW_ARR;
		}
       else
       {
          print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          return;
       }
	}
	elsif($_ eq 'CONFIG_CIFS_SUBTREE_SEARCH' ) 
	{
		my $CHANGE_VALUE_PATH_NAME = "/etc/opt/novell/cifs/cifs.conf";
		if ( -e $CHANGE_VALUE_PATH_NAME)
		{
		my %AFP_CONF_ATTR=('-SUBTREE' => 'CONFIG_CIFS_SUBTREE_SEARCH');
		my $SUBTREE_SEARCH_ATTR=`grep -r SUBTREE $CHANGE_VALUE_PATH_NAME |grep -v ^#`;
		my @SUBTREE_SEARCH_ATTR_ARR= split(' ',$SUBTREE_SEARCH_ATTR);
		my $SUBTREE_SEARCH_ATTR_NEW = $SUBTREE_SEARCH_ATTR_ARR[1];
		chomp $SUBTREE_SEARCH_ATTR_NEW;
		my @SUBTREE_SEARCH_ATTR_NEW_ARR=($SUBTREE_SEARCH_ATTR_NEW,$CHANGE_VALUE_PATH_NAME);
		print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $SUBTREE_SEARCH_ATTR_NEW\n";
		return @SUBTREE_SEARCH_ATTR_NEW_ARR;
		}
       else
       {
          print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          return;
       }
	}

    elsif ($_ eq 'CONFIG_LUM_LDAP_SERVER' || $_ eq 'CONFIG_LUM_PARTITION_ROOT' || $_ eq 'CONFIG_LUM_WS_CONTEXT' || $_ eq 'CONFIG_LUM_RESTRICT_ACCESS')
    {
       my $CHANGE_VALUE_PATH_NAME='/etc/nam.conf'; # path where LUM attributes value stored outside
       my %LUM_CONF_ATTR=('preferred-server' => 'CONFIG_LUM_LDAP_SERVER', 'base-name' => 'CONFIG_LUM_PARTITION_ROOT' , 'workstation-context' => 'CONFIG_LUM_WS_CONTEXT' , 'umask' => 'CONFIG_LUM_RESTRICT_ACCESS');
       my $NAM_CONF_ATTR_VALUE_NEW;
       if(-e $CHANGE_VALUE_PATH_NAME)
       {
          while ((my $key, my $value) = each %LUM_CONF_ATTR)
          {
             if ($_ eq $LUM_CONF_ATTR{$key})
             {
                my $NAM_CONF_ATTR = `grep -r $key $CHANGE_VALUE_PATH_NAME`;
                my @NAM_CONF_ATTR_ARR = split('=',$NAM_CONF_ATTR);
                shift @NAM_CONF_ATTR_ARR;
                $NAM_CONF_ATTR_VALUE_NEW = join("=",@NAM_CONF_ATTR_ARR);
                chomp $NAM_CONF_ATTR_VALUE_NEW;
             }
          }
          my @NAM_CONF_ATTR_VALUE_NEW_ARR=($NAM_CONF_ATTR_VALUE_NEW,$CHANGE_VALUE_PATH_NAME);
          print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $NAM_CONF_ATTR_VALUE_NEW \n";
          return @NAM_CONF_ATTR_VALUE_NEW_ARR;
       }
       else
       {
          print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          return ;
       }
    }
    elsif ($_ eq 'CONFIG_EDIR_SERVER_CONTEXT' || $_ eq 'CONFIG_EDIR_HTTP_PORT' || $_ eq 'CONFIG_EDIR_HTTPS_PORT')
    {
       my $CHANGE_VALUE_PATH_NAME='/etc/opt/novell/eDirectory/conf/nds.conf'; # path where EDIR attributes value stored outside
       my %EDIR_CONF_ATTR=('n4u.nds.server-context' => 'CONFIG_EDIR_SERVER_CONTEXT', 'http.server.clear-port' => 'CONFIG_EDIR_HTTP_PORT' , 'http.server.tls-port' => 'CONFIG_EDIR_HTTPS_PORT');
       my $NDS_CONF_ATTR_VALUE_NEW;
       if(-e $CHANGE_VALUE_PATH_NAME)
       {
          while ((my $key, my $value) = each %EDIR_CONF_ATTR)
          {
             if ($_ eq $EDIR_CONF_ATTR{$key})
             {
                my $NDS_CONF_ATTR = `grep -r $key $CHANGE_VALUE_PATH_NAME`;
                my @NDS_CONF_ATTR_ARR = split('=',$NDS_CONF_ATTR);
                shift @NDS_CONF_ATTR_ARR;
                $NDS_CONF_ATTR_VALUE_NEW = join("=",@NDS_CONF_ATTR_ARR);
                chomp $NDS_CONF_ATTR_VALUE_NEW;
             }
         }
         my @NDS_CONF_ATTR_VALUE_NEW_ARR=($NDS_CONF_ATTR_VALUE_NEW,$CHANGE_VALUE_PATH_NAME);
         print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $NDS_CONF_ATTR_VALUE_NEW \n";
         return @NDS_CONF_ATTR_VALUE_NEW_ARR;
      }
      else
      {
          print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
          return ;
      }
    }
    elsif ($_ eq 'CONFIG_EDIR_SLP_SCOPES' || $_ eq 'CONFIG_EDIR_SLP_DA' || $_ eq 'CONFIG_EDIR_SLP_MODE' || $_ eq 'CONFIG_EDIR_DASYNC' || $_ eq 'CONFIG_EDIR_SLP_BACKUP' || $_ eq 'CONFIG_EDIR_SLP_BACKUP_INTERVAL')
    {
       my $CHANGE_VALUE_PATH_NAME='/etc/slp.conf'; # path where SLP attributes value stored outside
       my %EDIR_CONF_ATTR2=('CONFIG_EDIR_SLP_SCOPES' => 'net.slp.useScopes', 'CONFIG_EDIR_SLP_DA' => 'net.slp.DAAddresses', 'CONFIG_EDIR_SLP_MODE' => 'net.slp.isDA', 'CONFIG_EDIR_DASYNC' => 'net.slp.dasyncreg', 'CONFIG_EDIR_SLP_BACKUP' => 'net.slp.isdabackup', 'CONFIG_EDIR_SLP_BACKUP_INTERVAL' => 'net.slp.dabackupinterval');
       my $SLP_CONF_ATTR_VALUE_NEW;
       if(-e $CHANGE_VALUE_PATH_NAME)
       {
         my $SLP_CONF_CONFIG_EDIR_SLP_MODE_NEW=SlpEdir($EDIR_CONF_ATTR2{'CONFIG_EDIR_SLP_MODE'},$CHANGE_VALUE_PATH_NAME);
         my $SLP_CONF_CONFIG_EDIR_DASYNC_NEW=SlpEdir($EDIR_CONF_ATTR2{'CONFIG_EDIR_DASYNC'},$CHANGE_VALUE_PATH_NAME);
         my $SLP_CONF_CONFIG_EDIR_SLP_BACKUP_NEW=SlpEdir($EDIR_CONF_ATTR2{'CONFIG_EDIR_SLP_BACKUP'},$CHANGE_VALUE_PATH_NAME);
         my $SLP_CONF_CONFIG_EDIR_SLP_BACKUP_INTERVAL_NEW=SlpEdir($EDIR_CONF_ATTR2{'CONFIG_EDIR_SLP_BACKUP_INTERVAL'},$CHANGE_VALUE_PATH_NAME);
         my $SLP_CONF_CONFIG_EDIR_SLP_SCOPES_NEW=SlpEdir($EDIR_CONF_ATTR2{'CONFIG_EDIR_SLP_SCOPES'},$CHANGE_VALUE_PATH_NAME);
         my $SLP_CONF_CONFIG_EDIR_SLP_DA_NEW=SlpEdir($EDIR_CONF_ATTR2{'CONFIG_EDIR_SLP_DA'},$CHANGE_VALUE_PATH_NAME);
         if ($_ eq 'CONFIG_EDIR_SLP_MODE')
         {
            if($SLP_CONF_CONFIG_EDIR_SLP_MODE_NEW eq '' && $SLP_CONF_CONFIG_EDIR_DASYNC_NEW eq '' && $SLP_CONF_CONFIG_EDIR_SLP_BACKUP_NEW eq '' && $SLP_CONF_CONFIG_EDIR_SLP_BACKUP_INTERVAL_NEW eq '' && $SLP_CONF_CONFIG_EDIR_SLP_SCOPES_NEW eq '' && $SLP_CONF_CONFIG_EDIR_SLP_DA_NEW eq '') 
            {
                $SLP_CONF_ATTR_VALUE_NEW='multicast';
            }          
            elsif($SLP_CONF_CONFIG_EDIR_SLP_MODE_NEW eq 'true')
            {
                $SLP_CONF_ATTR_VALUE_NEW='da_server';
            }
            else
            {
                $SLP_CONF_ATTR_VALUE_NEW='da';
            }
        }
        elsif ($_ eq 'CONFIG_EDIR_DASYNC')
        {
           if($SLP_CONF_CONFIG_EDIR_DASYNC_NEW eq 'true')
           {
               $SLP_CONF_ATTR_VALUE_NEW='yes';
           }
           else
           {
               $SLP_CONF_ATTR_VALUE_NEW='no';
           }
        }
        elsif ($_ eq 'CONFIG_EDIR_SLP_BACKUP')
        {
           if($SLP_CONF_CONFIG_EDIR_SLP_BACKUP_NEW eq 'false')
           {
               $SLP_CONF_ATTR_VALUE_NEW='no';
           }
           else
           {
              $SLP_CONF_ATTR_VALUE_NEW='yes';
           }
        }
        elsif($_ eq 'CONFIG_EDIR_SLP_SCOPES')
        {
            if($SLP_CONF_CONFIG_EDIR_SLP_SCOPES_NEW)
            {
                $SLP_CONF_ATTR_VALUE_NEW=$SLP_CONF_CONFIG_EDIR_SLP_SCOPES_NEW;
            }
            else
            {
               $SLP_CONF_ATTR_VALUE_NEW='DEFAULT';
            }
        }
        elsif($_ eq 'CONFIG_EDIR_SLP_DA')
        {
           if($SLP_CONF_CONFIG_EDIR_SLP_DA_NEW)
           {
              $SLP_CONF_ATTR_VALUE_NEW=$SLP_CONF_CONFIG_EDIR_SLP_DA_NEW;
           }
           else
           {
              $SLP_CONF_ATTR_VALUE_NEW='';
           }
        }
        elsif($_ eq 'CONFIG_EDIR_SLP_BACKUP_INTERVAL')
        {
           if($SLP_CONF_CONFIG_EDIR_SLP_BACKUP_INTERVAL_NEW)
           {
              $SLP_CONF_ATTR_VALUE_NEW=$SLP_CONF_CONFIG_EDIR_SLP_BACKUP_INTERVAL_NEW;
           }
           else
           {
              $SLP_CONF_ATTR_VALUE_NEW='900';
           }
        }
        my @SLP_CONF_ATTR_VALUE_NEW_ARR=($SLP_CONF_ATTR_VALUE_NEW,$CHANGE_VALUE_PATH_NAME);
        print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $SLP_CONF_ATTR_VALUE_NEW \n";
        return @SLP_CONF_ATTR_VALUE_NEW_ARR;
      }
      else
      {
         print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         return ;
      }
    }
    elsif ($_ eq 'CONFIG_EDIR_NTP_SERVERS')
    {
       my $CHANGE_VALUE_PATH_NAME='/etc/ntp.conf'; # path where NTP attributes value stored outside
       my @NTP_CONFIG_EDIR_NTP_SERVERS_NEW;
       open (my $file, '<', $CHANGE_VALUE_PATH_NAME) || die "File not found";
       while (my $line = <$file>)
       {
          if ( $line =~ /^server/ )
          {
              push (@NTP_CONFIG_EDIR_NTP_SERVERS_NEW,$line);
          }
       }
       close $file;
       shift @NTP_CONFIG_EDIR_NTP_SERVERS_NEW;
       my @NTP_CONF_ATTR_ARR;
       foreach(@NTP_CONFIG_EDIR_NTP_SERVERS_NEW)
       {
          my @NTP_CONF_ATTR_ARR_INI = split(' ',$_);
          my $NTP_CONF_ATTR_VALUE_INI = @NTP_CONF_ATTR_ARR_INI[1];
          chomp $NTP_CONF_ATTR_VALUE_INI;
          push(@NTP_CONF_ATTR_ARR,$NTP_CONF_ATTR_VALUE_INI);
       }
       my $NTP_CONF_ATTR_VALUE = join(',',@NTP_CONF_ATTR_ARR);
       chomp $NTP_CONF_ATTR_VALUE;
       my @NTP_CONF_ATTR_VALUE_ARR=($NTP_CONF_ATTR_VALUE,$CHANGE_VALUE_PATH_NAME);
        print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $NTP_CONF_ATTR_VALUE \n";
       return @NTP_CONF_ATTR_VALUE_ARR;
    }
    elsif ($_ eq 'CONFIG_IPRINT_TOP_CONTEXT')
    {
        my $CHANGE_VALUE_PATH_NAME='/etc/opt/novell/iprint/httpd/conf/iprint_ssl.conf'; # path where IPRINT attributes value stored outside
        if(-e $CHANGE_VALUE_PATH_NAME)
        {
           my $AUTHLDAPURL = `grep -r AuthLDAPDNURL $CHANGE_VALUE_PATH_NAME`;
           my @AUTHLDAPURL_ARR = split('/',$AUTHLDAPURL);
           my $AUTHLDAPURL_VALUE = pop @AUTHLDAPURL_ARR;
           my @CONFIG_IPRINT_TOP_CONTEXT_ARR = split('\?',$AUTHLDAPURL_VALUE);
           my $CONFIG_IPRINT_TOP_CONTEXT_NEW = shift @CONFIG_IPRINT_TOP_CONTEXT_ARR;
           chomp $CONFIG_IPRINT_TOP_CONTEXT_NEW;
           my @CONFIG_IPRINT_TOP_CONTEXT_NEW_ARR=($CONFIG_IPRINT_TOP_CONTEXT_NEW,$CHANGE_VALUE_PATH_NAME);
           print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $CONFIG_IPRINT_TOP_CONTEXT_NEW \n";
           return @CONFIG_IPRINT_TOP_CONTEXT_NEW_ARR;
       }
       else
       {
         print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         return ;
       }
    }
    elsif ($_ eq 'CONFIG_IPRINT_LDAP_SERVER')
    {
        my $CHANGE_VALUE_PATH_NAME='/etc/opt/novell/iprint/httpd/conf/iprint_g.conf'; # path where IPRINT attributes value stored outside
        if(-e $CHANGE_VALUE_PATH_NAME)
        {
           my @SERVER_NAME_ARR = `grep -r ServerName $CHANGE_VALUE_PATH_NAME`;
           my $SERVER_NAME_STRING = pop @SERVER_NAME_ARR;
           chomp $SERVER_NAME_STRING;
           my @SERVER_NAME_STRING_ARR = split(' ',$SERVER_NAME_STRING);
           my $SERVER_NAME_VALUE = pop @SERVER_NAME_STRING_ARR;
           my @CONFIG_IPRINT_LDAP_SERVER_ARR = split(':',$SERVER_NAME_VALUE);
           my $CONFIG_IPRINT_LDAP_SERVER_NEW = shift @CONFIG_IPRINT_LDAP_SERVER_ARR;
           chomp $CONFIG_IPRINT_LDAP_SERVER_NEW;
           my @CONFIG_IPRINT_LDAP_SERVER_NEW_ARR=($CONFIG_IPRINT_LDAP_SERVER_NEW,$CHANGE_VALUE_PATH_NAME);
           print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $CONFIG_IPRINT_LDAP_SERVER_NEW \n";
           return @CONFIG_IPRINT_LDAP_SERVER_NEW_ARR;
       }
       else
       {
         print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         return ;
       }
    }
    elsif ($_ eq 'CONFIG_DHCPSRV_LDAP_SERVER' || $_ eq 'CONFIG_DHCPSRV_SERVER_CONTEXT' || $_ eq 'CONFIG_DHCPSRV_SERVER_OBJECT_NAME')
    {
        my $CHANGE_VALUE_PATH_NAME='/etc/dhcpd.conf'; # path where DHCP attributes value stored outside
        my %DHCP_CONF_ATTR=('ldap-server' => 'CONFIG_DHCPSRV_LDAP_SERVER', 'ldap-base-dn' => 'CONFIG_DHCPSRV_SERVER_CONTEXT' , 'ldap-dhcp-server-cn' => 'CONFIG_DHCPSRV_SERVER_OBJECT_NAME');
        my $DHCP_CONF_ATTR_VALUE_NEW;
        if(-e $CHANGE_VALUE_PATH_NAME)
        {
           while ((my $key, my $value) = each %DHCP_CONF_ATTR)
           {
              if ($_ eq $DHCP_CONF_ATTR{$key})
              {
                  my $DHCP_CONF_ATTR_VALUES = `grep -r $key $CHANGE_VALUE_PATH_NAME`;
                  my @DHCP_CONF_ATTR_ARR = split(' ',$DHCP_CONF_ATTR_VALUES);
                  my $DHCP_CONF_ATTR_VALUE = pop @DHCP_CONF_ATTR_ARR;
                  my @DHCP_CONF_ATTR_ARR_NEW = split('"',$DHCP_CONF_ATTR_VALUE);
                  $DHCP_CONF_ATTR_VALUE_NEW = $DHCP_CONF_ATTR_ARR_NEW[1];
                  chomp $DHCP_CONF_ATTR_VALUE_NEW;
             }
          }
          my @DHCP_CONF_ATTR_VALUE_NEW_ARR=($DHCP_CONF_ATTR_VALUE_NEW,$CHANGE_VALUE_PATH_NAME);
           print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $DHCP_CONF_ATTR_VALUE_NEW \n";
          return @DHCP_CONF_ATTR_VALUE_NEW_ARR;
       }
       else
       {
          print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         return ;
       }
    }
    elsif ($_ eq 'CONFIG_IFOLDER_LDAP_SERVER' || $_ eq 'CONFIG_IFOLDER_SERVER_NAME' || $_ eq 'CONFIG_IFOLDER_PUBLIC_URL' || $_ eq 'CONFIG_IFOLDER_PRIVATE_URL' || $_ eq 'CONFIG_IFOLDER_SYSTEM_ADMIN_CONTEXT' || $_ eq 'CONFIG_IFOLDER_LDAP_PROXY_USER_CONTEXT' || $_ eq 'CONFIG_IFOLDER_LDAP_SEARCH_CONTEXTS' || $_ eq 'CONFIG_IFOLDER_NAMING_ATTRIBUTE')
    {
        my $CHANGE_VALUE_PATH_NAME='/var/simias/data/simias/Simias.config'; # path where ifolder attributes value stored outside
        my %IFOLDER_CONF_ATTR=('LdapUri' => 'CONFIG_IFOLDER_LDAP_SERVER', 'name="Name"' => 'CONFIG_IFOLDER_SERVER_NAME', 'PublicAddress' => 'CONFIG_IFOLDER_PUBLIC_URL', 'PrivateAddress' => 'CONFIG_IFOLDER_PRIVATE_URL', 'AdminName' => 'CONFIG_IFOLDER_SYSTEM_ADMIN_CONTEXT', 'ProxyDN' => 'CONFIG_IFOLDER_LDAP_PROXY_USER_CONTEXT', 'Context dn' => 'CONFIG_IFOLDER_LDAP_SEARCH_CONTEXTS', 'NamingAttribute' => 'CONFIG_IFOLDER_NAMING_ATTRIBUTE');
        my $IFOLDER_CONF_ATTR_VALUE_NEW;
        if(-e $CHANGE_VALUE_PATH_NAME)
        {
           while ((my $key, my $value) = each %IFOLDER_CONF_ATTR)
           {
               if ($_ eq $IFOLDER_CONF_ATTR{$key})
               {
                   my $IFOLDER_CONF_ATTR_VALUES = `grep -r '$key' $CHANGE_VALUE_PATH_NAME`;
                   my @IFOLDER_CONF_ATTR_ARR = split(' ',$IFOLDER_CONF_ATTR_VALUES);
                   chomp @IFOLDER_CONF_ATTR_ARR;
                   pop @IFOLDER_CONF_ATTR_ARR;
                   my $IFOLDER_CONF_ATTR_VALUE = pop @IFOLDER_CONF_ATTR_ARR; 
                   my @IFOLDER_CONF_ATTR_ARR_NEW = split('=',$IFOLDER_CONF_ATTR_VALUE);
                   shift @IFOLDER_CONF_ATTR_ARR_NEW;
                   my $IFOLDER_CONF_ATTR_VALUE_QUOTE=join('=',@IFOLDER_CONF_ATTR_ARR_NEW);
                   chomp $IFOLDER_CONF_ATTR_VALUE_QUOTE;
                   my @IFOLDER_CONF_ATTR_ARR_QUOTE = split('"',$IFOLDER_CONF_ATTR_VALUE_QUOTE);
                   $IFOLDER_CONF_ATTR_VALUE_NEW = $IFOLDER_CONF_ATTR_ARR_QUOTE[1];
                   chomp $IFOLDER_CONF_ATTR_VALUE_NEW;
                   if ($_ eq 'CONFIG_IFOLDER_LDAP_SERVER' || $_ eq 'CONFIG_IFOLDER_PUBLIC_URL' || $_ eq 'CONFIG_IFOLDER_PRIVATE_URL')
                   {
                       my @IFOLDER_CONF_ATTR_VALUE_NEW_SLASH=split('/',$IFOLDER_CONF_ATTR_VALUE_NEW);
                       my @IFOLDER_CONF_ATTR_VALUE_NEW_COL=split(':',@IFOLDER_CONF_ATTR_VALUE_NEW_SLASH[2]);
                       $IFOLDER_CONF_ATTR_VALUE_NEW=@IFOLDER_CONF_ATTR_VALUE_NEW_COL[0];
                       chomp $IFOLDER_CONF_ATTR_VALUE_NEW;
                   }
              }
           }
           my @IFOLDER_CONF_ATTR_VALUE_NEW_ARR=($IFOLDER_CONF_ATTR_VALUE_NEW,$CHANGE_VALUE_PATH_NAME);
           print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $IFOLDER_CONF_ATTR_VALUE_NEW \n";
           return @IFOLDER_CONF_ATTR_VALUE_NEW_ARR;
       }
       else
       {
          print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         return ;
       }
    }
    elsif ($_ eq 'CONFIG_NCS_LDAP_SERVER')
    {
        my $CHANGE_VALUE_PATH_NAME='/etc/opt/novell/ncs/clstrlib.conf'; # path where NCS attributes value stored outside
        if(-e $CHANGE_VALUE_PATH_NAME)
        {
            my $LDAPURL = `grep -r ldaps $CHANGE_VALUE_PATH_NAME`;
            my @LDAPURL_ARR = split('\'',$LDAPURL);
            my @CONFIG_NCS_LDAP_SERVER_VALUE = split('/',@LDAPURL_ARR[1]);
            my @CONFIG_NCS_LDAP_SERVER_VALUE = split(':',@CONFIG_NCS_LDAP_SERVER_VALUE[2]);
            my $CONFIG_NCS_LDAP_SERVER_NEW = shift @CONFIG_NCS_LDAP_SERVER_VALUE;
            chomp $CONFIG_NCS_LDAP_SERVER_NEW;
            my @CONFIG_NCS_LDAP_SERVER_NEW_ARR=($CONFIG_NCS_LDAP_SERVER_NEW,$CHANGE_VALUE_PATH_NAME);
           print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $CONFIG_NCS_LDAP_SERVER_NEW \n";
            return @CONFIG_NCS_LDAP_SERVER_NEW_ARR;
       }
       else
       {
          print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         return ;
       }
    }
    elsif ($_ eq 'CONFIG_NSS_NSSADMIN_DN')
    {
         my $CHANGE_VALUE_PATH_NAME;
         my $NSS_ADMIN_DATA;
         my $NSS_ADMIN_INSTALL_BIN="$NSS_ADMIN_INSTALL_BIN_PATH/nssAdminInstall";
         my $TEMP1_PATH="/tmp/temp1";
         if(-e "$NSS_ADMIN_INSTALL_BIN")
         {
             $NSS_ADMIN_DATA=`"$NSS_ADMIN_INSTALL_BIN" --get-nssadmin-name`;
             $CHANGE_VALUE_PATH_NAME = "$NSS_ADMIN_INSTALL_BIN";
             my $CONFIG_NSS_ADMIN_NAME_NEW=GetNssAdminName($NSS_ADMIN_DATA);
             my @CONFIG_NSS_ADMIN_NAME_NEW_ARR=($CONFIG_NSS_ADMIN_NAME_NEW,$CHANGE_VALUE_PATH_NAME);
             print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $CONFIG_NSS_ADMIN_NAME_NEW \n";
             return @CONFIG_NSS_ADMIN_NAME_NEW_ARR;
         }
         else
         {
            `nssAdminInstall --get-nssadmin-name &>$TEMP1_PATH`;
            if ($? != 0)
            {
                print $OUTPUT "\n Unable to retrive the value : nssAdminInstall : Couldn't find attribute value for $_ \n";
                print " Unable to retrive the value. Utility to retrive nss admin name is not available in the installed rpm. Please copy the attached 'nssAdminInstall' library to current working dir and reexecute this script : Couldn't find attribute value for $_ \n";
                return ; 
            }
            else
            {
                 $NSS_ADMIN_DATA=`nssAdminInstall --get-nssadmin-name`;
                 $CHANGE_VALUE_PATH_NAME = `which nssAdminInstall`;
                 my $CONFIG_NSS_ADMIN_NAME_NEW = GetNssAdminName($NSS_ADMIN_DATA);
                 my @CONFIG_NSS_ADMIN_NAME_NEW_ARR=($CONFIG_NSS_ADMIN_NAME_NEW,$CHANGE_VALUE_PATH_NAME);
                 print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $CONFIG_NSS_ADMIN_NAME_NEW \n";
                 return @CONFIG_NSS_ADMIN_NAME_NEW_ARR;
            }
         }
    }
    elsif ($_ eq 'CONFIG_EDIR_REPLICA_SERVER')
    {
         my $TEMP1_PATH="/tmp/temp1";
         `ndsconfig get > $TEMP1_PATH`;
         my $CONFIG_EDIR_REPLICA_SERVER_VALUE=`grep -r n4u.nds.server-name $TEMP1_PATH`;
         my @CONFIG_EDIR_REPLICA_SERVER_VALUE_NAME_ARRAY=split('=',$CONFIG_EDIR_REPLICA_SERVER_VALUE);
         my $CONFIG_EDIR_REPLICA_SERVER_VALUE_NAME = pop @CONFIG_EDIR_REPLICA_SERVER_VALUE_NAME_ARRAY;
         my @CONFIG_EDIR_REPLICA_SERVER_VALUE = split('\(',`ping -c 3 $CONFIG_EDIR_REPLICA_SERVER_VALUE_NAME`);
         shift @CONFIG_EDIR_REPLICA_SERVER_VALUE;
         my @CONFIG_EDIR_REPLICA_SERVER_VALUE_NEW_ARR=split('\)',shift @CONFIG_EDIR_REPLICA_SERVER_VALUE);
         my $CONFIG_EDIR_REPLICA_SERVER_VALUE_NEW = shift @CONFIG_EDIR_REPLICA_SERVER_VALUE_NEW_ARR;
         `rm -f $TEMP1_PATH`;
         my $CHANGE_VALUE_PATH_NAME = `which ndsconfig`;
         my @CONFIG_EDIR_REPLICA_SERVER_NEW_ARR=($CONFIG_EDIR_REPLICA_SERVER_VALUE_NEW,$CHANGE_VALUE_PATH_NAME);
         print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> $CONFIG_EDIR_REPLICA_SERVER_VALUE_NEW \n";
         return @CONFIG_EDIR_REPLICA_SERVER_NEW_ARR;
    }
    elsif ($_ eq 'XAD_CONFIG_DNS')
    {
         my $CHANGE_VALUE_PATH_NAME='/etc/opt/novell/xad/xad.ini'; # path where IPRINT attributes value stored outside
         if(-e $CHANGE_VALUE_PATH_NAME)
         {
		my @XAD_CONFIG_DNS_ATTR = `grep -r "DNS Master"  $CHANGE_VALUE_PATH_NAME`;
         	my $XAD_CONFIG_DNS_STRING = pop @XAD_CONFIG_DNS_ATTR;
         	chomp $XAD_CONFIG_DNS_STRING;
         	my @XAD_CONFIG_DNS_TEMP = split(' ',$XAD_CONFIG_DNS_STRING);
         	my $XAD_CONFIG_DNS_VALUE = pop @XAD_CONFIG_DNS_TEMP;
           	chomp $XAD_CONFIG_DNS_VALUE;
			if( $XAD_CONFIG_DNS_VALUE eq 'TRUE' )
			{
				my $XAD_CONFIG_DNS_VALUE="yes";
				chomp $XAD_CONFIG_DNS_VALUE;
				my @XAD_CONFIG_DNS_VALUE_ARR=($XAD_CONFIG_DNS_VALUE,$CHANGE_VALUE_PATH_NAME);
				print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> @XAD_CONFIG_DNS_VALUE_ARR \n";
				return @XAD_CONFIG_DNS_VALUE_ARR;
			}
			elsif( $XAD_CONFIG_DNS_VALUE eq 'FALSE')
			{
				my $XAD_CONFIG_DNS_VALUE="no";
				chomp $XAD_CONFIG_DNS_VALUE;
				my @XAD_CONFIG_DNS_VALUE_ARR=($XAD_CONFIG_DNS_VALUE,$CHANGE_VALUE_PATH_NAME);
           		print $OUTPUT "\nNew value for $_ : $CHANGE_VALUE_PATH_NAME -> @XAD_CONFIG_DNS_VALUE_ARR \n";
				return @XAD_CONFIG_DNS_VALUE_ARR;
			}
	}
       else
       {
         print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         return ;
       }
   }
   elsif($_ eq 'XAD_TREE_ADMIN_CONTEXT')
   {
        if ( "$EDIR_TREE_TYPE" eq "existing"  && "$XAD_CONFIGURED" eq "yes") 
		{
			my $CHANGE_VALUE_PATH_NAME='/opt/novell/xad/share/dcinit/provisionTools.sh'; # path where IPRINT attributes value stored outside
        	my $TEMP_PATH="/tmp/adminname_temp";
			if(-e $CHANGE_VALUE_PATH_NAME)
        	{
            	`$CHANGE_VALUE_PATH_NAME get-admin-name > $TEMP_PATH`;
				my $XAD_TREE_ADMIN_VALUE_NEW;
		        if(-e $TEMP_PATH)
          		{
             		$XAD_TREE_ADMIN_VALUE_NEW = `cat $TEMP_PATH` ;
             		chomp $XAD_TREE_ADMIN_VALUE_NEW;
             		`rm /tmp/adminname_temp`; #delete temp file
          		}
          		else
          		{
            		$XAD_TREE_ADMIN_VALUE_NEW="";
          		}
          		my @XAD_TREE_ADMIN_VALUE_NEW_ARR=($XAD_TREE_ADMIN_VALUE_NEW,$CHANGE_VALUE_PATH_NAME);
	          	print $OUTPUT "New Value for $_ : $CHANGE_VALUE_PATH_NAME -> $XAD_TREE_ADMIN_VALUE_NEW \n";
          		return @XAD_TREE_ADMIN_VALUE_NEW_ARR;
        	}
			else
        	{
		        print $OUTPUT "\n File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         		print " File not found : $CHANGE_VALUE_PATH_NAME : Couldn't find attribute value for $_ \n";
         		return ;
       		}
    	}
  	}
}


#Function to find out value of service attributes inside the sysconfig files 
sub FindValueInSysconfigFile
{
    my $SYSCONFIG_ATTR_NAME=$_[0];
    my $SYSCONFIG_FILE_NAME=$_[1]; 
    my $SYSCONF_ATTR_INI=`grep -r $SYSCONFIG_ATTR_NAME $PATH_SYSCONFIG/$SYSCONFIG_FILE_NAME| grep -v \^\#`;
    my @SYSCONF_ATTR_ARR = split('=',$SYSCONF_ATTR_INI);
    shift @SYSCONF_ATTR_ARR;
    chomp @SYSCONF_ATTR_ARR;
    my $SYSCONF_ATTR_VALUE_INI = join('=',@SYSCONF_ATTR_ARR);
    my @SYSCONF_ATTR_VALUE_STRIP_DQUOTE = split('"',$SYSCONF_ATTR_VALUE_INI);
    chomp @SYSCONF_ATTR_VALUE_STRIP_DQUOTE;
    my $SYSCONF_ATTR_VALUE = $SYSCONF_ATTR_VALUE_STRIP_DQUOTE[1];
    chomp $SYSCONF_ATTR_VALUE;
    print $OUTPUT "sysconf attribute value $SYSCONFIG_ATTR_NAME : $SYSCONFIG_FILE_NAME -> $SYSCONF_ATTR_VALUE \n";
    return $SYSCONF_ATTR_VALUE;
}


#Function to read service attributes value inside as well as outside of sysconfig
sub read_sysconf_files
{
   my $SYSCONFIG_FILE_NAME = $_;
   my @SYSCONF_ATTR=(@{$SERVICES_WITH_OES_RELEASE{$oes_release_name}{$_}}); #attributes list for the particular service
   foreach(@SYSCONF_ATTR)
   {
       my $SYSCONF_ATTR_VALUE = FindValueInSysconfigFile($_,$SYSCONFIG_FILE_NAME); #find value for the attribute inside the sysconfig file
       chomp $SYSCONF_ATTR_VALUE;
       my @SYSCONFIG_ATTR_VALUE_NEW_ARR = outside_configuration($_); #find value for the attribute outside the sysconfig file
       my $SYSCONFIG_ATTR_VALUE_NEW;
       my $SYSCONFIG_ATTR_VALUE_NEW_FILE_NAME;
       if(@SYSCONFIG_ATTR_VALUE_NEW_ARR)
       {
          $SYSCONFIG_ATTR_VALUE_NEW=@SYSCONFIG_ATTR_VALUE_NEW_ARR[0];
          $SYSCONFIG_ATTR_VALUE_NEW_FILE_NAME=@SYSCONFIG_ATTR_VALUE_NEW_ARR[1];
          chomp $SYSCONFIG_ATTR_VALUE_NEW;
          chomp $SYSCONFIG_ATTR_VALUE_NEW_FILE_NAME;
          #if NTP has some server except local clock then SYSCONF_ATTR_VALUE_NTP_LOCAL_CLOCK should be no
          if($_ eq 'CONFIG_EDIR_NTP_SERVERS' && $SYSCONFIG_ATTR_VALUE_NEW)
          {
              my $SYSCONF_ATTR_VALUE_NTP_LOCAL_CLOCK = FindValueInSysconfigFile('CONFIG_EDIR_NTP_USE_LOCAL_CLOCK',$SYSCONFIG_FILE_NAME);
              if($SYSCONF_ATTR_VALUE_NTP_LOCAL_CLOCK eq 'yes')
              {
                  $SYSCONFIG_MODIFIED_ATTR{CONFIG_EDIR_NTP_USE_LOCAL_CLOCK}='no';
                  push(@LIST_SYSCONFIG_ATTR_EDIR,'CONFIG_EDIR_NTP_USE_LOCAL_CLOCK');
              }
          }
          print $OUTPUT "current value : $SYSCONF_ATTR_VALUE and new value : $SYSCONFIG_ATTR_VALUE_NEW \n";
          if (lc($SYSCONF_ATTR_VALUE) ne lc($SYSCONFIG_ATTR_VALUE_NEW))
          {
             $SYSCONFIG_MODIFIED_ATTR{$_}=$SYSCONFIG_ATTR_VALUE_NEW; #add modified attributes value into the hash %SYSCONFIG_MODIFIED_ATTR
             $SYSCONFIG_MODIFIED_ATTR_DISP{$_}=$SYSCONFIG_ATTR_VALUE_NEW; #add modified attributes value into the hash %SYSCONFIG_MODIFIED_ATTR_DISP (for individual service)
             push(@LIST_SYSCONFIG_FILES_WRITE,$SYSCONFIG_FILE_NAME); #List of modified sysconfig files are stored in @LIST_SYSCONFIG_FILES_WRITE
          }
          else
          {
              $SYSCONFIG_NO_CHANGE_ATTR{$_}=$SYSCONF_ATTR_VALUE; #add unmodified attributes value into the hash %SYSCONFIG_NO_CHANGE_ATTR
          }
       }
       if(%SYSCONFIG_MODIFIED_ATTR_DISP)
       {
           while ((my $key, my $value) = each %SYSCONFIG_MODIFIED_ATTR_DISP)
          {
              print $OUTPUT "\n \t  $key got changed from $SYSCONF_ATTR_VALUE ($PATH_SYSCONFIG/$SYSCONFIG_FILE_NAME)   to   $SYSCONFIG_MODIFIED_ATTR_DISP{$key} ($SYSCONFIG_ATTR_VALUE_NEW_FILE_NAME)  \n\n";
              print " \t  $key got changed from $SYSCONF_ATTR_VALUE ($PATH_SYSCONFIG/$SYSCONFIG_FILE_NAME)   to   $SYSCONFIG_MODIFIED_ATTR_DISP{$key} ($SYSCONFIG_ATTR_VALUE_NEW_FILE_NAME)  \n\n";
          }
       }
       undef %SYSCONFIG_MODIFIED_ATTR_DISP; #Clear the hash
   }
}


#Funtion to write modified attributes value to sysconfig files
sub write_diff_data_to_sysconfig
{
   my %temp_hash = map { $_, 0 } @LIST_SYSCONFIG_FILES_WRITE; #list sysconfig files whose attributes are modified
   my @LIST_SYSCONFIG_FILES_WRITE_UNIQUE = keys %temp_hash; #unique list
   foreach(@LIST_SYSCONFIG_FILES_WRITE_UNIQUE)
   {
       my $SYSCONFIG_FILE_NAME = $_;
       my @SYSCONF_ATTR=(@{$SERVICES_WITH_OES_RELEASE{$oes_release_name}{$_}});
       BackupSysconfDir($SYSCONFIG_FILE_NAME); #copy the original sysconfig file as backup
       foreach(@SYSCONF_ATTR)
       {
           while ((my $key, my $value) = each %SYSCONFIG_MODIFIED_ATTR)
           {
              if ($_ eq $key)
              { 
                  my $SYSCONF_ATTR_LINE=`grep -r ^$_ $PATH_SYSCONFIG/$SYSCONFIG_FILE_NAME`;
                  chomp $SYSCONF_ATTR_LINE;
                  `perl -pi -e 's/$SYSCONF_ATTR_LINE/$_="$SYSCONFIG_MODIFIED_ATTR{$key}"/' $PATH_SYSCONFIG/$SYSCONFIG_FILE_NAME`; #write the changed attribute value into the sysconfig file
              }
          }
      }
   }
}


# This function returns the script name
sub GetProgramName
{
    my @appdir = split(/\\/, $0);
    my @NSS_ADMIN_INSTALL_BIN_ARR = split(/\//, $0);
    pop @NSS_ADMIN_INSTALL_BIN_ARR ;
    $NSS_ADMIN_INSTALL_BIN_PATH=join('/',@NSS_ADMIN_INSTALL_BIN_ARR);
    return $appdir[$#appdir];
}

$scriptname=GetProgramName();


#This funtion display how to use the script
sub Usage 
{
     print $OUTPUT "\n\n" .
           " \t Usage: $scriptname all \n".
           " \t        $scriptname afp \n".
           " \t        $scriptname afp cifs lum ...... \n".
           "\n";
     print "\n" .
           " \t Usage: $scriptname all \n".
           " \t        $scriptname afp \n".
           " \t        $scriptname afp cifs lum ...... \n".
           "\n";
     exit(-1);
}


#Function to take backup of original sysconfig file
sub BackupSysconfDir
{
   my $backup_dir="/etc/sysconfig/.novell_backup_sysconfig";
   my $SYSCONFIG_FILE_NAME=$_;
#   my $CURRENT_TIME=`date +%F_%T`;
   my $backup_file="$SYSCONFIG_FILE_NAME-$CURRENT_TIME"; #backup file copied to backup directory with timestamp
   unless(-d $backup_dir) #create backup directory if its not exists
   {
       mkdir $backup_dir or die;
   }
   `cp -rf /etc/sysconfig/novell/$_ $backup_dir/$backup_file`;
   print $OUTPUT "\n\t Backup of $_ file stored in : $backup_dir/$backup_file  \n";
   print "\t Backup of $_ file stored in : $backup_dir/$backup_file  \n";
}


#Funtion to validate command line arguments
sub ArgValidate
{
   print $OUTPUT "\nnumArgs = $numArgs \n"; 
   if($numArgs == 0 || $numArgs > 9) # checks for no argument or exceeds the limitation
   {
       print "  Please input correct arguments \n";
       print $OUTPUT "\n  Please input correct arguments \n";
       Usage();
       exit;
   }
   elsif($numArgs > 1 &&  $numArgs <= 9)  # checks for valid arguments which is defined in the hash %SYSCONF_FILE_NAMES 
   {
      print $OUTPUT "\nCommand line args are @ARGV \n";
      foreach (@ARGV)
      {
           my $CMD_INPUT=lc($_);
           chomp $CMD_INPUT;
           if ((exists $SYSCONF_FILE_NAMES{$CMD_INPUT} ? "yes" : "no") eq "no")
           {
               if($CMD_INPUT eq 'all' || $CMD_INPUT eq 'version')   # should not pass argument all with other arguments
               {
                   print $OUTPUT "\n Do not pass argument $CMD_INPUT with other arguments \n";
                   print " Do not pass argument $CMD_INPUT with other arguments \n";
                   Usage();
                   exit;
               }
               else
               {
                   print $OUTPUT "\n $CMD_INPUT is invalid argrument \n";
                   print " $CMD_INPUT is invalid argrument \n";
                   Usage();
                   exit;
               }
          }
     }
   }  
}

# Function to add additional attributes which are added in the recent releases
sub AddMissingAttributes
{   
	if($oes_release_name eq '11.1')       
	{
	push (@LIST_SYSCONFIG_ATTR_AFP,'CONFIG_AFP_PROXY_USER');
	}
	if($oes_release_name eq '11.2' || $oes_release_name eq "2015") 
	{
		push (@LIST_SYSCONFIG_ATTR_AFP,'CONFIG_AFP_PROXY_USER','CONFIG_AFP_SUBTREE_SEARCH'); 
		push (@LIST_SYSCONFIG_ATTR_CIFS,'CONFIG_CIFS_SUBTREE_SEARCH');	
	}
}


# Funtion to copy list of sysconfig files name in an array @LIST_SYSCONFIG_FILES
sub AssignAgrList
{
   if($numArgs == 1 && lc($ARGV[0]) eq 'all') #command line argument is only one and that would be 'all'
   {
      @LIST_SYSCONFIG_FILES=sort (keys %{$SERVICES_WITH_OES_RELEASE{$oes_release_name}});
	foreach (@LIST_SYSCONFIG_FILES)
	{
		if($_ =~ m/edir/)
		{
			$EDIR_SYSCONFIG_FILE_NAME = $_;
		}
		if($_ =~ m/xad/)
		{
			my $SERVICE_CONFIGURED=`grep -r SERVICE_CONFIGURED $PATH_SYSCONFIG/$_` ; #check whether service is configured or not
		    my @SERVICE_CONFIGURED_VAR = split('=',$SERVICE_CONFIGURED);
	        chomp(@SERVICE_CONFIGURED_VAR);
	        my @SERVICE_CONFIGURED_VAL = split('"',$SERVICE_CONFIGURED_VAR[1]);
	        chomp(@SERVICE_CONFIGURED_VAL);
	        if ($SERVICE_CONFIGURED_VAL[1] eq 'yes' )
     	    {
				$XAD_CONFIGURED="yes";
	   	    }
		}
	}
AddMissingAttributes();

    Verify_and_Apply();
   }
   elsif($numArgs == 1 && lc($ARGV[0]) eq 'version') #check script version
   {
      print "oes_upgrade_check version is $VERSION_NUMBER \n";
      print $OUTPUT "\noes_upgrade_check version is $VERSION_NUMBER \n";
   }
   elsif ((exists $SYSCONF_FILE_NAMES{lc($ARGV[0])} ? "yes" : "no") eq "no") #checks for valid arguments which is defined in the hash %SYSCONF_FILE_NAMES 
   {
       print " $ARGV[0] is invalid argument \n";
       Usage();
       exit;
   } 
   else
   { 
       my @CMD_INPUT_ARR_LIST=@ARGV;
       foreach (@CMD_INPUT_ARR_LIST)
       {
          my $CMD_SYSCONFIG_FILE_NAME;
          my $CMD_SYS_NAME=lc($_);
          chomp $CMD_SYS_NAME;
          if($oes_release_name eq '2.0.3') #ifolder sysconfig file has different format
          {
              if ($CMD_SYS_NAME eq 'ifolder')
              {
                    $CMD_SYSCONFIG_FILE_NAME="$SYSCONF_FILE_NAMES{$CMD_SYS_NAME}_2\_"."sp3";
              }
              else
              {
                   $CMD_SYSCONFIG_FILE_NAME="$SYSCONF_FILE_NAMES{$CMD_SYS_NAME}2\_"."sp3";
              #     if ($CMD_SYS_NAME eq 'edir')
              #     {
              #         $EDIR_SYSCONFIG_FILE_NAME = $CMD_SYSCONFIG_FILE_NAME;
              #     } 
              }
         }
         elsif($oes_release_name eq '11')
         {
              if ($CMD_SYS_NAME eq 'ifolder')
              {
                   $CMD_SYSCONFIG_FILE_NAME="$SYSCONF_FILE_NAMES{$CMD_SYS_NAME}_2\_"."oes11";
              }
              else
              {
                  $CMD_SYSCONFIG_FILE_NAME="$SYSCONF_FILE_NAMES{$CMD_SYS_NAME}2\_"."oes11";
              }
        }
        else
        {
            $CMD_SYSCONFIG_FILE_NAME="$SYSCONF_FILE_NAMES{$CMD_SYS_NAME}\_"."$release_name";
	AddMissingAttributes();
	}
        
        if($CMD_SYS_NAME eq 'edir')
        {
           push (@LIST_SYSCONFIG_FILES,'oes-ldap');
           $EDIR_SYSCONFIG_FILE_NAME = $CMD_SYSCONFIG_FILE_NAME;
        }   
        push (@LIST_SYSCONFIG_FILES,$CMD_SYSCONFIG_FILE_NAME);
    }
    chomp @LIST_SYSCONFIG_FILES;
    Verify_and_Apply();  #function for verify the modified attributes and apply the changes.
  }

}


# Function to display unmodified attributes which are stored in the hash %SYSCONFIG_NO_CHANGE_ATTR
sub DispSysconfigNoChangeAttr
{
   if(%SYSCONFIG_NO_CHANGE_ATTR) 
   {
      print $OUTPUT "\n  \t List of unmodified attributes :  \n";
      foreach my $key (keys %SYSCONFIG_NO_CHANGE_ATTR)
      {
          print $OUTPUT "\t\t $key =  $SYSCONFIG_NO_CHANGE_ATTR{$key} \n";
      }
   }
}

# Function to display list of not configured services which are stored in the array @SERVICE_CONFIGURED_NO
sub DispServiceNotConfigured
{
   if(@SERVICE_CONFIGURED_NO) #if hash stores not configured services
   {
       print $OUTPUT "\nFollowing services are not configured i.e. SERVICE_CONFIGURED = \"NO\" \n";
       foreach (@SERVICE_CONFIGURED_NO)
       {
          print $OUTPUT "\n$_";
       }
    }
}


#Funtion to apply/discard the modified attributes value to sysconfig files based on user input. These values are stored in the hash %SYSCONFIG_MODIFIED_ATTR
sub DispSysconfigModifiedAttr
{
   if(%SYSCONFIG_MODIFIED_ATTR) # if hash has modified attributes value
   {
       $#ARGV=-1;
       print $OUTPUT "\n\t\t Do  you wish to apply these changes Y(yes) or N(no) ? \n";
       print "\t\t Do  you wish to apply these changes Y(yes) or N(no) ? \n";
       my $answer = <>; #command line input
       chomp $answer;
       print $OUTPUT "\n$answer \n";
       if (lc($answer) eq 'y' || lc($answer) eq 'yes')
       {
          write_diff_data_to_sysconfig(); #Apply the modified attributes value to sysconfig files
          print $OUTPUT "\n\n \t Attributes value changed. \n\n";
          print "\n \t Attributes value changed. \n\n";
       }
       else
       {
          print $OUTPUT "\n\n \t Attributes value remains unchanged. \n\n";
          print "\n \t Attributes value remains unchanged. \n\n";
       }
   }
}

#my $LOGFILE="/tmp/oes_upgrade_check-$CURRENT_TIME";
#open (my $OUTPUT, '>', "/tmp/oes_upgrade_check-$CURRENT_TIME") || die "File could not open";
OESReleaseName();
print $OUTPUT "\nCurrent dir $CURRENT_DIR \n ";
ArgValidate();
AssignAgrList();
DispSysconfigModifiedAttr();
DispSysconfigNoChangeAttr();
DispServiceNotConfigured();
close $OUTPUT;
