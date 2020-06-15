#!/bin/bash

# File   cron-config.sh
# Description 	Configure the shell and environment variables for user crontabs

# Created on: Fri Sep 01 2017 15:18
# Last updated: 
# Version: 0.1.1

# Set the shell to bash
echo SHELL=/bin/sh >> ~/bin/tmp.cron

# Set the path to the current system environment
echo PATH=$PATH >> ~/bin/tmp.cron

# add a space into the file
echo >> ~/bin/tmp.cron

# Add the contents of the current user's crontab
crontab -l >> tmp.cron

# Import the new modified cron into crontab
crontab tmp.cron

exit 1

