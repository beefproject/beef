#!/bin/bash
#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'home/beef/doc/COPYING' for copying permission
#

   
#
# This is the auto startup script for the BeEF Live CD. 
# IT SHOULD ONLY BE RUN ON THE LIVE CD
# Download LiveCD here: http://beefproject.com/BeEFLive1.2.iso
# MD5 (BeEFLive1.2.iso) = 1bfba0942a3270ee977ceaeae5a6efd2
#
# This script contains a few fixes to make BeEF play nicely with the way  
# remastersys creates the live cd distributable as well as generating host keys 
# to enable SSH etc. The script also make it easy for the user to update/start 
# the BeEF server
#

#
# Create a shortcut in the user's home folder to BeEF, msf and sqlmap
# (if they do not yet exist)
#
f1="beef"
if [ -f $f1 ] ; then
	echo ""
else
	ln -s /opt/beef/ beef
	ln -s /opt/metasploit-framework/ msf
	ln -s /opt/sqlmap/ sqlmap
fi

#
# function to allow BeEF to run in the background
#
run_beef() {	
	cd /opt/beef/
	ruby beef -x
}

# set default values
bac="0"

#
# User Menu Loop
#
while true; do
	clear
	echo "======================================"
	echo "          BeEF Live CD   "
	echo "======================================"
	echo ""
	echo "Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net"
	echo "Browser Exploitation Framework (BeEF) - http://beefproject.com"
	echo "See the file 'home/beef/doc/COPYING' for copying permission"
	echo ""
	
	echo "Welcome to the BeEF Live CD" 
	echo "" 
	
	
	#
	# Check for SSH Host Keys - if they do not exist SSH will be displayed as disabled 
	# (remastersys has a habit of deleting them during Live CD Creation)
	#
	f1="/etc/ssh/ssh_host_rsa_key"
	if [ -f $f1 ] ; then
		echo "[1] Disable SSH                              [Currently Enabled]"
	else 
		echo "[1] Enable SSH                               [Currently Disabled]"
	fi
	
		echo "[2] Update BeEF"
		echo "[3] Update sqlMap                            (Bundled with LiveCD)"
		echo "[4] Update metasploit-framework              (Bundled with LiveCD)"
		echo ""
	if [ "$bac" = "1" ] ; then
		echo "[5] Disable BeEF in background mode          [Currently Enabled]"
	else
		echo "[5] Enable BeEF in background mode           [Currently Disabled]"
	fi
	
	if [ "$sqlm" = "1" ] ; then
		echo "[6] Disable sqlMap demo                      [Currently Enabled]"
	else
		echo "[6] Enable sqlMap demo                       [Currently Disabled]"
	fi
	
		#echo "[7] Enable metasploit-framework integration  [Currently Disabled]"
		echo ""
		echo "[q] Quit to terminal"
		echo ""
		echo "[b] Run BeEF"
		echo ""
		echo -n "BeEF Live ~# "
		read var
	
	#
	# Quit liveCD loop
	#	
	if [ $var = "q" ] ; then
		 exit
	fi
	
	#
	# Create SSH Keys to enable SSH or Delete the Keys to disable
	#
	if [ $var = "1" ] ; then
		if [ -f $f1 ]
		then
			sudo rm /etc/ssh/ssh_host_rsa_key
			sudo rm /etc/ssh/ssh_host_dsa_key 
		else
			 sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
			 sudo ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
			 echo ""
			 echo "Please provide a password for ssh user: beef"
			 sudo passwd beef
			 echo "ssh enabled"
		 fi
	fi
	
	#
	# Update BeEF from github repository
	#	
	if [ $var = "2" ] ; then
		 cd /opt/beef
		 git stash
		 git pull
	fi
	
	#
	# Update sqlmap from github repository
	#	
	if [ $var = "3" ] ; then
		 cd /opt/sqlmap
	 	 git stash
		 git pull
	fi
	
	#
	# Update msf from github repository
	#
	if [ $var = "4" ] ; then
		 cd /opt/metasploit-framework
		 git stash
		 git pull
	fi
	
	#
	# set BeEF to run in the background
	#
	if [ $var = "5" ] ; then
		if [ "$bac" = "1" ] ; then
		 	bac="0"
		 	# check and disable sqlmap (requires beef run in the background)
		 	sqlm="0"
		else 
			bac="1"
		fi
	fi
	
	#
	# enable the sqlmap demo
	#
	if [ $var = "6" ] ; then
		if [ "$sqlm" = "1" ] ; then
		 	sqlm="0"
		else 
			sqlm="1"
			# requires BeEF be run in the background
			bac="1"
		fi
	fi
	
	#
	# Run BeEF
	#
	if [ $var = "b" ] ; then
		if [ "$bac" = "1" ] ; then
		 	run_beef &
			sleep 5
			echo ""
			echo "BeEF is running in the background, returning to the menu or running something else now..."
			sleep 5
			
			#
			# If the user has enabled it start sqlmap using beef as proxy
			#
			if [ $sqlm = "1" ] ; then
				echo ""
				echo "sqlMAP can now be run using the --proxy command set to the BeEF Proxy: http://127.0.0.1:6789 starting the wizard to demo with:"
				echo "python /opt/sqlmap/sqlmap.py --proxy http://127.0.0.1:6789 --wizard"
				sleep 5
				python /opt/sqlmap/sqlmap.py --proxy http://127.0.0.1:6789 --wizard
			fi
		else 
			cd /opt/beef/
			ruby beef -x
		fi
	fi	
		
done




