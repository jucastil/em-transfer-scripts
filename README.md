# em-transfer-scripts
bash scripts for EM data transfer. Read the README for the details

# How to use this
* Donwload the file
* edit it so that it matches your setup 
* make it executable (chmod 777)
* put it as a cronjob (crontab -e)

# What does this do
It does a loop over the folders on the storage data share.  
If it finds a folder named YYYY-MM-DD_username_project, data inside is transferred.  

**IMPORTANT** : it only transfer the data if:
* the folder is recent (not older than a week)
* the folder is NOT containing "tomo" on its name (tomo sessions are treated separately)
* the files are stored under /Images-DiscXXX/GridXXX/Data/
* the files are MRC or TIFF and are older than 15 minutes
