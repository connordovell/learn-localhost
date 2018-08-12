#!/bin/bash

if [ -f /usr/bin/apt ]
then
    # DEB BASED SYSTEMS
    rand_package=`dpkg --get-selections | awk {'print $1'} | shuf -n 1`
    echo $rand_package
    apt show $rand_package

    read -p "Press enter to begin reading any found documentation.."
    # Loop over documentation
    while read -r man_page
    do
        man $man_page
    done < <(dpkg-query -L $rand_package | grep man | grep gz)
    
    read -p "Do you want to look at the files installed by the package? (y/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Downloading.."
        if [ -d $rand_package ]
        then
            rm -rf $rand_package/*
        else
            mkdir $rand_package
        fi
        cd $rand_package
        apt download $rand_package 
        deb_file_name=`ls | grep $rand_package | grep '.deb'`
        dpkg -x $deb_file_name .
        echo "You'll find the files in ./$rand_package"
    fi
else
    # RPM BASED SYSTEMS
    rand_package=`yum list installed | grep -v ^Installed | shuf -n 1 | awk {'print $1'} | sed 's/\..*//'`
    echo $rand_package
    yum info $rand_package

    read -p "Press enter to begin reading any found documentation.."
    # Loop over documentation
    while read -r man_page
    do
        man $man_page
    done < <(rpm -ql $rand_package | grep man | grep gz)

    read -p "Do you want to look at the files installed by the package? (y/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Downloading.."
        if [ -d $rand_package ]
        then
            rm -rf $rand_package/*
        else
            mkdir $rand_package
        fi
        cd $rand_package
        yumdownloader $rand_package 
        rpm_file_name=`ls | grep $rand_package | grep '.rpm'`
        rpm2cpio $rpm_file_name | cpio -idmv #Extract the rpm
        echo "You'll find the files in ./$rand_package"
    fi
fi


