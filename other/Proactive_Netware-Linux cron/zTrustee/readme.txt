
zTrustee v2.02.3

Usage:

- zTrustee [options] SAVE (ALL | <path>) <outputFile>
  Saves all file system properties into a CSV file starting from the given path (or, using the ALL parameter, all the directories and files on the volume).
  Use options to include selected properties only, or to process files or directories separately (see the Option explanation below).

  Example:
  zTrustee SAVE ALL VOL1:Home/Admin/Trustee.txt
    Save all properties from all local volumes to the specified file
  zTrustee /EDI SAVE VOL1:Programs VOL1:Home/Admin/Trustee.txt
    Save all directory quotas and IRMs starting at the given path
  zTrustee /ETO /R SAVE DATA:Home DATA:Trustee.txt
    Save all trustees and owners starting at the given path, storing relative path


- zTrustee [options] RESTORE <inputFile>
  Restores file system properties from the CSV file created by the previous function.
  Use options to restore selected properties only, or to process files or directories separately (see the Option explanation below).

  Example:
  zTrustee RESTORE VOL1:Home/Admin/Trustee.txt
    Restore every settings found in the input file
  zTrustee /D /ETI RESTORE VOL1:Home/Admin/Trustee.txt
    Restore only directory trustees and IRMs from that file
  zTrustee /ETO /R USERS:Home RESTORE USERS:Trustee.txt 
    Restore all trustees and owners from file to the given base path. Input file is supposed to contain relative path only


- zTrustee REMOVE (ALL | <path>)
  Removes all trustee rights starting from the given path (or, using the ALL parameter, all the directories and files on the volume).

  Example:
  zTrustee REMOVE ALL
    Remove all trustees from all volumes on this server
  zTrustee REMOVE VOL1:Programs
    Remove all trustees starting at the given path


- zTrustee REMOVENULL (ALL | <path>)
  Removes all trustee rights starting from the given path (or, using the ALL parameter, all the directories and files on the volume), where empty rights are assigned.

  Example:
  zTrustee REMOVENULL VOL1:Programs
    Remove all empty trustees starting at the given path


- zTrustee RESTRICT <rights> (ALL | <path>)
  Restrict trustees to the given rights starting from the given path (or, using the ALL parameter, all the directories and files on the volume).

  Example:
  zTrustee RESTRICT RF VOL1:Home
    Restrict trustee rights to read and file scan


- zTrustee LENGTH <number> (ALL | <path>) <outputFile>
  Save path names longer than the given number into a CSV file starting from the given path (or, using the ALL parameter, all the directories and files on the volume).

  Example:
  zTrustee LENGTH 250 VOL1:Home DATA:output.csv
    Save path names longer than 250 characters


- zTrustee ACCESSED <days> (ALL | <path>) <outputFile>
  Save path names of entries older than the given number of days (accessed date is older than x days) into a CSV file starting from the given path (or, using the ALL parameter, all the directories and files on the volume).

  Example:
  zTrustee ACCESSED 365 VOL1:Home DATA:output.csv
    Save path names with access date older than one year



Options can be specified with the SAVE and RESTORE commands:
  
    [/V] [/A] [/R[ basePath]] [/H host:port] [/F] [/D] [/E[T][I][O][A][D]]
    /V  ... verbose mode (include all lines written to the output, or read from the input file into [sys:]ztrustee.log)
    /A  ... all entries, even unchanged or default ones (makes it possible to change them in a text editor and restore back)
    /R  ... use relative path (specify basePath for restore only)
    /H  ... LDAP server info to use DNs instead of GUIDs
    /F  ... files only
    /D  ... directories only
    /ET ... trustee entries only
    /EI ... IRM entries only
    /EO ... owner entries only
    /EA ... attribute entries only
    /ED ... dirquota entries only

If no parameters are specified, the program gives a short description on usage.
The program lists its activities into the [sys:]ztrustee.log file.


Sample output file:

ZTRUSTEE v2.00
"ATTR","SYS:\Apache\Apache.nlm","LONG","APShDi",""
"OWNER","SYS:\Apache\Apache.nlm","LONG","49FC5F80-9C85-11D9-AAC1-000C2911B121",""
"TRUSTEE","SYS:\TRUSTEE\temp","LONG","cn=user,o=org","RWCEMFA"
"IRM","SYS:\Network Trash Folder","LONG","S",""
"DIRQUOTA","SYS:\TRUSTEE\temp","LONG","3200",""

"LENGTH","sys:tmp\attr.ztr","LONG","252",""
"ACCESSED","sys:\adminsrv\lib\ecb.jar","LONG","37",""


ATTR
  path       The complete path, starting with the volume name
  namespace  LONG
  attrs      Abbreviated attribute names
             Ro  Read-Only
             H   Hidden
             Sy  System
             A   Archive needed
             X   Execute only
             T   Transactional
             P   Immediate purge
             Sh  Shareable
             Di  Delete inhibit
             Ci  Copy inhibit
             Ri  Rename inhibit
  na         Not used, leave it empty
  
OWNER
  path       The complete path, starting with the volume name
  namespace  LONG
  owner      GUID (globally unique ID) or full distinguished object name (/H option)
  na         Not used, leave it empty

TRUSTEE
  path       The complete path, starting with the volume name
  namespace  LONG
  trustee    GUID (globally unique ID) or full distinguished object name (/H option)
  rights     Trustee rights
             R   Read
             W   Write
             C   Create
             E   Erase
             M   Modify
             F   File scan
             A   Access control

IRM
  path       The complete path, starting with the volume name
  namespace  LONG
  irm        Rights allowed to flow down from upper levels
             R   Read
             W   Write
             C   Create
             E   Erase
             M   Modify
             F   File scan
             A   Access control
  na         Not used, leave it empty

DIRQUOTA
  path       The complete path, starting with the volume name
  namespace  LONG
  quota      Assigned quota in KB, must be a multiple of 4
             Specify -4 on input to remove the quota
  na         Not used, leave it empty

LENGTH
  path       The complete path, starting with the volume name
  namespace  LONG
  length     Length of the path name
  na         Not used, leave it empty

ACCESSED
  path       The complete path, starting with the volume name
  namespace  LONG
  accessed   Number of days elapsed from the last accessed date
  na         Not used, leave it empty


Compatibility: The program was tested on OES1/2 NetWare/Linux servers.

Always use the latest support pack.
