#!/bin/bash

# Test for loop

for i in $(cat ~/bin/servers.txt); do
	echo server: "$i"
done

exit

