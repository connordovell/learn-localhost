#!/bin/bash

# eventually want to make this distro-agnostic, but starting with rpm based systems..
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
