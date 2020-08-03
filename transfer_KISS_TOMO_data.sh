#!/bin/bash

###----------------------------------------------
### Krios Image Storage Server (KISS)
### data transfer script (TOMO data)
###----------------------
### Juan.Castillo@biophys.mpg.de
### last update: 24.01.2019
###----------------------------------------------

### dates
DATE=`date +%Y-%m-%d`
DATE_2=`date --date="1 day ago" +%Y-%m-%d`
DATE_3=`date --date="2 days ago" +%Y-%m-%d`
DATE_4=`date --date="3 days ago" +%Y-%m-%d`
DATE_5=`date --date="4 days ago" +%Y-%m-%d`
DATE_6=`date --date="5 days ago" +%Y-%m-%d`
DATE_7=`date --date="6 days ago" +%Y-%m-%d`
DATE_8=`date --date="7 days ago" +%Y-%m-%d`
YEAR=`date +%Y`
### RUN parameters
INPUT='/CIFS_KISS_STORAGE'
OUTPUT=/BIGSTORAGE/RAW/Krios/$YEAR
TRANSFERLIST='/var/logs/KISS.transfer'
FOLDER="blablabla"
LOCK='/var/logs/automatic.KISS.lock'
TRANSFERLIST='/var/logs/KISS.transfer'
FOLDERS_ALL='/var/logs/KISS.FOLDERS_ALL'
FOLDERS_OK='/var/logs/KISS.FOLDERS_OK'
FOLDERS_OLD='/var/logs/KISS.FOLDERS_OLD'
FOLDER="blablabla"
LOCK='blablabla'

### email alert
DESTINATION="root"

function list_share_folders(){
	### make a list of all folders on INPUT
	for FOLDER in `ls $INPUT`; do 
		if [ ! -d $INPUT/$FOLDER ]; then 
			###echo "	not a folder: " $FOLDER;
			NSKIPP=$((NSKIPP+1))
		else
			echo "$FOLDER" >> $FOLDERS_ALL
		fi
	done
}

function list_session_folders(){
	### make a list of all session folders on FOLDERS_ALL
	for FOLDER in `cat $FOLDERS_ALL`; do
			if [[ $FOLDER == "$DATE"* ]]; then	echo "$FOLDER" >> $FOLDERS_OK
			elif [[ $FOLDER == "$DATE_2"* ]]; then echo "$FOLDER" >> $FOLDERS_OK
			elif [[ $FOLDER == "$DATE_3"* ]]; then echo "$FOLDER" >> $FOLDERS_OK
			elif [[ $FOLDER == "$DATE_4"* ]]; then echo "$FOLDER" >> $FOLDERS_OK
			elif [[ $FOLDER == "$DATE_5"* ]]; then echo "$FOLDER" >> $FOLDERS_OK
			elif [[ $FOLDER == "$DATE_6"* ]]; then echo "$FOLDER" >> $FOLDERS_OK
			elif [[ $FOLDER == "$DATE_7"* ]]; then echo "$FOLDER" >> $FOLDERS_OK
			else
				echo "$FOLDER" >> $FOLDERS_OLD
			fi 
	done
	
}

function transfer_tomo_sessions(){	
	for FOLDER in `cat $FOLDERS_OK`; do
			if [[ $FOLDER == *"tomo"* ]]; then
				echo "	"`date +%Y-%m-%d%t%H:%M` ":	Tomo session found: " $FOLDER
				LOCK=/sb_home/admin/logs/KISS.TOMO.$FOLDER.lock
				if [ ! -f $LOCK ]; then
					echo "	"`date +%Y-%m-%d%t%H:%M` ":	No lock found, creating it: " $LOCK
					touch $LOCK
					### create the folder if not there
					if [ ! -d $OUTPUT/$FOLDER ]; then
						mkdir $OUTPUT/$FOLDER
					else
						echo "	"`date +%Y-%m-%d%t%H:%M` ":	Destination exist, adding new data to: " $OUTPUT/$FOLDER
					fi
					### rsync all, print stats only
					rsync -am --stats $INPUT/$FOLDER $OUTPUT/$SESSION
					echo "	"`date +%Y-%m-%d%t%H:%M` ":	Transfer done. Removing lock file:" $LOCK
					rm $LOCK 	
				else
					echo "	"`date +%Y-%m-%d%t%H:%M` ":	LOCK FOUND: TO RESTART TRANSFER PLEASE DELETE IT -> " $LOCK
				fi
			else
				echo "	"`date +%Y-%m-%d%t%H:%M`"	Not a tomo session:" $FOLDER
			fi
	done

}

################### start of the MAIN process ########################
start=`date +%s`
echo " ----------------------------------------"
echo "	"`date +%Y-%m-%d%t%H:%M` ": KRIOS 1 K3 TOMO transfer STARTED "
echo " ----------------------------------------"

LOCKG=/sb_home/admin/logs/KISS.TOMO.running.lock
if [ ! -f $LOCKG ]; then
	echo "	"`date +%Y-%m-%d%t%H:%M` ": Creating transfer LOCK : " $LOCKG
   	touch $LOCKG
   	list_share_folders
   	echo "	"`date +%Y-%m-%d%t%H:%M` ": Total folders on the share : " `cat $FOLDERS_ALL | wc -l `
   	list_session_folders
   	echo "	"`date +%Y-%m-%d%t%H:%M` ": Total sessions to scan : " `cat $FOLDERS_OK | wc -l`
   	transfer_tomo_sessions
   	echo "	"`date +%Y-%m-%d%t%H:%M` ": Cleaning up... " 
   	rm -rf $FOLDERS_ALL $FOLDERS_OK $FOLDERS_OLD $LOCKG
   	echo "	"`date +%Y-%m-%d%t%H:%M` ": ...Done " 
else  	
   	echo "	"`date +%Y-%m-%d%t%H:%M` ": TRANSFER seems to be running, LOCK name: " $LOCKG 
fi

STATUS=`df -h $INPUT | tail -1 |  awk '{print "Size: "$2" Used: "$3" Free: "$4" ("$5")"}'`

end=`date +%s`
runtime=$((end-start))
echo "	"`date +%Y-%m-%d%t%H:%M` ": SHARE STATUS: 	" $STATUS 
echo "	"`date +%Y-%m-%d%t%H:%M` ": Runtime (in seconds) : " $runtime
echo " -----------------------------------------------------------------"
echo "	"`date +%Y-%m-%d%t%H:%M` ": Krios1 K3 transfer FINISHED "
echo " -----------------------------------------------------------------"

##echo "transfer completed" | mail -s "DATA TRANSFER" $DESTINATION@biophys.mpg.de
