# em-transfer-scripts
bash scripts for EM data transfer.

> :warning: ** WARNING**: These script are coming without any warranty! > :warning:

# How to use this
* Donwload the files on your linux client
* edit the relevant parameters, specially: 
  * INPUT='/CIFS_KISS_STORAGE' (where the KISS data lays)
  * OUTPUT=/BIGSTORAGE/RAW/Krios/$YEAR (where the KISS data goes)
* make them executable (chmod 777)
* do a test run
* put it as a cronjob (crontab -e)

# What does this do
Both scripts run a loop over the folders on the storage data share.  
**transfer_KISS_data.sh** is optimized for single particle sessions.  
If it finds a folder named YYYY-MM-DD_username_project, data inside is COPIED.  
**transfer_KISS_TOMO_data.sh** is optimized for tomography sessions.  
If it finds a folder named YYYY-MM-DD_username_tomo_project, data inside is COPIED.  

All the action is logged on **/var/log/**.  
Session lock files are stored there also.  
Both algorithms are "not ideal" :stuck_out_tongue_winking_eye: but they are easy to understand and edit.

**IMPORTANT** : it only COPIES the data if:
* the folder is recent (not older than a week)
* the folder is NOT containing "tomo" on its name (tomo sessions are treated separately)
* the files are stored under /Images-DiscXXX/GridXXX/Data/
* the files are MRC or TIFF and are older than 15 minutes

Feel free to change the "copy" to "move" when you are ready for it :grin:
