# Automatic Snapshots for Google (gcloud) Compute Engine

Bash script for Automatic Snapshots and Cleanup on Google Compute Engine. **Requires no user input!**

Inspiration (and the installation instructions) taken from AWS script [aws-ec2-ebs-automatic-snapshot-bash](https://github.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-bash)


## How it works
gcloud-snapshot.sh will:

- Determine the device ID of the Google Compute Engine server on which the script runs
- Get the Primary Disk ID attached to that instance
- Take a snapshot of Disk
- The script will then delete all associated snapshots taken by the script that are older than 7 days (optional: [default snapshot retention can be changed by using -d flag](#snapshot-retention))


## Prerequisites
* `cURL` must be installed
* The VM must have the sufficient gcloud permissions, including "compute" set to "enabled":

	[	http://stackoverflow.com/questions/31905966/gcloud-compute-list-networks-error-some-requests-did-not-succeed-insufficie#31928399](http://stackoverflow.com/questions/31905966/gcloud-compute-list-networks-error-some-requests-did-not-succeed-insufficie#31928399)


## Installation

ssh on to the server you wish to have backed up

**Install Script**: Download the latest version of the snapshot script and make it executable:
```
cd ~
wget https://raw.githubusercontent.com/jacksegal/google-compute-snapshot/master/gcloud-snapshot.sh
chmod +x gcloud-snapshot.sh
mkdir -p /opt/google-compute-snapshot
sudo mv gcloud-snapshot.sh /opt/google-compute-snapshot/
```

**Setup CRON**: You should then setup a cron job in order to schedule a daily backup. Example cron:
```
0 5 * * * root /opt/google-compute-snapshot/ebs-snapshot.sh >> /var/log/cron/snapshot.log 2>&1
```

**Manage CRON Output**: You should then create a directory for all cron outputs and add it to logrotate:

- Create new directory:
``` 
mkdir /var/log/cron 
```
- Create empty file for snapshot log:
```
touch /var/log/cron/snapshot.log
```
- Change permissions on file:
```
chgrp adm /var/log/cron/snapshot.log
chmod 664 /var/log/cron/snapshot.log
```
- Create new entry in logrotate so cron files don't get too big (it is a multi-line command - copy and paste all of it):
```
cat > /etc/logrotate.d/cron << EOF
/var/log/cron/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 664 root adm
    sharedscripts
}
EOF
```

**To manually test the script:**
```
sudo /opt/google-compute-snapshot/ebs-snapshot.sh
```

## Snapshot Retention
By default snapshots will be kept for 7 days, however they can be kept for longer / shorter, by using the the -d flag:

    Usage: ./snapshot.sh [-d <days>]
    
    Options:
    
       -d  Number of days to keep snapshots. Snapshots older than this number deleted.
           Default if not set: 7 [OPTIONAL]

## Limitations
* Only works for the primary disk on VM
* Only manages snapshots created by the script


## Downloading the script and opening in Windows?

If you download the script and open it on a Windows machine, that may add windows character's to the file: https://github.com/Forward-Action/google-compute-snapshot/issues/1.
