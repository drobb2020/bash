#!/bin/bash

rsync --remove-source-files -a casadmin@$1:/home/backup/backup_* /home/backup

exit 1

