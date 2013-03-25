#!/bin/bash
#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'home/beef/doc/COPYING' for copying permission
#

   
#
# This is the auto startup script for the BeEF Live CD. 
# IT SHOULD ONLY BE RUN ON THE LIVE CD
# Download LiveCD here: http://downloads.beefproject.com/BeEFLive1.4.iso
# MD5 (BeEFLive1.4.iso) = 5167450078ef5e9b8d146113cd4ba67c
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

#
# function to start msf and run in the background
#
run_msf() {	
	# start msf
	/opt/metasploit-framework/msfconsole -r /opt/beef/test/thirdparty/msf/unit/BeEF.rc 2> /dev/null
}

#
# functions to enable or disable msf integration
#
enable_msf() {
	# enable msf integration in main config file
	sed -i '1N;$!N;s/metasploit:\n\s\{1,\}enable:\sfalse/metasploit:\n            enable: true/g;P;D' /opt/beef/config.yaml
	# enable auto_msfrpcd
	sed -i 's/auto_msfrpcd:\sfalse/auto_msfrpcd: true/g' /opt/beef/extensions/metasploit/config.yaml	
}
disable_msf() {
	# disable msf integration in main config file
	sed -i '1N;$!N;s/metasploit:\n\s\{1,\}enable:\strue/metasploit:\n            enable: false/g;P;D' /opt/beef/config.yaml
	# disable auto_msfrpcd
	sed -i 's/auto_msfrpcd:\strue/auto_msfrpcd: false/g' /opt/beef/extensions/metasploit/config.yaml
}

#
# function to exit cleanly
#
# trap ctrl-c and call close_bash()
trap close_bash_t INT

close_bash_t() {
	# beef would have quit
	back_running="0"
	close_bash
}
close_bash() {
	echo ""	
	echo "Are you sure you want to exit the LiveCD? (y/N): "
	read var
	if [ $var = "y" ] ; then
		disable_msf
		exit
	else		
		show_menu
	fi
}

# set default values
bac="0"



#
# User Menu Loop
#
show_menu() {
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
			echo -ne "                                             beef@"
			ifconfig | awk -F "[: ]+" '/inet addr:/ { if ($4 != "127.0.0.1") print $4 }'
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
		
		if [ "$msf" = "1" ] ; then
			echo "[7] Disable metasploit-framework integration [Currently Enabled]"
		else
			echo "[7] Enable metasploit-framework integration  [Currently Disabled]"
		fi
			echo ""
			echo "[q] Quit to terminal"
			echo ""
		if [ "$back_running" = "1" ] ; then	
			echo "[k] End BeEF process [BeEF running in background mode]"
		else
			echo "[b] Run BeEF"
		fi
			echo ""
			echo -n "BeEF Live ~# "
			read var
		
		#
		# Quit liveCD loop
		#	
		if [ $var = "q" ] ; then
			 close_bash
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
			 msf="0"
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
		# enable the msf integration
		#
		if [ $var = "7" ] ; then
			if [ "$msf" = "1" ] ; then
			 	msf="0"
			 	disable_msf
			else 
				msf="1"
				enable_msf
			fi
		fi
		
		#
		# end background beef process
		#
		if [ $var = "k" ] ; then
			pkill -x 'ruby'
			back_running="0"
		fi
		
		#
		# Run BeEF
		#
		if [ $var = "b" ] ; then
			
			if [ "$msf" = "1" ] ; then
				#
				# First start msf if it is enabled
				#
				printf "Starting MSF (wait 45 seconds)..."
				run_msf &
				sleep 45
			fi
			
			if [ "$bac" = "1" ] ; then
				#
				# run beef in the background
				#
			 	run_beef &
				sleep 5
				echo ""
				echo "BeEF is running in the background, returning to the menu or running something else now..."
				sleep 15
				back_running="1"
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
				#
				# run beef in the foreground
				#
				cd /opt/beef/
				ruby beef -x
			fi
		fi	
			
	done
}

# show user menu
show_menu



