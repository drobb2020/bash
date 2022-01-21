#!/bin/bash
###############################################################################
#ScriptName: rsyncVolume.sh                                                   #
#Purpose: Synchronize USER and DATA volumes from src1 to dest1.               #
#                                                                             #
#Requirements: atl-rsync,cen-rsync,nwr-rsync or pac-rsync                     #
#              must be able to ssh into the source server with no             #
#              password prompt.                                               #
###############################################################################

#Functions

#Create Log Header
function writeHeader(){
    
    echo '-------------------------------------------------------------------------------------' >> $1
    echo '---------------------------------Log Header------------------------------------------' >> $1
    echo '-------------------------------------------------------------------------------------' >> $1
}

#Create Log Footer
function writeFooter(){

    echo '-------------------------------------------------------------------------------------' >> $1
    echo '--------------------------------End Log Footer---------------------------------------' >> $1
    echo '-------------------------------------------------------------------------------------' >> $1
}

function loadMenu(){
    clear
    echo
    echo "              Menu List                    "
    echo "              ---------                    "
    echo "Choose your option from the menu below     "
    echo 
    echo "[H]ome Directory Sync"
    echo "[D]ata Drive Sync from regional server"
    echo "[S]taging Drive Sync to end state server"
    echo "[Q]uit"
    echo

    read -rp "Select option: " option

}

function getOption(){
    case $option in
        "H" | "h" )
            promptForOptions=0
            promptForInput
            ;;
        "D" | "d" )
            promptForOptions=0
            promptForInput
            ;;
        "S" | "s" )
            promptForOptions=0
            ;;
        "Q" | "q" )
            exit
            ;;
        * )
            echo
            echo "Please choose valid option"
            echo 
            read -n1 -r -p "Press any key to continue..." key 
            clear
            promptForOptions=1
            loadMenu
            ;;
    esac
} 
function promptForInput(){
    read -rp "Select Tree Name [ATL,CEN,NWR,PAC]: " treeChoice
    
    case $treeChoice in
        "ATL" | "atl" )
            user="atl-rsync"
            ;;
        "CEN" | "cen" )
            user="cen-rsync"
            ;;
        "NWR" | "nwr" )
            user="nwr-rsync"
            ;;
        "PAC" | "pac" )
            user="pac-rsync"
            ;;
        * )
            invalidTreeName=1
    esac

    read -rp "Enter Server Name [Example: lchar-s020.l.rcmp-grc.gc.ca]: " hostname
    
    ping -c 2 $hostname >> /dev/null 2>> /dev/null

    if [ $? -ne 0 ]; then
        echo "hostname is invalid, please verify"
        exit
    fi


}
function getBandwidth(){

    read -rp "Select WAN Link Speed ( [1] = 800kbps, [2] = 6.4mbps, [3] = 16mpbs, [4] = Unlimited  " bandwidth
    case $bandwidth in
        "1" )
            promptForBandwidth=0
            speed=100
            ;;
        "2" )
            promptForBandwidth=0
            speed=800
            ;;
        "3" )
            promptForBandwidth=0
            speed=2000
            ;;
        "4" )
            promptForBandwidth=0
            speed=0
            ;;
        * )
            echo
            echo "Please choose valid option"
            echo

			read -n1 -r -p "Press any key to continue..." key
            clear
            getBandwidth
            ;;
    esac
}
function purgeOldArchives(){

    if [ -e $errorLogs ]; then

        mv $errorLogs $archives

    fi

    if [ -e $successLogs ]; then

        mv $successLogs $archives

    fi

}

#MAIN
promptForOptions=1
promptForBandwidth=1
#Load Menu
loadMenu

#Prompt User for Options
while [ ${promptForOptions} -eq 1 ];do

    getOption

done


#Prompt User for Bandwidth
getBandwidth

#Variable Declaration
host=$(echo "$hostname" | cut -d'.' -f1)
errorLogs=/opt/scripts/os/regional/logs/error_"$host".log
successLogs=/opt/scripts/os/regional/logs/success_"$host".log
archives=/opt/scripts/os/regional/logs/archives

#Set the source and destination volume names
if [ $option == "H" ] || [ $option == "h" ]; then
  
    read -rp "Enter branch server volume[Default: /media/nss/USER]: " branchVolume 
    read -rp "Run with delete flag (y/n): " deleteFlag
    deleteFlag=`echo $deleteFlag | tr '[:upper:]' '[:lower:]'`

    if [ -z ${branchVolume} ]; then
        src=/media/nss/USER/
    else
        #Append a / incase user does not add one.
        src=${branchVolume%"/"}/
        
    fi
    
    #Validate Source Volume exists 
    echo $src
    if [ $deleteFlag == "n" ]; then
        test -d $src
    else
        sudo ssh -n -i /home/$user/.ssh/id_rsa $user@$hostname test -d $src
    fi
 
    if [ $? -ne 0 ]; then
        echo "Please verify source volume is up, volume is case sensitive"
        exit
    fi
 
    #Remove any old logs and move them to archives.
    purgeOldArchives

    writeHeader $successLogs

    if [ $deleteFlag == "y" ]; then
        read -rp "Enter destination volume [Example: LDIV_DATA_PR]: " stagingVolume
        while [ -z $stagingVolume ];
        do
            read -rp "Volume name cannot be blank, re enter volume name [Example: LDIV_DATA_PR]: " stagingVolume
        done

        dest=/media/nss/$stagingVolume

        while [ ! -d $dest ];
        do
            read -rp "Please re enter the volume name or make sure it exists [Example: LDIV_DATA_PR]: " stagingVolume
            while [ -z $stagingVolume ];
            do
                read -rp "Volume name cannot be blank, re enter volume name [Example: LDIV_DATA_PR]: " stagingVolume
            done     
            dest=/media/nss/$stagingVolume
        done

        sudo rsync --bwlimit=$speed -atvx --delete --ignore-errors --exclude-from=/opt/scripts/os/regional/excludedFiles.txt -e "sudo ssh -i /home/$user/.ssh/id_rsa" $user@$hostname:$src $dest >> $successLogs 2>> $errorLogs &
    else
	#We are synchronizing to the final volume. Add filter to only copy HRMIS folders.
        hrmis=\*00*\
        src=$src$hrmis
        read -rp "Enter destination server [Example: homedrive3.ross.rcmp-grc.gc.ca]: " destinationServer
        hostname=$destinationServer
		
        dest=/media/nss/HOME3_VOL_PR
        sudo rsync -atvx --update --exclude-from=/opt/scripts/os/regional/excludedFiles.txt --timeout=360 -e "sudo ssh -i /root/.ssh/id_rsa" $src "root@$hostname:$dest" >> $successLogs 2>> $errorLogs &
    fi

fi

if [ $option == "D" ] || [ $option == "d" ]; then

    read -rp "Enter staging volume [Example: LCHAR_DATA]: " stagingVolume
    #stagingVolume=`echo $stagingVolume | tr '[:lower:]' '[:upper:]'`
    read -rp "Enter branch server volume [Default: /media/nss/DATA]: " branchVolume
    #branchVolume=`echo $branchVolume | tr '[:lower:]' '[:upper:]'`
   
    if [ -z ${branchVolume} ]; then
        src=/media/nss/DATA/
    else
        #Append a / incase user does not add one.
        src=${branchVolume%"/"}/
    fi

    while [ -z $stagingVolume ];
    do
        read -rp "Volume name cannot be blank, re enter volume name [Example: LDIV_DATA_PR]: " stagingVolume
    done

    dest=/media/nss/$stagingVolume
    while [ ! -d $dest ];
    do
        read -rp "Please re enter the volume name or make sure it exists [Example: LDIV_DATA_PR]: " stagingVolume
        while [ -z $stagingVolume ];
        do
            read -rp "Volume name cannot be blank, re enter volume name [Example: LDIV_DATA_PR]: " stagingVolume
        done
        dest=/media/nss/$stagingVolume
    done
 
    #Validate Source Volume exists 
    #sudo ssh -n -i /home/$user/.ssh/id_rsa $user@$hostname test -d $src
    #if [ $? -ne 0 ]; then
    #    echo "Please verify source volume is up, volume is case sensitive"
    #    exit
    #fi

    #test -d $dest

    #if [ $? -ne 0 ]; then
    #    echo "Please verify destination volume is up, volume is case sensitive"
    #    exit
    #fi
     
    #Remove any old archives. Possible the sync
    #has been ran several times. 
    purgeOldArchives

    writeHeader $successLogs
    rsync --bwlimit=$speed -atvx --delete --ignore-errors --exclude-from=/opt/scripts/os/regional/excludedFiles.txt --timeout=360 -e "sudo ssh -o StrictHostKeyChecking=no -i /home/$user/.ssh/id_rsa" $user@$hostname:$src $dest >> $successLogs 2>> $errorLogs &
#  echo $! > /tmp/${host}
    
fi

if [ $option == "S" ] || [ $option == "s" ]; then

    read -rp "Enter staging volume [Example: LCHAR_DATA]: " stagingVolume
    #stagingVolume=`echo $stagingVolume | tr '[:lower:]' '[:upper:]'`
    read -rp "Enter destination volume [Example: LDIV_DATA_PR]: " destinationVolume
    #destinationVolume=`echo $destinationVolume | tr '[:lower:]' '[:upper:]'`
    read -rp "Enter destination server [Example: ldiv-cifs.ross.rcmp-grc.gc.ca]: " destinationServer
    read -rp "Enter site folder [Example: Kings District]: " siteFolder
 
    while [ -z "${siteFolder}" ]
    do    
        echo "Site Folder cannot be empty"
        read -rp "Enter site folder [Example: Kings District]: " siteFolder
    done
 
    siteFolder=`echo $siteFolder | sed -e 's/ /\\\ /'`
    
    #Variable Declaration
    host=$(echo "$destinationServer" | cut -d'.' -f1)
    errorLogs=/opt/scripts/os/regional/logs/error_"$host".log
    successLogs=/opt/scripts/os/regional/logs/success_"$host".log
    archives=/opt/scripts/os/regional/logs/archives
    src=/media/nss/$stagingVolume/
    dest=/media/nss/$destinationVolume/$siteFolder
    
    #Validate Source Volume exists 
    #test -d $src
    
    #if [ $? -ne 0 ]; then
    #    echo "Please verify staging volume is correct, volume is case sensitive"
    #    exit
    #fi

    #Check we can resolve source server
    ping -c 2 $destinationServer >> /dev/null 2>> /dev/null

    if [ $? -ne 0 ]; then
        echo "Destination server is invalid, please verify"
        exit
    fi
    
    #Remove any old archives. Possible the sync
    #has been ran several times. 
    purgeOldArchives
    writeHeader $successLogs
    sudo rsync -avtxX --delete --ignore-errors --exclude-from=/opt/scripts/os/regional/excludedFiles.txt --timeout=360 -e "sudo ssh -i /root/.ssh/id_rsa" $src "root@$destinationServer:$dest" >> $successLogs 2>> $errorLogs &
    
fi

if [ $? -eq 0 ]; then
    echo -e "Copy in progress... \nType 'tail -f /opt/scripts/os/regional/logs/success_<hostname>.log' to see the progress."
fi

#End Main
