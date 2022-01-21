#!/bin/bash

function press_enter
{
    echo ""
    echo -n "Press Enter to continue"
    read -r
    clear
}

selection=
until [ "$selection" = "0" ]; do
    echo ""
    echo "PROGRAM MENU"
    echo "1 - display free disk space"
    echo "2 - display free memory"
    echo ""
    echo "0 - exit program"
    echo ""
    echo -n "Enter selection: "
    read -r selection
    echo ""
    case $selection in
        1 ) df -h ; press_enter ;;
        2 ) free -k ; press_enter ;;
        0 ) exit ;;
        * ) echo "Please enter 1, 2, or 0"; press_enter
    esac
done
