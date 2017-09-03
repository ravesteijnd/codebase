#!/bin/bash

LOGFILE=/var/log/backupjob.log
LASTRUNFILE=lastbackup.txt

echo "Starting job at $(date +%d-%m-%y/%H:%M:%S)" >> $LOGFILE
echo "Checking if host is online ..." >> $LOGFILE
if ping -c 1 192.168.1.201 &> /dev/null
then
        echo "Checking last time this job was run ..." >> $LOGFILE
        if [ ! -f $LASTRUNFILE ]; then
                echo "Could not determine last run" >> $LOGFILE
                LASTRUN=0
        else
                LASTRUN="`cat $LASTRUNFILE`"
        fi
		echo $LASTRUN

		# If the last backup was run more than 12 hours ago
		CURRENT_TIME=$(date +%s)
		CHECKING_TIME=$(($LASTRUN+43200))
        if [ "$CURRENT_TIME" -gt "$CHECKING_TIME" ] ; then
			echo "Host is online, trying to mount directory ..." >> $LOGFILE
			sudo mount -t cifs -o username=Daan,password=Iceman1122 //192.168.1.201/Backup /mnt/win
			echo "Checking if directory is successfully mounted ..." >> $LOGFILE
			if mountpoint -q /mnt/win; then
					echo "Directory is mounted" >> $LOGFILE
					echo "Syncing folders ..." >> $LOGFILE
					sleep 1
					sudo rsync -avz --delete "/mnt/600gb_external/600gb_share/Backup" "/mnt/win"
					echo "Done" >> $LOGFILE
					echo "$(date +%s)" >> $LASTRUNFILE 
			else
					echo "Windows PC is not mounted, cannot run backup" >> $LOGFILE
			fi
		else 
			echo "Last run was less than 12 hours ago, exiting ..." >> $LOGFILE
		fi
else
        echo "Host is offline, removing mount if there is any ..." >> $LOGFILE
        sudo umount -f -l /mnt/win
fi

echo "End." >> $LOGFILE



