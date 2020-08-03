#!/bin/bash

###----------------------------------------------
### Krios Image Storage Server (KISS)
### data transfer script
###----------------------
### Juan.Castillo@biophys.mpg.de
### last update: 24.01.2019
###----------------------------------------------

### current date + 7 days before
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
NSKIPP=0
NTRANS=0
STATUS="0"
LSKIPP="0"
LTRANS="0"
NMRCS="0"

#### function checking folder and making the sync
function  check_folder(){
		#echo $FOLDER
		### check the folder is not empty already
		echo "	"`date +%Y-%m-%d%t%H:%M` ":	Checking if folder empty : " $INPUT/$FOLDER
		find $INPUT/$FOLDER -maxdepth 4 -empty -exec echo "	" {} is empty. \;
		### trasfer lock : empty file with the name of the session
		LOCK=/var/logs/KISS.$FOLDER.lock
		### check there is no transfer lock already, if there is, it will not run
		if [ ! -f $LOCK ]; then
			echo "	"`date +%Y-%m-%d%t%H:%M` ":	No lock found, creating one"
   			touch $LOCK
			echo "	"`date +%Y-%m-%d%t%H:%M` ":	Starting copy to : " $FOLDER
			#### check it's not a tomo folder
			if [[ $FOLDER == *"tomo"* ]]; then
				echo "	"`date +%Y-%m-%d%t%H:%M` ":	Tomo session :  skipping ana" 
			else
				#### check if the destination folder exist, if not, make it
				if [ ! -d $OUTPUT/$FOLDER ]; then
					#### dir doesn't exist, make it
					echo "	"`date +%Y-%m-%d%t%H:%M` ":	Creating folder: " $OUTPUT/$FOLDER
					mkdir $OUTPUT/$FOLDER	
					#### count the number of MRC files
					NFILES=`find $INPUT/$FOLDER/Images-Disc*/Grid*/Data/ -type f -name '*.mrc'  -or  -type f  -name '*.tiff' -mmin +15  | wc -l  `
					echo "	"`date +%Y-%m-%d%t%H:%M` ":	Found: " $NFILES " MRCs or TIFFs older than 15 minutes"
				
					#### THE REAL ACTION: cp the file, count it, remove it
					for i in `find $INPUT/$FOLDER/Images-Disc*/Grid*/Data/ -type f -name '*.mrc'  -or  -type f  -name '*.tiff' -mmin +15`; do
						#sleep 1
						#bbcp -arpg -P 2 -s 16 -w 8M $i $OUTPUT/$FOLDER
						echo "	"`date +%Y-%m-%d%t%H:%M` ":transfering: " $i >> $TRANSFERLIST
						NMRCS=$((NMRCS+1))
						cp -Rauv $i $OUTPUT/$FOLDER
						#echo ---- #rm $i
						chown root:root $OUTPUT/$FOLDER
						chmod 755 $OUTPUT/$FOLDER
					done
					##### count the folder as transfered, remove the data transfer lock
					NTRANS=$((NTRANS+1))
					LTRANS=$FOLDER    	
					echo "	"`date +%Y-%m-%d%t%H:%M` ":	Removing lock file:" $LOCK
					rm $LOCK 	
				### if the folder exists, add data to it
				else
					##### count the number of MRC files
					echo "	"`date +%Y-%m-%d%t%H:%M` ":	Folder: " $OUTPUT/$FOLDER " exist: adding data"
					NFILES=`find $INPUT/$FOLDER/Images-Disc*/Grid*/Data/ -type f -name '*.mrc'  -or  -type f  -name '*.tiff' -mmin +15 | wc -l`
					echo "	"`date +%Y-%m-%d%t%H:%M` ":	Found: " $NFILES " MRCs or TIFF older than 15 minutes"
					#### THE REAL ACTION: cp the file, count it, remove it
					for i in `find $INPUT/$FOLDER/Images-Disc*/Grid*/Data/ -type f -name '*.mrc'  -or  -type f  -name '*.tiff' -mmin +15 `; do
                        #bbcp -arpg -P 2 -s 16 -w 8M $i $OUTPUT/$FOLDER
						echo "	"`date +%Y-%m-%d%t%H:%M` ":transfering: " $i >> $TRANSFERLIST
 						cp -Rauv $i $OUTPUT/$FOLDER
                        #echo ___ #rm $i
                        chown root:root $OUTPUT/$FOLDER
                        chmod 755 $OUTPUT/$FOLDER
                        find $OUTPUT/$FOLDER -type d -exec chmod 755 {} +
                        find $OUTPUT/$FOLDER -type f -exec chmod 644 {} +
						#echo "	transfering : " $i
						NMRCS=$((NMRCS+1))
						#sleep 1
					done

					##### count the folder as transfered, remove the data transfer lock
					NTRANS=$((NTRANS+1))
					LTRANS=$FOLDER    	
					echo "	"`date +%Y-%m-%d%t%H:%M` ": 	Removing lock file:" $LOCK
					rm  $LOCK
			fi	
		fi
		### There is a transfer going on, print a message
		else
			echo "	"`date +%Y-%m-%d%t%H:%M` ": 	TRANSFER seems to be running, LOCK name: " $LOCK 
		fi			
		
}

start=`date +%s`
echo " ----------------------------------------"
echo "	"`date +%Y-%m-%d%t%H:%M` ": KRIOS1 F3 transfer STARTED "
echo " ----------------------------------------"

### loop over the folders on /CIFS_KISS_STORAGE
for FOLDER in `ls $INPUT`; do 
	### check "folder" is indeed a folder
	if [ ! -d $INPUT/$FOLDER ]; then 
		#echo "	not a folder: " $FOLDER;
		NSKIPP=$((NSKIPP+1))
		LSKIPP=$FOLDER
	else
		#### Scanning previous DATES (see top)
		if [[ $FOLDER == "$DATE"* ]]; then
			check_folder
		elif [[ $FOLDER == "$DATE_2"* ]]; then
			check_folder
		elif [[ $FOLDER == "$DATE_3"* ]]; then
			check_folder
		elif [[ $FOLDER == "$DATE_4"* ]]; then
			check_folder
		elif [[ $FOLDER == "$DATE_5"* ]]; then
			check_folder
		elif [[ $FOLDER == "$DATE_6"* ]]; then
			check_folder
		elif [[ $FOLDER == "$DATE_7"* ]]; then
			check_folder
		else
			NSKIPP=$((NSKIPP+1))
			LSKIPP=$FOLDER
			#echo "		Now new FOLDER found"
		fi 
	fi
done

### uncommenting this line will send an email once the transfer is done
#echo "transfer completed" | mail -s "DATA TRANSFER" $DESTINATION@biophys.mpg.de
### this should give you info about the storage occupancy
STATUS=`df -h | grep /CIFS_KISS_STORAGE`

### info block: just comment it out if you don't use it
echo " -----------------------------------------------------------------------"	
echo "	"`date +%Y-%m-%d%t%H:%M` ": Last folder skipped		:" $LSKIPP
echo "	"`date +%Y-%m-%d%t%H:%M` ": Last folder transfer	:" $LTRANS
echo "	"`date +%Y-%m-%d%t%H:%M` ": Occupancy: 	" $STATUS "%"
echo " 	"`date +%Y-%m-%d%t%H:%M` ": Folders SKIPPED (old, bad name, or not a folder)	: " $NSKIPP
echo "	"`date +%Y-%m-%d%t%H:%M` ": Total number of folders scanned on this run  : " $NTRANS
if [ $NMRCS -gt 1 ];	then
	echo "	"`date +%Y-%m-%d%t%H:%M` ": Total number of MRCS or TIFFs found on this run  : " $NMRCS
else
	echo "	-------> NOTHING COMING  <-----"
fi
end=`date +%s`
runtime=$((end-start))
echo "	"`date +%Y-%m-%d%t%H:%M` ": Runtime (in seconds) : " $runtime
echo " -----------------------------------------------------------------"
echo "	"`date +%Y-%m-%d%t%H:%M` ": KRIOS1 F3 transfer FINISHED "
echo " -----------------------------------------------------------------"
