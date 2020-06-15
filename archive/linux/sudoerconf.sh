#!/bin/bash

# Allow Sudo access for ECS
echo "Setting up SUDO access for ECS"
if [ ! -z "$1" ]; then
	echo "#Change requested by ECS" >> $1
	echo "%ECS_ELSS_ADMIN ALL=(ALL) NOPASSWD: ALL" >> $1
else
	export EDITOR=$0
	visudo
fi

exit

