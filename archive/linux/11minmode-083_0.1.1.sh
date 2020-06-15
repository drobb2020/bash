#!/bin/bash

adjtimex --print | awk '/status/ {
    if ( and($2, 64) == 0 ) {
        print "11 minute mode is enabled"
    } else {
        print "11 minute mode is disabled"
    }
}'
